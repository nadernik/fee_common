function cs = num2cellstr(n)
%NUM2CELLSTR Convert numbers to a cell array of strings
%   cs = NUM2CELLSTR(n) converts numerical matrix n into a cell array of
%   strings that is the same size as n. Each element in n becomes one cell
%   in the cell array.

cs = arrayfun(@num2str, n, 'UniformOutput', 0);
