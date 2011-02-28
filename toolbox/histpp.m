function varargout = histpp(varargin)
% Better version of hist that lets you set Patch Properties

[histargs, patchargs] = parseargs(varargin{:});

[n, xout] = hist(histargs{:});

% edges of patches are the midpoints between centers of bins
xedge = mean([xout(1:end-1); xout(2:end)]);
% make first and last bins symmetrical about their centers
firstedge = xedge(1) - (xedge(2) - xedge(1)); 
lastedge = xedge(end) + (xedge(end) - xedge(end-1));
xedge = [firstedge xedge lastedge];

xL = xedge(1:end-1); % left edges (row vector)
xR = xedge(2:end); % right edges (row vector)
X = [xL; xL; xR; xR];
ymin = zeros(size(n)); % bottom edges (row vector)
ymax = n;% top edges are n from hist (row vector)
Y = [ymin; ymax; ymax; ymin];
C = zeros(size(n));

h = patch(X, Y, C, patchargs{:});

switch nargout
    case 1
        varargout = {h};
    case 2
        varargout = {n, xout};
    case 3
        varargout = {n, xout, h};
end

function [histargs, patchargs] = parseargs(varargin)
for n = (length(varargin)-1):-2:1
    if ~ischar(varargin{n})
        break
    end
end
histargs = varargin(1:(n-1));
patchargs = varargin(n:end);