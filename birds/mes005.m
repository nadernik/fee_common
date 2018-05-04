%% 2011-02-16

annotate_exper('mes005','2011-02-16','edgeSyllThreshold',-11,'triggerSyllThreshold',-7, 'fMinIntervalDuration', 0.02, 'filenum',1:111)

%% 2011-02-17

annotate_exper('mes005','2011-02-16','edgeSyllThreshold',-11,'triggerSyllThreshold',-7, 'fMinIntervalDuration', 0.02)

%% 2011-02-18

% Annotated by overnight batch.
% Clustered in vectorClust with polygons20110218.mat which now includes
% cluster #2 for hits
plot_pitch_multiday('mes005','2011-02-17','cluster_hits', 2, 'pitch_lims', [14 17], 'pitch_lim_units', 'percent')
% Looks like I am hitting way more than half of renditions, but there are
% still some escapes so he should be able to learn. No learning observed
% yet, but I started the CAF near the end of the day yesterday. Will
% continue for 1-2 more days.

%% 2011-02-20

% Annotated by overnight batch
vcQuickCluster('mes005','2011-02-18','polygons20110218.mat',[],'root','c:\stetner\data\');
vcQuickCluster('mes005','2011-02-19','polygons20110218.mat',[],'root','c:\stetner\data\');
plot_pitch_multiday('mes005',{'2011-02-17' '2011-02-18' '2011-02-19'},'cluster_hits', 2, 'pitch_lims', [14 17], 'pitch_lim_units', 'percent')

%% 2011-02-21

vcQuickCluster('mes005','2011-02-20','polygons20110218.mat',[],'root','c:\stetner\data\');
plot_pitch_multiday('mes005',{'2011-02-19' '2011-02-20'},'cluster_hits', 2, 'pitch_lims', [14 17], 'pitch_lim_units', 'percent')

%% 2011-02-22
vcQuickCluster('mes005','2011-02-21','polygons20110218.mat',[2],'root','c:\stetner\data\');
plot_pitch_multiday('mes005',{'2011-02-21'},'cluster_hits', 2, 'pitch_lims', [14 17], 'pitch_lim_units', 'percent')

%% 2011-02-23
vcQuickCluster('mes005','2011-02-22','polygons20110218.mat',[2],'root','c:\stetner\data\');
plot_pitch_multiday('mes005',{'2011-02-22'},'cluster_hits', 2, 'pitch_lims', [.038 .043], 'pitch_lim_units', 'seconds')
% Did not learn. Sadness.

annotate_exper('mes005', '2011-02-23', ...
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02, ...
    'filenum', 1:106)
vcQuickCluster('mes005','2011-02-23','polygons20110218.mat',[],'root','c:\stetner\data\');
plot_pitch_multiday('mes005',{'2011-02-23'},'cluster_hits', 2, 'pitch_lims', [.038 .043], 'pitch_lim_units', 'seconds')

%% 2011-02-24

vcQuickCluster('mes005','2011-02-23','polygons20110218.mat',[],'root','c:\stetner\data\');
plot_pitch_multiday('mes005',{'2011-02-23'},'cluster_hits', 2, 'pitch_lims', [.038 .043], 'pitch_lim_units', 'seconds')
% no learning.

%% 2011-02-25
vcQuickCluster('mes005','2011-02-24','polygons20110218.mat',[],'root','c:\stetner\data\');
plot_pitch_multiday('mes005',{'2011-02-23' '2011-02-24'},'cluster_hits', 2, 'pitch_lims', [.038 .043], 'pitch_lim_units', 'seconds')