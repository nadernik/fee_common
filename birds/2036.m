%% 2011-02-03
% Bird is not learning on CAF. It seems like my filters are not specific enough. When I plot mean pitch vs. noised or not, I do not see a clear separation of pitches. I would expect lower pitches to be noised and higher pitches to be escapes.
% Made better clusters using these additional features (20100203 polygons.mat)
% 	35_45_mean_pitch 
% 	35_45_mean_pitchGoodness
% 	25_35_mean_pitchGoodness
%% 2011-02-04

annotate_exper('2036','2011-02-03','maxFilesPerAnnotation',400)

% clustered in vectorClust with "20110203 polygons.mat"

% with rules_matlab.mat from 2011-02-01, tested on syllables from files
% 316-353 on 2011-02-03 (N=60) hits 18% of cluster 2, the target, and 14%
% of cluster 1 (bad!)

% problem: window does not always come at the right time. often comes too
% late. i need to find another way to do timing

% exper 2011-02-04b is for debugging
% stopped other expers from acquiring while debugging

% made new and better rules and loaded them (exper 2011-02-04c)

%% 2011-02-05

% after file 65 changed syll from 25 to 40 ms above

%% 2011-02-06

annotate_exper('2036','2011-02-05','maxFilesPerAnnotation',430)

%% 2011-02-07
annotate_exper('2036','2011-02-06','maxFilesPerAnnotation',350)

% clustered with "20110203 polygons.mat"
% had to create extra features in vectorClust. I should make a way to do
% this automatically so I can use vcQuickCluster.m

plot_pitch_multiday('2036', {'2011-02-05', '2011-02-06'}, 'pitch_lims', [.04 .05], 'pitch_lim_units', 'seconds', 'cluster_hits', 3, 'cluster_escapes', 2)

% small shift in median pitch (~9Hz), but I am not conviced he is learning.
% There is not a slow and steady shift in pitch, but a sudden change on
% 2011-02-06. While all hits are on syllables with lower pitch, there are
% also many low pitch syllables that escape. 

% Testing files around 125 in 2011-02-07 show that matlab testing and what
% happens for real do not agree. Some syllables that escape should be
% getting noise according to MATLAB testing.

% Turned off CAF after file 426 for debuging. Back on after file 428.

% After debugging, found that rule "insong" was not staying triggered for
% as long as it should. Extended time high to 800ms to compensate.