function hist_sf(vcdb, sfname, varargin)
P.mask = true(size(vcdb.d.sf, 1), 1);
P.bin_width = [];
P.patchargs = {};
P.mask = true(size(vcdb.d.v));
P = parseargs(P, varargin{:});

sf = mapFeatureName2Number(vcdb.f.sfname, sfname);
y = vcdb.d.sf(P.mask, sf);
if ~isempty(P.bin_width)
    x = min(y - P.bin_width):bin_width:max(y + P.bin_width);
    histpp(y, x, P.patchargs{:})
else
    histpp(y, P.patchargs{:})
end