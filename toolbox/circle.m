function circle(varargin)
%CIRCLE Create circle
%   CIRCLE adds a default circle to the current axes.
%   CIRCLE('Center', [x y], 'Diameter', d, ...)
%   Other properties are the same as for rectangle function
%   Calls rectangle with Curvature of [1 1].

circle_arg_ndx = [];

diameter_ndx = find(strcmpi(varargin, 'Diameter') & mod(1:nargin,2), 1) + 1;
if isempty(diameter_ndx)
    d = 1;
else
    d = varargin{diameter_ndx};
    circle_arg_ndx = [circle_arg_ndx, diameter_ndx-1, diameter_ndx];
end

center_ndx = find(strcmpi(varargin, 'Center') & mod(1:nargin,2), 1) + 1;
if isempty(center_ndx)
    c = [0 0];
else
    c = varargin{center_ndx};
    circle_arg_ndx = [circle_arg_ndx, center_ndx-1, center_ndx];
end

x = c(1) - d/2;
y = c(2) - d/2;
w = d;
h = d;

rectangle_arg_ndx = setdiff(1:nargin, circle_arg_ndx);
rectangle_args = varargin(rectangle_arg_ndx);
rectangle('Position', [x y w h], 'Curvature', [1 1], rectangle_args{:})
