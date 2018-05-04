function s = selectivity_maxovertotal(x)

N = size(x, 1);

s = (max(x) - mean(x)) ./ sum(x) ./ (1 - 1/N);
