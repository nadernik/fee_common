function sfhist(vcdb, sfname, varargin)
P.BinWidth = [];
P.PatchProperties = [];
P.Mask = true(size(vcdb.d.v));
P = parseargs(P, varargin{:});
if isempty(P.PatchProperties)
    P.PatchProperties = {}; % because parseargs does not allow empty cell arrays
end
y = getsf(vcdb, sfname, P.Mask);
if ~isempty(P.BinWidth)
    x = min(y - P.BinWidth):P.BinWidth:max(y + P.BinWidth);
    histpp(y, x, P.PatchProperties{:})
else
    histpp(y, P.PatchProperties{:})
end