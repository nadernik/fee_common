function y = sem(x)
%SEM Standard error of the mean

assert(isvector(x))

y = std(x) / sqrt(length(x));