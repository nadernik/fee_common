function varargout = stdbyfactor(Y, F)
%SEMBYFACTOR Standard error of the mean calculated by factors
%   

levels = unique(F);

if iscellstr(F)
    eqfcn = @strcmp;
else
    eqfcn = @eq;
end

for ii = 1:length(levels)
    ndx = eqfcn(levels(ii), F);
    m(ii) = mean(Y(ndx));
    s(ii) = std(Y(ndx));
end

switch nargout
    case 0
        plothelper(levels, m, s, '.');
    case 1
        h = plothelper(levels, m, s, '.');
        varargout{1} = h;
    case 2
        varargout{1} = levels;
        varargout{2} = s;
end

function h = plothelper(x, y, b, varargin)
if isnumeric(x)
    h = errorbar(x, y, b, varargin{:});
else
    h = errorbar(1:length(x), y, b, varargin{:});
    set(gca, 'XTick', 1:length(x), 'XTickLabel', x)
end
    