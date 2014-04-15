function varargout = fwhm(varargin)
%FWHM Full Width at Half Maximum
%   width = fwhm(y)
%   width = fwhm(x, y)
%   [width, xw] = fwhm(x, y)

DEBUG_FLAG = 0;

switch nargin
    case 1
        y = varargin{1};
        x = 1:length(y);
    case 2
        x = varargin{1};
        y = varargin{2};
        assert(length(x) == length(y))
    otherwise
        error('Wrong number of arguments')
end


% Divide y into two, splitting at the maximum. note that maximum is in both
[ymax, imax] = max(y);
x1 = x(1:imax);
y1 = y(1:imax);
x2 = x(imax:end);
y2 = y(imax:end);


% Abort if there is more than one maximum?

% Interpolate to find x at half maximum on the way up
xw(1) = interp1(y1, x1, ymax/2);
% Repeat to find x at half maximum on the way down
xw(2) = interp1(y2, x2, ymax/2);

width = diff(xw);

switch nargout
    case 1
        varargout{1} = width;
    case 2
        varargout{1} = width;
        varargout{2} = xw;
end

if DEBUG_FLAG
    figure
    plot(x,y)
    hold on
    h = line(xw, ymax/2*[1,1]);
    set(h, 'LineStyle', '--')
end