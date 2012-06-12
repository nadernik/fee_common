function setticklimy(varargin)

switch nargin
    case 1
        axh = gca;
        newlims = varargin{1};
    case 2
        axh = varargin{1};
        newlims = varargin{2};
end

set(axh, 'YLim', newlims, 'YTick', newlims)