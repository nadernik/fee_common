function m = modnonzero(x, y)

m = mod(x, y);
if isscalar(y)
    m(m == 0) = y;
else
    m(m == 0) = y(m == 0);
end