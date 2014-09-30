function add_raster_line(axisHandle, rasterTimes, yBase, yHeight, varargin)
%ADD_RASTER_LINE Add a raster line to an existing plot
%   ADD_RASTER_LINE(axisHandle, rasterTimes, yBase, yHeight) adds a raster
%   line to the axes in axisHandle, with lines at x position in vector
%   rasterTimes, starting at y yBase, and extending for extent yHeight.
%
%   ADD_RASTER_LINE(axisHandle, rasterTimes, yBase, yHeight,...) accepts
%   the following named options:
%  'lineWidth': default .5, width of raster lines
%  'lineColors': default [0, 0, 0], color fo raster lines
%  See also: POPULATION_RASTERPLOT_GL

%   Galen Lynch, 8/22/2014
options = struct('lineWidth', .5, 'lineColor', [0,0,0]);
options = gl_parse_args(options, varargin);

assert(ishghandle(axisHandle), 'axesHandle must be a matlab handle');
assert(yBase<=yHeight, 'non sensical height parameters');
holdStatus = ishold(axisHandle);
nPoint = length(rasterTimes);
xx = nan(nPoint*3, 1);
yy = nan(nPoint*3, 1);
xx(1:3:3*nPoint) = rasterTimes;
xx(2:3:3*nPoint) = rasterTimes;
yy(1:3:3*nPoint) = yBase;
yy(2:3:3*nPoint) = yBase+ yHeight;
hold(axisHandle, 'on');
plot(axisHandle, xx, yy, 'color', options.lineColor,...
    'linewidth', options.lineWidth);
if ~holdStatus
   hold(axisHandle, 'off');
end
end