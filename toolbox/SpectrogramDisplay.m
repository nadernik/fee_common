classdef (Sealed) SpectrogramDisplay < ResizableDisplay
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
        
        freqRange
        startTime
        nCourse
        cLimits
        windowSize
        NFFT
        backgroundColor
        frequencyUnits
    end
    properties (Access = private)
        cMap
        ImageHandle
        taper = [];
        freqScaling
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
                superArgs = {in1};
                signal = in2;
                fs = Params.fs;
            elseif isnumeric(in1)
                superArgs = {gca()};
                signal = in1;
                fs = in2;
                assert(isnumeric(fs), 'fs must be numeric');
            else
                error('Input parsing failed');
            end
            assert(isnumeric(signal) && numel(signal) > 0, 'Signal invalid');
            assert(fs > 0, 'fs must be specified');
            self@ResizableDisplay(superArgs{:});
            self.signal = signal;
            self.nSamp = numel(self.signal);
            self.endNdx = self.nSamp;
            self.fs = fs;
            self.freqRange = Params.freqRange;
            self.startTime = Params.startTime;
            self.nCourse = Params.nCourse;
            self.cLimits = Params.cLimits;
            self.windowSize = Params.windowSize;
            self.NFFT = Params.NFFT;
            self.cMap = Params.colorMap;
            self.backgroundColor = Params.backgroundColor;
            self.cMap(1,:) = self.backgroundColor; %set background to black
            self.ImageHandle = gobjects(1);
            
            self.frequencyUnits = Params.frequencyUnits;
            if strcmpi(self.frequencyUnits, 'Hz')
                self.freqScaling = 1;
            elseif strcmpi(self.frequencyUnits, 'KHz')
                self.freqScaling = 1 / 1000;
            else
                error('Unrecognized frequency units');
            end
            self.update_display();
        end
        
        function update_display(self, ~, ~)
            %% Determine axis pixel size
            pixelWidth = self.pixel_width(); % X extent of spectrogram, in pixels
            
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
                if verLessThan('matlab', '9.0')
                    self.ImageHandle = imagesc(times, freqs, powers, 'Parent', self.AxisHandle);
                else
                    self.ImageHandle = imagesc(self.AxisHandle, times, freqs, powers);
                end
            else
                if verLessThan('matlab', '9.0')
                    self.ImageHandle = imagesc(times, freqs, powers, self.cLimits, 'Parent', self.AxisHandle);
                else
                    self.ImageHandle = imagesc(self.AxisHandle, times, freqs, powers, self.cLimits);
                end
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
        end
        
        function ndx = x_to_ndx(self, x)
            ndx = floor((x - self.startTime) * self.fs) + 1;
        end
    end
end