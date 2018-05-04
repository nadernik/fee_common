function varargout = mini_max_plot(times, data, varargin)
%MINI_MAX_PLOT Min-max decimation and plotting
%
%Usage: 
%   mini_max_plot(times, data)
%   mini_max_plot(times, data, 'ax', axes_handle)
%Arguments:
%   time is the vector of time points corresponding to the data
%   data is the vector to be decimated and plotted
%   axes_handle is a handle to the axes to plot on. If omitted, the curret
%       axes are used.
%
% The amount of decimation is automatically chosen based on the size of the
% figure window. 

assert(isvector(data), 'MINI_MAX_PLOT only handles vector inputs atm');
assert(isvector(times), 'MINI_MAX_PLOT only handles vector inputs atm');
times = reshape(times, [], 1);
data = reshape(data, [], 1);
%% Handling arguments to MINI_MAX_PLOT
options = struct('ax', nan);
options = gl_parse_args(options, varargin);

if isnan(options.ax)
    options.ax = gca();
end

assert(length(times) == length(data), 'x and y data points unequal length');
ud.times = times;
ud.data = data;
ud.ax = options.ax;
ud.startndx = 1;
ud.endndx = length(data);
ud.startTime = times(1);
ud.Fs = 1/(times(2)-times(1));
hFig = get_parent_figure(ud.ax);
rszFcn = get(hFig, 'ResizeFcn');
function helper_resize(hObject, event) 
        helper_mini_max_plot(get(ud.ax, 'UserData'));
        if ~isempty(rszFcn)
            rszFcn(hObject, event);
        end
end
set(gcf, 'ResizeFcn', @helper_resize)
helper_mini_max_plot(ud)
if nargout > 0
    varargout = {ud.ax};
end
end


function helper_mini_max_plot(ud)
%determine size of axis relative to size of the signal,
%use this to adapt the window overlap and downsampling of the signal.
%no need to worry about size of fftwindow, this doesn't effect speed.
%keyboard;
set(ud.ax,'Units','pixels')
pixSize = get(ud.ax,'Position');
numPixels = pixSize(3);
numPoints = length(ud.data(ud.startndx:ud.endndx));
cla(ud.ax);
ratio = numPoints/numPixels;
if(ratio < 5)
    %If we do not need to downsample
    p = plot(ud.ax, ud.times(ud.startndx:ud.endndx), ud.data(ud.startndx:ud.endndx));
else
    %If we have more ffts then pixels, then we can do things, we can
    %downsample the signal, or we can skip signal between ffts.
    %Skipping signal mean we may miss bits of song altogether.
    %Decimating throws away high frequency information.
    windowSize = ceil(numPoints/numPixels);
    numWindows = ceil(numPoints/windowSize);
    paddedData = [ud.data(ud.startndx:ud.endndx); nan(windowSize*numWindows-numPoints,1)];
    paddedTimes = [ud.times(ud.startndx:ud.endndx);nan(windowSize*numWindows-numPoints,1)];
    reshapedData = reshape(paddedData, windowSize, numWindows);
    reshapedTimes = reshape(paddedTimes, windowSize, numWindows);
    timeCenters = nanmean(reshapedTimes)';
    %Patch method
%     timeCenters = [timeCenters; flipud(timeCenters)];
%     minimaxData  = [max(reshapedData)'; flipud(min(reshapedData)')];
%     axes(ud.ax);
%     p = patch(timeCenters, minimaxData, 'b', 'edgecolor', 'none');
    %jaggy line method
    timeCenters = repmat(timeCenters, 1,2)';
    timeCenters = reshape(timeCenters, [], 1);
    minimaxData  = [max(reshapedData); min(reshapedData)];
    minimaxData = reshape(minimaxData, [], 1);
    p = plot(ud.ax, timeCenters, minimaxData);
    %top bottom plot
%     timeCenters = repmat(timeCenters, 1,2)';
%     timeCenters = reshape(timeCenters, [], 1);
%     minimaxData  = [max(reshapedData)'; flipud(min(reshapedData)')];
%     axes(ud.ax);
%     p = plot(ud.ax, timeCenters, minimaxData);
end
axis xy; axis tight;
set(p,'HitTest', 'off');

set(ud.ax,'Units','normalized')
set(ud.ax, 'UserData', ud);
set(ud.ax, 'ButtonDownFcn', @buttondown_minimaxplot);
end

function buttondown_minimaxplot(src, evnt)
ud = get(src, 'UserData');
axes(ud.ax);
mouseMode = get(gcf, 'SelectionType');
clickLocation = get(ud.ax, 'CurrentPoint');
%keyboard
if(strcmp(mouseMode, 'alt'))
    %control click
    rect = rbbox;
    endPoint = get(gca,'CurrentPoint'); 
    point1 = clickLocation(1,1:2);              % extract x and y
    point2 = endPoint(1,1:2);
    shiftTime = point1(1) - point2(1);
    shiftNdx = round((shiftTime * ud.Fs) + 1);
    shiftNdx = shiftNdx - max(0, ud.endndx + shiftNdx - length(ud.data));
    shiftNdx = shiftNdx - min(0, ud.startndx + shiftNdx -1);
    ud.startndx = ud.startndx + shiftNdx;
    ud.endndx = ud.endndx + shiftNdx;
elseif(strcmp(mouseMode, 'open'))
    %double click to zoom out
    ud.startndx = 1;
    ud.endndx = length(ud.data);
elseif(strcmp(mouseMode, 'normal'))
    %left click to zoom in.
    rect = rbbox;
    endPoint = get(gca,'CurrentPoint'); 
    point1 = clickLocation(1,1:2);              % extract x and y
    point2 = endPoint(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);         % and dimensions
    if(offset(1)/diff(xlim) < .001)
        quarter = round((ud.endndx - ud.startndx) / 4);
        midndx = round((p1(1) - ud.startTime)*ud.Fs + 1);
        ud.startndx = max(1,midndx - quarter);
        ud.endndx = min(length(ud.data), midndx + quarter);
    else
        ud.startndx = max(round((p1(1) - ud.startTime)*ud.Fs + 1),1);
        ud.endndx = min(round((p1(1) + offset(1) - ud.startTime)*ud.Fs + 1),length(ud.data));
    end
end
set(ud.ax,'UserData',ud);
helper_mini_max_plot(ud);
end