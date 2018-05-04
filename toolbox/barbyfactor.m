function barbyfactor(factors, data, varargin)
%HISTBYFACTOR Histograms of data grouped by factors
%   HISTBYFACTOR(F, X, ...)

factor_levels = wrev(unique(factors));

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
    
    avg(ii) = nanmean(data(current));
    sd(ii) = nanstd(data(current));
end

switch nargout
    case 2
        varargout{1} = factor_levels;
        varargout{2} = avg;
    case 3
        varargout{1} = factor_levels;
        varargout{2} = avg;
        varargout{3} = sd;
    otherwise
        x = 1:length(factor_levels);
        bar(x, avg)
        hold on
        errorbar(x, avg, sd, '.')
        hold off
        set(gca, 'XTick', x, 'XTickLabel', legendstr)
end