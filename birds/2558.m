%% 2011-10-19
vectorClust
vcQuickCluster('2558', '2011-10-18', 'c:\stetner\data\2558\polygons 2011-10-18.mat', [])
% 1 = escapes
labeledspecgram('2558', '2011-10-18')
rules
% pushing up

%% 2011-10-20
vectorClust
vcQuickCluster('2558', '2011-10-19', 'c:\stetner\data\2558\polygons 2011-10-19.mat', [])
cafplots('2558', '2011-10-19', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.055 .057], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\2558\2011-10-19\cafplots_vcdb.mat')
% no learning; only getting hit about 15% of the time
rules