%% 2011-09-21
annotate_exper('2523', '2011-09-20','edgeSyllThreshold', -9, 'triggerSyllThreshold', -6)
vectorClust
% made clusters (1=escape) and exported for pt 3 only
rules
% Can't load rules because "Unable to write to buffer rawCoef4."
% I don't want to stop the TDT to reload the circuit because 2492 has
% already started singing and it is important that I get good data from
% him.

%% 2011-09-22
annotate_exper('2523', '2011-09-21','edgeSyllThreshold', -9, 'triggerSyllThreshold', -6, 'filenum', 600:886)
vcQuickCluster('2523', '2011-09-21', 'c:\stetner\data\2523\polygons 2011-09-20.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2523', '2011-09-21')

%% 2011-09-24
annotate_exper('2523', '2011-09-23','edgeSyllThreshold', -9, 'triggerSyllThreshold', -6)
vectorClust
% Cluster 2 escapes
% Cluster 3 hits
vcQuickCluster('2523', '2011-09-23', 'c:\stetner\data\2523\polygons 2011-09-23.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2523', '2011-09-23')
cafplots('2523', '2011-09-23', ...
    'HitCluster', 3, ...
    'EscapeCluster', 2, ...
    'Range', [.092 .094], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2523\2011-09-23\cafplots_vcdb.mat')
% was pushing up but did not learn
% adjust filters to increase hits slightly, and try again tonight

%% 2011-09-25
annotate_exper('2523', '2011-09-24','edgeSyllThreshold', -9, 'triggerSyllThreshold', -6)
vcQuickCluster('2523', '2011-09-24', 'c:\stetner\data\2523\polygons 2011-09-23.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2523', '2011-09-24')
cafplots('2523', '2011-09-24', ...
    'HitCluster', 3, ...
    'EscapeCluster', 2, ...
    'Range', [.092 .094], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2523\2011-09-24\cafplots_vcdb.mat')
% Not sure what is going on. Push one more day then give up
rules

%% 2011-09-28
% I was busy so I have not analyzed learning for the past few days.
annotate_exper('2523', '2011-09-26','edgeSyllThreshold', -9, 'triggerSyllThreshold', -6)
% This exper contains singing from the past 2 days
vcQuickCluster('2523', '2011-09-25', 'c:\stetner\data\2523\polygons 2011-09-23.mat', [], 'root', 'c:\stetner\data')
vcQuickCluster('2523', '2011-09-26', 'c:\stetner\data\2523\polygons 2011-09-23.mat', [], 'root', 'c:\stetner\data')

%% 2011-09-29
cafplots('2523', '2011-09-25', ...
    'HitCluster', 3, ...
    'EscapeCluster', 2, ...
    'Range', [.092 .094], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2523\2011-09-25\cafplots_vcdb.mat')
% he is just not learning. abandon him.