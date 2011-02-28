%% 2011-02-04
annotate_exper('2089','2011-02-03','maxFilesPerAnnotation',500)

% clustered in vectorClust, using polygons.mat. No other modifications.

% tested rules_matlab.mat from 2011-02-01 on files 340-364 from 2011-02-03.
% found that 43% of cluster 1 would be hit (N=60). Looks like pitch
% actually matters. Lower pitches are hit and higher pitches escape. Yay.

% Since filters seem good, turned on CAF at 12:52pm before any files were
% sung

%% 2011-02-07
annotate_exper('2089','2011-02-06','maxFilesPerAnnotation',500)

% Seems like no noise on 2011-02-06. Is CAF running? No. Speaker is not
% plugged into TDT. Will verify that filters are still good and then start
% it.

deglitch_all_pitch('2089', '2011-02-06')
vcQuickCluster('2089', '2011-02-06', 'polygons.mat', [], 'root', 'c:\stetner\data')

% Still good. Tested on files 908-923 of 2011-02-06 and hits 43% of target
% syllable (N=44) with good pitch discrimination. Sometimes also hits the
% very end of another syllable, but I think it will be okay.

% Rules loaded after file 431

% Just sitting in my room I hear the noise going off even when the bird is
% not singing (aquisitionGui not triggered to record). Caught an example by
% forcing recording, file 433. Will see if bird will sing anyway. May need
% to adjust filters. Also file 435.

%% 2011-02-08
annotate_exper('2089','2011-02-07','maxFilesPerAnnotation',350)
% no noise in part 1. rules were not loaded yet.

% A glance at today's files shows that the target syllable is rarely hit.
% In fact the syllable before it is hit much more often. Did the bird
% learn or do my filters suck?

% made new polygons
% cluster 1 = noised targets, except not when the syllable before it was
% also noised. DOES include noised targets that were segmented badly and
% include the next little syllable
% cluster 2 = escapes (targets that were not noised)
% cluster 3 = that other syllable before the target, not noised
% cluster 4 = that other syllable before target, noised
% cluster 5 = other syllable and target, both noised and segmented badly so
% they are both one syllable

% applied to 2011-02-07 in vectorClust, now for today's data so far:
annotate_exper('2089','2011-02-08','maxFilesPerAnnotation',350,'filenum',1:318)
vcQuickCluster('2089', '2011-02-08', 'polygons20110208.mat', [], 'root', 'c:\stetner\data')
deglitch_all_pitch('2089', '2011-02-07')
deglitch_all_pitch('2089', '2011-02-08')

plot_pitch_multiday('2089',{'2011-02-07' '2011-02-08'},'cluster_escapes',2,'cluster_hits',1,'pitch_lims', [.105 .110], 'pitch_lim_units', 'seconds')
% Looks good! Will implant tomorrow!

%% 2011-02-09

% implanted probes in area X

%% 2011-02-10

% (9:30am) Incision is open, but no bleeding. Lightly anesthetized with
% isoflurane and applied some vetropolycin to the area. Injected with 50 uL
% baytril/buprenex mix.

%% 2011-02-14

% Yesterday was his first full day singing since surgery. Today I will get
% CAF running again and then start injecting PBS or drugs on 2-16.

annotate_exper('2089','2011-02-13','edgeSyllThreshold',-11,'triggerSyllThreshold',-7, 'fMinIntervalDuration', 0.02)

%% 2011-02-15

% clustered in vectorClust. New polygons file for escapes only. There are
% no hits yet because caf was not running.

% New rules loaded at 12:47pm before any singing.

% starting with rules from 2011-02-07, updated

%% 2011-02-16

% Annotated by overnight batch.

% Clustered in vectorClust. Made new polygons (polygons20110216.mat) that
% are the same as yesterday except now also include hits as cluster 2.

plot_pitch_multiday('2089','2011-02-15', 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')

% No change in pitch. Continue on PBS today.

% recalibrated speaker 96 dB to 101 dB

%% 2011-02-17

vcQuickCluster('2089', '2011-02-16', 'polygons20110216.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-15' '2011-02-16'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')


% after file 154 reverted to rev 21 and reloaded rules.

%% 2011-02-18

vcQuickCluster('2089', '2011-02-17', 'polygons20110218.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-17'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')

% Looks like I was not hitting only a small portion of syllables. Adjusted
% pitch rule upwards by 5 Hz so I will hit more.

%% 2011-02-19

vcQuickCluster('2089', '2011-02-18', 'polygons20110218.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{ '2011-02-18'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')
% looks like he is learning. will try higher concenration.

%% 2011-02-21
vcQuickCluster('2089', '2011-02-19', 'polygons20110218.mat', [], 'root','c:\stetner\data\')
vcQuickCluster('2089', '2011-02-20', 'polygons20110218.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{ '2011-02-19' '2011-02-20'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')
% YAY! No learning!

plot_pitch_multiday('2089',{'2011-02-17' '2011-02-18' '2011-02-19' '2011-02-20'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')

%% 2011-02-22

vcQuickCluster('2089', '2011-02-21', 'polygons20110218.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-21'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')

% no learning, even though he only  had PBS :(

%% 2011-02-23

% Yesterday I made new filters to target the harmonic stack at the
% beginning of the same target syllable. This stack has a higher pitch, so
% I will hopefully be able to push it more.

vcQuickCluster('2089', '2011-02-22', 'polygons20110223.mat', 2, 'root','c:\stetner\data\')

% Made new polygons to capture new noise cluster. Escapes cluster remained
% the same.

plot_pitch_multiday('2089',{'2011-02-22'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')

%% 2011-02-23

vcQuickCluster('2089', '2011-02-23', 'polygons20110223.mat', 2, 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-23'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')

% He learned!! Adjusted filters to push down even further.

%% 2011-02-25
annotate_exper('2089', '2011-02-25', ...
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02, ...
    'filenum', 1:182)
            
vcQuickCluster('2089', '2011-02-25', 'polygons20110223.mat', 2, 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-25'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')

%% 2011-02-26
  
vcQuickCluster('2089', '2011-02-25', 'polygons20110223.mat', 2, 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-25'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')
% great!!!

%% 2011-02-27

annotate_exper('2089', '2011-02-27', ...
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02, ...
    'filenum', 1:670)
vcQuickCluster('2089', '2011-02-27', 'polygons20110223.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-27'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')
% did not learn. no drugs today :(
% tomorrow start pushing up

%% 2011-02-28

overnight_pitch_distribution_shift('2089', '2011-02-26', '2011-02-27', ...
    'clusters', [1 2], ...
    'minpg', 0.3, ...
    'range', [.029 .032], ...
    'rangeunits', 'seconds');

overnight_pitch_distribution_shift('2089', '2011-02-26', '2011-02-27', 'clusters', [1 2], 'minpg', 0.3, 'range', [.029 .032], 'rangeunits', 'seconds');