classdef (Sealed) SpectrogramDisplay < handle
    %SPECTROGRAMDISPLAY create interactive spectrogram display
    %   SPECTROGRAMDISPLAY(signal, fs) creates an interactive spectrogram
    %   plot of the signal with sampling rate Fs that is calculated to fit the
    %   resolution of the plot. Left clicking zooms, dragging boxes sets the
    %   plot limits, double clicking zooms out. 
    %
    %   Based entirely on DISPLAYSPECGRAMQUICK.M by Aaron Andalman.
    %   Differences include: named optional arguments, correct redisplay of
    %   spectrogram when the figure is resized, does not destroy other
    %   plots in the same axes when resized, ability to freeze the colormap
    %   so that subsequent changes of the figure's colormap do not change
    %   the plot colors.
    %
    %   SPECTROGRAMDISPLAY(ax, signal, fs) plots in the specified axis
    %
    %   SPECTROGRAMDISPLAY(..., paramName, paramValue) sets named
    %   parameters as folows:
    %   'freqRange': default [500 7500], bounds the frequencies included in the
    %       spectrogram
    %   'startTime': default 0, sets the time of the first index in signal
    %   'nCourse': default 1, allows for alteration of the plot resolution
    %   'cLimits': default [], changes the colormap range to fill [min, max].
    %       if empty then the min and max is calculated from the data.
    %   'windowSize': default 512, changes the FFT window size
    %   'NFFT': default 1024, changes the number of FFT points used in the
    %       spectrogram
    %   'backgroundColor': default [0 0 0], the color of the bottom of the
    %       colormap
    %   'colorMap': default jet(256), colormap to use for spectrogram
    %   See also DISPLAYSPECGRAMQUICK, ELECTRO_SONOGRAM_CLONER
    properties (SetAccess = private)
        signal
        fs
        AxisHandle
        
        freqRange
        startTime
        nCourse
        cLimits
        windowSize
        NFFT
        backgroundColor
        frequencyUnits
        
        startNdx
        endNdx
    end
    properties (Access = private)
        cMap
        HostFigure
        ImageHandle
        XLimListener
        taper = [];
        nSamp
        freqScaling
        ownResize
        ownButtonDown
        ChangeResizeListener
        ChangeButtonDownListener
    end
    methods
        function self = SpectrogramDisplay(in1, in2, varargin)
            %SPECTROGRAMDISPLAY make display object
            %   SPECTROGRAMDISPLAY(signal, fs) plots in current axis
            %   SPECTROGRAMDISPLAY(ax, signal, fs) specify axis
            %   SPECTROGRAMDISPLAY(..., ParamName, ParamValue) parameters
            persistent p;
            if isempty(p)
                p = inputParser();
                addOptional(p, 'fs', 0, @isnumeric);
                addParameter(p, 'freqRange', [0, 8000]);
                addParameter(p, 'startTime', 0);
                addParameter(p, 'nCourse', 1);
                addParameter(p, 'cLimits', []);
                addParameter(p, 'windowSize', 512);
                addParameter(p, 'NFFT', 1024);
                addParameter(p, 'backgroundColor', [0, 0 0]);
                addParameter(p, 'colorMap', jet(256));
                addParameter(p, 'frequencyUnits', 'Hz');
            end
            parse(p, varargin{:});
            Params = p.Results;
            if isgraphics(in1)
                self.AxisHandle = in1;
                self.signal = in2;
                self.fs = Params.fs;
            elseif isnumeric(in1)
                self.AxisHandle = gca();
                self.signal = in1;
                self.fs = in2;
                assert(isnumeric(self.fs), 'fs must be numeric');
            else
                error('Input parsing failed');
            end
            assert(isnumeric(self.signal) && numel(self.signal) > 0, 'Signal invalid');
            assert(self.fs > 0, 'fs must be specified');
            
            self.nSamp = numel(self.signal);
            self.freqRange = Params.freqRange;
            self.startTime = Params.startTime;
            self.nCourse = Params.nCourse;
            self.cLimits = Params.cLimits;
            self.windowSize = Params.windowSize;
            self.NFFT = Params.NFFT;
            self.cMap = Params.colorMap;
            self.backgroundColor = Params.backgroundColor;
            self.cMap(1,:) = self.backgroundColor; %set background to black
            self.HostFigure = get_parent_figure(self.AxisHandle);
            self.ImageHandle = gobjects(1);
            self.startNdx = 1;
            self.endNdx = self.nSamp;
            self.frequencyUnits = Params.frequencyUnits;
            if strcmpi(self.frequencyUnits, 'Hz')
                self.freqScaling = 1;
            elseif strcmpi(self.frequencyUnits, 'KHz')
                self.freqScaling = 1 / 1000;
            else
                error('Unrecognized frequency units');
            end
            set(self.AxisHandle, 'UserData', self);
            set(self.AxisHandle, 'ButtonDownFcn', @self.buttondown_updatedspecgram);
            self.ownButtonDown = true;
            self.ChangeButtonDownListener = addlistener(self.AxisHandle, 'ButtonDownFcn', 'PostSet', @self.change_buttondown_cb);
            self.insert_resize_hook();
            self.display_spec();
        end
        function delete(self)
            delete(self.XLimListener);
            try
                if self.ownResize
                    set(self.HostFigure, 'SizeChangedFcn', '');
                end
            catch ME
                if ~strcmp('MATLAB:class:InvalidHandle', ME.identifier)
                    rethrow(ME);
                end
            end
            try
                if self.ownButtonDown
                    self.AxisHandle.ButtonDownFcn = '';
                end
            catch ME
                if ~strcmp('MATLAB:class:InvalidHandle', ME.identifier)
                    rethrow(ME);
                end
            end
            try
                if isequal(self.AxisHandle.UserData, self)
                    self.AxisHandle.UserData = [];
                end
            catch ME
                if ~strcmp('MATLAB:class:InvalidHandle', ME.identifier)
                    rethrow(ME);
                end
            end
        end
        
        function display_spec(self, ~, ~)
            %% Change callbacks to avoid loops?
            delete(self.XLimListener);
            usedToOwnResize = self.ownResize;
            if usedToOwnResize
                set(self.HostFigure, 'SizeChangedFcn', '');%empty resize function to avoid callback loops
            end
            %% Determine axis pixel size
            oldUnits = get(self.AxisHandle, 'Units');
            set(self.AxisHandle, 'Units', 'pixels')
            pixelSize = get(self.AxisHandle, 'Position');
            set(self.AxisHandle, 'Units', oldUnits);
            pixelWidth = pixelSize(3) / self.nCourse; % X extent of spectrogram, in pixels
            
            %% Determine how many fft windows we can display
            thisWindowSize = min(self.windowSize, self.endNdx - self.startNdx);%must be at least as long as the signal
            nDispSamps = self.endNdx - self.startNdx + 1;
            nWindows = nDispSamps / thisWindowSize;
            if nWindows < pixelWidth
                %% If we have more pixels than windows, increase window overlap
                pixelsPerWindow = ceil(pixelWidth / nWindows);
                windowOverlap = min(0.999, 1 - (1 / pixelsPerWindow));
                finalWindowSize = thisWindowSize;
            else
                %% If we have more windows than pixels, increase window size
                finalWindowSize = 2 * floor(nDispSamps / (pixelWidth + 1));
                windowOverlap = 0.5;
            end
            overlapSamples = floor(windowOverlap * finalWindowSize);
            displayedSignal = self.signal(self.startNdx:self.endNdx);
            
            %% Compute the spectrogram
            if size(self.taper, 1) ~= finalWindowSize
                self.taper = hann(finalWindowSize); % Only want the first taper
            end
            [S,F,T] = spectrogram(displayedSignal, self.taper, ...
                overlapSamples, self.NFFT, self.fs);
            
            %% Draw the spectrogram
            oldImgNdx = find(self.ImageHandle == self.AxisHandle.Children, 1, 'first');
            delete(self.ImageHandle); %Get rid of the outdated spectrogram
            holdState = ishold(self.AxisHandle); %Cache existing hold status
            hold(self.AxisHandle, 'on');
            times = T + self.startTime + (self.startNdx - 1) / self.fs;
            freqMask = F >= self.freqRange(1) & F <= self.freqRange(2);
            freqs = self.freqScaling .* F(freqMask);
            powers = 10 * log10(abs(S(freqMask, :)) + 0.02);
            if isempty(self.cLimits)
                self.ImageHandle = imagesc(self.AxisHandle, times, freqs, powers);
            else
                self.ImageHandle = imagesc(self.AxisHandle, times, freqs, powers, self.cLimits);
            end
            if ~holdState %Restore hold state at call
                hold(self.AxisHandle, 'off');
            end
            if numel(times) > 1
                xlim(self.AxisHandle, [times(1), times(end)]);
            else
                xlim(self.AxisHandle, [times(1) - eps, times(end) + eps]);
            end
            ylim(self.AxisHandle, [freqs(1), freqs(end)]);
            axis(self.AxisHandle, 'xy');
            colormap(self.AxisHandle, self.cMap);
            
            set(self.ImageHandle, 'HitTest', 'off'); % Don't block click events
            %% Hopefully re-order the draw stack
            if ~isempty(oldImgNdx)
                newImgIndx = find(self.ImageHandle == self.AxisHandle.Children, 1, 'first');
                tmpChildren = self.AxisHandle.Children;
                oldImg = tmpChildren(oldImgNdx);
                tmpChildren(oldImgNdx) = self.ImageHandle;
                tmpChildren(newImgIndx) = oldImg;
                self.AxisHandle.Children = tmpChildren;
            end
            self.XLimListener = addlistener(self.AxisHandle, 'XLim', 'PostSet', @self.xlim);
            if usedToOwnResize
                self.insert_resize_hook();
            end
        end
        
        function xlim(self, ~, ~)
            xbnds = xlim(self.AxisHandle);
            p1 = xbnds(1);              % extract x and y
            p2 = xbnds(2);
            p1 = min(p1, p2);             % calculate locations
            tryStartNdx = max(floor((p1 - self.startTime) * self.fs) + 1, 1);
            tryEndNdx = min(floor((p2 - self.startTime) * self.fs) + 1, self.nSamp);
            self.set_clip(tryStartNdx, tryEndNdx);
            self.display_spec();
        end
        
        function buttondown_updatedspecgram(self, ~, ~)
            mouseMode = get(self.HostFigure, 'SelectionType');
            clickLocation = get(self.AxisHandle, 'CurrentPoint');
            switch mouseMode
                case 'alt'
                    %% Control click to pan
                    rbbox();
                    endPoint = get(self.AxisHandle, 'CurrentPoint');
                    point1 = clickLocation(1, 1);              % extract x and y
                    point2 = endPoint(1, 1);
                    shiftByTime = point1(1) - point2(1);
                    shiftSamples = floor(shiftByTime * self.fs) + 1;
                    self.set_clip(self.startNdx + shiftSamples, ...
                        self.endNdx + shiftSamples);
                case 'open'
                    %% Double click to zoom out
                    self.startNdx = 1;
                    self.endNdx = self.nSamp;
                case 'extend'
                    %% Shift click to zoom out
                    self.startNdx = 1;
                    self.endNdx = self.nSamp;
                case 'normal'
                    %% Left click to zoom in.
                    rbbox();
                    endPoint = get(gca,'CurrentPoint');
                    point1 = clickLocation(1, 1);              % extract x and y
                    point2 = endPoint(1, 1);
                    p1 = min(point1, point2);             % calculate locations
                    offset = abs(point1 - point2);         % and dimensions
                    clickNdx = floor((p1 - self.startTime) * self.fs) + 1;
                    if offset / diff(xlim(self.AxisHandle)) < .001 %Very small selection
                        quarterWindow = round((self.endNdx - self.startNdx) / 4);
                        self.set_clip(clickNdx - quarterWindow, clickNdx + quarterWindow);
                    else
                        boxSampLen = floor(offset * self.fs);
                        self.set_clip(clickNdx, clickNdx + boxSampLen);
                    end
            end
            self.display_spec([], []);
        end
        
        function change_resize_cb(self, ~, ~)
            self.ownResize = false;
            delete(self.ChangeResizeListener);
        end
        function change_buttondown_cb(self, ~, ~)
            self.ownButtonDown = false;
            delete(self.ChangeButtonDownListener);
        end
    end
    methods (Access = private)
        function insert_resize_hook(self)
            set(self.HostFigure, 'SizeChangedFcn', @self.display_spec);
            self.ownResize = true;
            self.ChangeResizeListener = addlistener(self.HostFigure, 'SizeChangedFcn', 'PostSet', @self.change_resize_cb);
        end
        function set_clip(self, startNdx, endNdx)
            self.startNdx = min(max(startNdx, 1), self.nSamp);
            if endNdx < self.startNdx
                self.endNdx = startNdx;
            else
                self.endNdx = min(max(endNdx, 1), self.nSamp);
            end
        end
    end
end