function m = globalmax(x)
if isvector(x)
    m = max(x);
else
    m = globalmax(max(x));
end