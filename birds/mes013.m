%% 2011-03-10

annotate_exper('mes013', '2011-03-10', 'edgeSyllThreshold',-9.5,'triggerSyllThreshold',-8, 'filenum', 200:445)
% clustered in vectorClust (1=escapes)
% started caf for first time after file 445

%% 2011-03-11

% New polgyons (1=escapes, 2=hits)
vcQuickCluster('mes013', '2011-03-10', 'polygons20110311.mat', [], 'root', 'c:\stetner\data')
cafplots('mes013', '2011-03-10', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [0.03 0.035], ...
    'RangeUnits', 'seconds')
% No learning yet, but fitlers seem to be accurate. Continue one more day
% as is.

%% 2011-03-13
vcQuickCluster('mes013', '2011-03-11', 'polygons20110311.mat', 2, 'root', 'c:\stetner\data')
cafplots('mes013', '2011-03-11', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [0.03 0.035], ...
    'RangeUnits', 'seconds', ...
    'SaveVcdb', 'vcdb2011-03-11.mat')
% crappy segmentation especially on cluster 2 (hits). 

% make new filters with today's singing
annotate_exper('mes013', '2011-03-13', 'edgeSyllThreshold',-9.5,'triggerSyllThreshold',-6, 'filenum', 700:782)

%% 2011-03-14

vcQuickCluster('mes013', '2011-03-13', 'polygons20110311.mat', 1, 'root', 'c:\stetner\data')
