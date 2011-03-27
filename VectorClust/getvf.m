function f = getvf(vcdb, feat, mask)

if ischar(feat)
    feat = getvfnum(vcdb, feat);
end

if isempty(feat)
    f = [];
elseif feat == 0
    f = vcdb.d.v;
else
    f = vcdb.d.vf{feat};
end
if exist('mask', 'var') && ~isempty(mask)
    f = f(mask);
end