function plotbyfactor(X, Y, F, domean)
% factor should be discrete!
assert(isvector(F))

c = get(gca, 'ColorOrder');
hold on
Fvals = unique(F);
for nf = 1:length(Fvals)
    if ischar(F)
        cols = strcmp(F, Fvals);
    else
        cols = F == Fvals(nf);
    end
    
    if ~isempty(domean) && domean
        yy = mean(Y(:,cols), 2);
    else
        yy = Y(:,cols);
    end
    h{nf} = plot(X(:,cols), yy, 'Color', c(nf,:));
    legend_handles(nf) = h{nf}(1);
end

if iscellstr(Fvals)
    legend(legend_handles, Fvals)
elseif isnumeric(Fvals)
    legend(legend_handles, num2cellstr(Fvals))
else
    warning('Cannot display legend because F is not numeric nor a cell array of strings.')
end
end