%% 2011-02-19
annotate_exper('2098','2011-02-19b','edgeSyllThreshold',-10,'triggerSyllThreshold',-8,'filenum',1:43)

%% 2011-02-21

annotate_exper('2098','2011-02-19b','edgeSyllThreshold',-10,'triggerSyllThreshold',-8)
annotate_exper('2098','2011-02-20','edgeSyllThreshold',-10,'triggerSyllThreshold',-8)

% clustered in vectorClust. New polygons file 'polygons20110221.mat' that
% includes a cluster for noise.

vcQuickCluster('2098', '2011-02-20', 'polygons20110221.mat', [], ...
    'root', 'c:\stetner\data')

plot_pitch_multiday('2098', '2011-02-20', 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.117 .122], 'pitch_lim_units', 'seconds')

%% 2011-02-22
annotate_exper('2098','2011-02-21','edgeSyllThreshold',-10,'triggerSyllThreshold',-8)
vcQuickCluster('2098', '2011-02-21', 'polygons20110221.mat', [], ...
    'root', 'c:\stetner\data')
plot_pitch_multiday('2098', {'2011-02-20' '2011-02-21'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.117 .122], 'pitch_lim_units', 'seconds')

%% 2011-02-23
annotate_exper('2098','2011-02-22','edgeSyllThreshold',-10,'triggerSyllThreshold',-8)
vcQuickCluster('2098', '2011-02-22', 'polygons20110221.mat', [], ...
    'root', 'c:\stetner\data')
plot_pitch_multiday('2098', {'2011-02-22'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.117 .122], 'pitch_lim_units', 'seconds')

%% 2011-02-24

annotate_exper('2098','2011-02-23','edgeSyllThreshold',-10,'triggerSyllThreshold',-8)
vcQuickCluster('2098', '2011-02-23', 'polygons20110224.mat', [], ...
    'root', 'c:\stetner\data')
plot_pitch_multiday('2098', { '2011-02-23'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.117 .122], 'pitch_lim_units', 'seconds')
% bad segmentation

annotate_exper('2098','2011-02-23','edgeSyllThreshold',-8,'triggerSyllThreshold',-6,'fMinIntervalDuration',0.03)

%% 2011-02-25
annotate_exper('2098','2011-02-24','edgeSyllThreshold',-8,'triggerSyllThreshold',-6,'fMinIntervalDuration',0.03)
vcQuickCluster('2098', '2011-02-24', 'polygons20110224.mat', 1, ...
    'root', 'c:\stetner\data')
plot_pitch_multiday('2098', { '2011-02-23' '2011-02-24'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.117 .122], 'pitch_lim_units', 'seconds')

caf_plots('2098', '2011-02-24', ...
    'polygon_file', 'c:\stetner\data\2098\polygons20110224.mat', ...
    'cluster_escape', 1, ...
    'cluster_hit', 2, ...
    'target_region', [.117 .122], ...
    'target_units', 'seconds')