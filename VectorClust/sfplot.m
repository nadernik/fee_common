function h = sfplot(vcdb, sf, varargin)
P.mask = true(size(vcdb.d.t));
P.smoothing = [];
P = parseargs(P, varargin{:});

t = vcdb.d.t(P.mask);
y = getsf(vcdb, sf, P.mask);
if ~isempty(P.smoothing)
    y = smooth(y, P.smoothing);
end
h = plot(t, y);