function vcdb = vc_feat_sfdiff(vcdb, feat1, feat2, varargin)
P.name = [feat1 '-' feat2];
P.offset = [0 0];
P = parseargs(P, varargin{:});

f1 = getSFbyName(vcdb, feat1);
f2 = getSFbyName(vcdb, feat2);
f1 = safesub(f1, 1+offset(1), sprintf('end+%g', offset(1)));
f2 = safesub(f2, 1+offset(2), sprintf('end+%g', offset(2)));

vcdb.d.sf(:,n) = f1 - f2;
vcdb.f.sfname{n} = P.name;
vcdb.f.sffcn{n} = mfilename;
vcdb.f.sfparam{n} = {feat1, feat2, varargin{:}};

function y = safesub(x, n1, n2)
% x is a column vector
if ischar(n1) 
    n1 = eval(strrep(n1, 'end', 'length(x)'));
end
if ischar(n2) 
    n1 = eval(strrep(n1, 'end', 'length(x)'));
end
if n2 < n1
    temp = n1;
    n1 = n2;
    n2 = temp;
end
prenans = nan(1-n1, 1);% this works because nan(-a, 1) gives empty matrix for all a >= 0
postnans = nan(n2 - length(x), 1); 
y = [prenans; x(max(1, n1):min(length(x), n2)); postnans];