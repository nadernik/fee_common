function h = sfscatter(vcdb, sfname, varargin)
P.mask = true(size(vcdb.d.v));
P = parseargs(P, varargin{:});

t = vcdb.d.t(P.mask);
y = getsf(vcdb, sfname, P.mask);
h = scatter(t, y);