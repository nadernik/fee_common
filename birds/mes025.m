%% 2011-04-20

annotate_exper('mes025', '2011-04-20', 'filenum', 1:91, ... 
    'triggerSyllThreshold', -5, 'edgeSyllThreshold', -10)

vectorClust
% Cluster 1 = escapes

rules

%% 2011-04-21

annotate_exper('mes025', '2011-04-20', 'triggerSyllThreshold', -5, 'edgeSyllThreshold', -10)

% New clusters to include hits (2=hits)
vectorClust
vcQuickCluster('mes025', '2011-04-20', 'polygons20110421.mat', [], 'root', 'c:\stetner\data')

cafplots('mes025', '2011-04-20', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.103 .108], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\mes025\2011-04-20\cafplots_vcdb.mat')
% great filters, no learning. continue with same filters another day.