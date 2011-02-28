function h = scatter_sf_over_time(vcdb, sfname, varargin)
P.mask = true(size(vcdb.d.v));
P = parseargs(P, varargin{:});

sf = mapFeatureName2Number(vcdb.f.sfname, sfname);
t = vcdb.d.t(P.mask);
y = vcdb.d.sf(P.mask, sf);
h = scatter(t, y);