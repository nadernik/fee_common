function f = getVF(vcdb, n)
if n == 0
    f = vcdb.d.v;
else
    f = vcdb.d.vf{n};
end