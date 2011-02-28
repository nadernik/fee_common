function f = getVFbyName(vcdb, name)
n = mapFeatureName2Number(vcdb.f.vfname, name);
if isempty(n) && strcmp(name, 'v')
    % If we are looking for a feature called 'v' and cannot find it, they
    % must be looking for the raw signal
    f = vcdb.d.v;
else
    f = getVF(vcdb, n);
end