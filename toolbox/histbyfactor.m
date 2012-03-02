function histbyfactor(factors, data, varargin)
%HISTBYFACTOR Histograms of data grouped by factors
%   HISTBYFACTOR(F, X, ...)

factor_levels = unique(factors);

for ii = 1:length(factor_levels)
    
    % Choose only data that has the current factor level
    if iscellstr(factors)
        current = strcmp(factors, factor_levels{ii});
        legendstr{ii} = factor_levels{ii};
    elseif ischar(factors)
        current = factors == factor_levels(ii);
        legendstr{ii} = factor_levels(ii);
    elseif isnumeric(factors)
        current = factors == factor_levels(ii);
        legendstr{ii} = num2str(ii);
    end
    
    [counts(:,ii), bins(:,ii)] = hist(data(current), varargin{:});
end

switch nargout
    case 2
        varargout{1} = factor_levels;
        varargout{2} = counts;
    case 3
        varargout{1} = factor_levels;
        varargout{2} = counts;
        varargout{3} = bins;
    otherwise
        stairs(bins, counts)
        legend(legendstr)
end