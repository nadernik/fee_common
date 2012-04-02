function y = stresc(x, varargin)
%STRESC escapes a string by prefixing backslash to backslash and underscore
%
%   Y = STRESC(X)
%       Replace all '\' and '_' in X with '\\' and '\_'.
%
%   Y = STRESC( ... 'backslash', 0)
%       Do not escape backslashes.
%
%   Y = STRESC( ... 'underscore', 0)
%       Do not escape underscores.

do.backslash = 1;
do.underscore = 1;
do = parseargs(do, varargin{:});

if do.backslash
    y = strrep(x, '\', '\\');
end

if do.underscore
    y = strrep(y, '_', '\_');
end
