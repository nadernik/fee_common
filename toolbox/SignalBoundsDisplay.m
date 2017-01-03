classdef (Sealed) SignalBoundsDisplay < ResizableDisplay
    properties (SetAccess = private)
        signal
        startTime
        fs
    end
    properties (Access = private)
        timeCourse
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
                signal = in2; %#ok<*PROP>
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
            self.startTime = Params.startTime;
            self.nSamp = numel(self.signal);
            self.endNdx = self.nSamp;
            self.timeCourse = self.startTime + (0:(self.nSamp - 1)) ./ self.fs;
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
                PlotHandle = plot(self.AxisHandle, ...
                    self.timeCourse(self.startNdx:self.endNdx), displayedSig);
                PlotHandle.HitTest = 'Off';
            else
                %% Calculate maximum and minimum
                pointsPerBin = ceil(nDispSamps / pixelWidth);
                nBins = ceil(nDispSamps / pointsPerBin);
                nPad = mod(-nDispSamps, pointsPerBin);
                paddedSig = vertcat(displayedSig, nan(nPad, 1));
                binnedSig = reshape(paddedSig, pointsPerBin, nBins);
                binCenterSamp = (pointsPerBin - 1) / 2;
                firstBinTime = self.timeCourse(1) + binCenterSamp / self.fs;
                binTime = firstBinTime  + pointsPerBin * (0:(nBins - 1)) / self.fs;
                minSig = nanmin(binnedSig);
                maxSig = nanmax(binnedSig);
                
                %% Plotting
                hold(self.AxisHandle, 'all');
                MinPlot = plot(self.AxisHandle, binTime, minSig);
                MaxPlot = plot(self.AxisHandle, binTime, maxSig, 'Color', MinPlot.Color);
                MinPlot.HitTest = 'Off';
                MaxPlot.HitTest = 'Off';
                hold(self.AxisHandle, 'off');
                xlim(self.AxisHandle, [binTime(1), binTime(end)]);
            end
        end
        
        function ndx = x_to_ndx(self, x)
            ndx = floor((x - self.startTime) * self.fs) + 1;
        end
    end
end