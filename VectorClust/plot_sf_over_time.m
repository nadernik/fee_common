function h = plot_sf_over_time(vcdb, sf, varargin)
P.mask = true(size(vcdb.d.t));
P.smoothing = [];
P = parseargs(P, varargin{:});

sf = mapFeatureName2Number(vcdb.f.sfname, sfname);
t = vcdb.d.t(P.mask);
y = vcdb.d.sf(P.mask, sf);
if ~isempty(P.smoothing)
    y = smooth(y, P.smoothing);
end
h = plot(t, y);