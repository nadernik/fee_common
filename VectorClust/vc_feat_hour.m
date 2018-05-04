function vcdb = vc_feat_hour(vcdb, varargin)
P.timesf = '';
P.name = 'hour';
P = parseargs(P, varargin{:});

if isempty(P.timesf)
    t = vcdb.d.t;
else
    t = getSFbyName(vcdb, P.timesf);
end

n = size(vcdb.d.sf, 2) + 1;

vcdb.d.sf(:,n) = floor(t) .* 24;
vcdb.f.sfname{n} = P.name;
vcdb.f.sffcn{n} = mfilename;
vcdb.f.sfparam{n} = {varargin{:}};