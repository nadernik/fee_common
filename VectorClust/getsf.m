function f = getsf(vcdb, feat, mask)
% GETSF gets scalar feature values from vcdb
%   f = getsf(vcdb, feat, mask)
%           f = column vector of feature values
%           vcdb = vectorClust database structure
%           feat = feature name or number
%           mask = optional indices to return, defaults to all


% If we are given a feature name, convert it to a feature number
if ischar(feat)
    feat = getsfnum(vcdb, feat);
end

% Lookup feature values by number. Some negative feature numbers have
% special meanings.
switch feat
    case -1 %PrevClusterNum
        f = [nan; vcdb.d.cn(1:end-1)];
        f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
    case -2 %NextClusterNum
        f = [vcdb.d.cn(2:end); nan];
        f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
    case -3 %PrevPrevClusterNum
        f = [nan; nan; vcdb.d.cn(1:end-2)];
        f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
    case -4 %NextNextClusterNum
        f = [vcdb.d.cn(3:end); nan; nan];
        f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
    otherwise
        f = vcdb.d.sf(:, feat);
end

if exist('mask', 'var')
    f = f(mask);
end