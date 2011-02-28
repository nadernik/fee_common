%% 2011-02-27
annotate_exper('mes010', '2011-02-26', ...
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02)
deglitch_all_pitch('mes010', '2011-02-26')
vcQuickCluster('mes010', '2011-02-26', 'polygons20110227.mat', [], 'root','c:\stetner\data\')

% Made two sets of rules. One targets cluster 1 which is short,
% high-pitched, and has lower pitch goodness. The other targets cluster 2
% which is the opposite. Will try high pitched one tomorrow, and if it
% doesn't work then I will try the second set later.