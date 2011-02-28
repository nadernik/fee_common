function f = getSFbyName(vcdb, name)
n = mapFeatureName2Number(vcdb.f.sfname, name);
f = getSF(vcdb, n);