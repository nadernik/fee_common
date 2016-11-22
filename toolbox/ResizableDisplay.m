classdef (Abstract) ResizableDisplay < handle
    properties (SetAccess = protected)
        AxisHandle
        startNdx = 1;
        endNdx
        nSamp = -1;
    end
    properties (Access = protected)
        HostFigure
        XLimListener
        ownResize
        ownButtonDown
        ChangeResizeListener
        ChangeButtonDownListener
    end
    methods (Abstract)
        update_display(self, ~, ~)
        ndx = x_to_ndx(self, x)
    end
    methods
        function self = ResizableDisplay(varargin)
            %SPECTROGRAMDISPLAY make display object
            %   SPECTROGRAMDISPLAY(signal, fs) plots in current axis
            %   SPECTROGRAMDISPLAY(ax, signal, fs) specify axis
            %   SPECTROGRAMDISPLAY(..., ParamName, ParamValue) parameters
            persistent p;
            if isempty(p)
                p = inputParser();
                addOptional(p, 'AxisHandle', gobjects(1), @(x) isa(x, 'matlab.graphics.Graphics'));
            end
            parse(p, varargin{:});
            Params = p.Results;
            self.endNdx = self.nSamp;
            if ~isgraphics(Params.AxisHandle)
                self.AxisHandle = gca();
            else
                self.AxisHandle = Params.AxisHandle;
            end
            self.HostFigure = get_parent_figure(self.AxisHandle);
            self.ownButtonDown = true;
            set(self.AxisHandle, 'UserData', self);
            set(self.AxisHandle, 'ButtonDownFcn', @self.buttondown);
            self.ChangeButtonDownListener = addlistener(self.AxisHandle, 'ButtonDownFcn', 'PostSet', @self.change_buttondown_cb);
            self.insert_resize_hook();
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
        
        function display_helper(self, ~, ~)
            %% Change callbacks to avoid loops?
            delete(self.XLimListener);
            usedToOwnResize = self.ownResize;
            if usedToOwnResize
                set(self.HostFigure, 'SizeChangedFcn', '');%empty resize function to avoid callback loops
            end
            self.update_display();
            self.XLimListener = addlistener(self.AxisHandle, 'XLim', 'PostSet', @self.xlim);
            if usedToOwnResize
                self.insert_resize_hook();
            end
        end
        
        function xlim(self, ~, ~)
            xBnds = xlim(self.AxisHandle);
            tryStartNdx = self.x_to_ndx(xBnds(1));
            tryEndNdx = self.x_to_ndx(xBnds(2));
            self.set_clip(tryStartNdx, tryEndNdx);
            self.display_helper();
        end
        
        function buttondown(self, ~, ~)
            mouseMode = get(self.HostFigure, 'SelectionType');
            clickLocation = get(self.AxisHandle, 'CurrentPoint');
            if strcmp(mouseMode, 'open') || strcmp(mouseMode, 'extend')
                %% Double click or shift click to zoom out
                self.startNdx = 1;
                self.endNdx = self.nSamp;
                self.display_helper();
                return
            end
            rbbox();
            releaseLocation = get(self.AxisHandle, 'CurrentPoint');
            startPoint = clickLocation(1, 1);
            endPoint = releaseLocation(1, 1);
            point1 = self.x_to_ndx(startPoint);              % extract x and y
            point2 = self.x_to_ndx(endPoint);
            if strcmp(mouseMode, 'alt')
                %% Control click to pan
                shiftSamples = point1 - point2;
                self.set_clip(self.startNdx + shiftSamples, ...
                    self.endNdx + shiftSamples);
            elseif strcmp(mouseMode, 'normal')
                %% Left click to zoom in.
                clickNdx = min(point1, point2);
                boxWidth = abs(point1 - point2);
                xBnds = xlim(self.AxisHandle);
                windowWidth = self.x_to_ndx(xBnds(2)) - self.x_to_ndx(xBnds(1));
                if boxWidth / windowWidth < .001 %Very small selection
                    quarterWindow = round((self.endNdx - self.startNdx) / 4);
                    self.set_clip(clickNdx - quarterWindow, clickNdx + quarterWindow);
                else
                    self.set_clip(clickNdx, clickNdx + boxWidth);
                end
            end
            self.display_helper();
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
    
    methods (Access = protected)
        function pixelWidth = pixel_width(self)
            %% Determine axis pixel size
            oldUnits = get(self.AxisHandle, 'Units');
            set(self.AxisHandle, 'Units', 'pixels')
            pixelSize = get(self.AxisHandle, 'Position');
            set(self.AxisHandle, 'Units', oldUnits);
            pixelWidth = pixelSize(3); % X extent of spectrogram, in pixels
        end
    end
    methods (Access = private)
        function insert_resize_hook(self)
            set(self.HostFigure, 'SizeChangedFcn', @self.display_helper);
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