function y = safeslice(x, ndx)
%SAFESLICE slice array while gracefully handling invalid indices
%
% Usage:
%   Y = SAFESLICE(X, NDX)
%
% Output:
%   Y = X(NDX) except where NDX is invalid. The entries in Y corresponding
%   to invalid incices are NaN. An index is invalid if it is not an integer
%   between 1 and LENGTH(X).
%
% Inputs:
%   X is an array
%   NDX is a list of indices

y = nan(size(ndx));
ok = uint64(ndx) == ndx & 1 <= ndx & ndx <= length(x);
y(ok) = x(ndx(ok));
end