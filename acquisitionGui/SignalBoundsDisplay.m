classdef (Sealed) SignalBoundsDisplay < ResizableDisplay
    properties (SetAccess = private)
        signal
        startTime
        fs
    end
    methods
        function self = SignalBoundsDisplay(in1, in2, varargin)
            %SignalBoundsDisplay make display object
            %   SignalBoundsDisplay(X, Y) plots in current axis
            %   SignalBoundsDisplay(ax, X, Y) specify axis
            %   SignalBoundsDisplay(..., ParamName, ParamValue) parameters
            persistent p;
            if isempty(p)
                p = inputParser();
                addOptional(p, 'fs', 0, @isnumeric);
                addParameter(p, 'startTime', 0);
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
            assert(isnumeric(signal) && ~isempty(signal), 'Signal invalid');
            assert(isnumeric(fs) && fs > 0, 'fs invalid');
            self@ResizableDisplay(superArgs{:});
            if size(signal, 2) > 1
                 self.signal = signal.';
            else
                self.signal = signal;
            end
            self.fs = fs;
            self.startTime = params.startTime;
            self.nSamp = numel(self.signal);
            self.endNdx = self.nSamp;
            self.update_display();
        end
        
        function update_display(self, ~, ~)
            %% Determine axis pixel size
            pixelWidth = self.pixel_width(); % X extent of axis, in pixels
            
            nDispSamps = self.endNdx - self.startNdx + 1;
            displayedSig = self.signal(self.startNdx:self.endNdx);
            
            pointsPerPixel = nDispSamps / pixelWidth;
            cla(self.AxisHandle);
            if pointsPerPixel < 4
                %% Plot without down sampling
                displayedX = self.startTime + ((self.startNdx - 1):(self.endNdx -1)) ./ self.fs;
                PlotHandle = plot(self.AxisHandle, displayedX, displayedSig);
                PlotHandle.HitTest = 'Off';
            else
                %% Calculate maximum and minimum
                pointsPerBin = ceil(nDispSamps / pixelWidth);
                nBins = ceil(nDispSamps / pointsPerBin);
                nPad = mod(-nDispSamps, pointsPerBin);
                paddedSig = vertcat(displayedSig, nan(nPad, 1));
                binnedSig = reshape(paddedSig, pointsPerBin, nBins);
                binCenterSamp = (pointsPerBin - 1) / 2;
                firstBinX = self.startTime + (self.startNdx + binCenterSamp - 1) / self.fs;
                binX = firstBinX  + pointsPerBin * (0:(nBins - 1)) / self.fs;
                minY = nanmin(binnedSig);
                maxY = nanmax(binnedSig);
                
                %% Plotting
                hold(self.AxisHandle, 'on');
                MinPlot = plot(self.AxisHandle, binX, minY);
                MaxPlot = plot(self.AxisHandle, binX, maxY);
                MinPlot.HitTest = 'Off';
                MaxPlot.HitTest = 'Off';
                hold(self.AxisHandle, 'off');
            end
        end
        
        function ndx = x_to_ndx(self, x)
            ndx = floor((x - self.startTime) * self.fs) + 1;
        end
    end
end