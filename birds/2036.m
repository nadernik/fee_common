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

%% 2011-02-08
annotate_exper('2036','2011-02-07','maxFilesPerAnnotation',450)

% New polygons file, polygons20110208.mat, to take advantage of new save
% file format that includes information on calculating partial mean
% features. Now, when I load this polygons file in the updated version of
% vectorClust (that I will commit to bazaar later today), it will
% automatically recalculate all the necessary scalar features. Yay!

% Checking progress on CAF today: is my targeting working?
annotate_exper('2036','2011-02-08') % first 116 files of the day
vcQuickCluster('2036','2011-02-08', 'polygons20110208.mat', [], 'root', 'c:\stetner\data')
plot_pitch_multiday('2036','2011-02-08','cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.05 .06], 'pitch_lim_units', 'seconds')
% Looks good.

%% 2011-02-09

% Saved new rules into 2011-02-08 folder. These are the same as the rules I
% was using previously, but with a different associated TDT circuit.

% Look at yesterday to see if he learned
annotate_exper('2036','2011-02-08')
vcQuickCluster('2036','2011-02-08', 'polygons20110208.mat', [], 'root', 'c:\stetner\data')
plot_pitch_multiday('2036',{'2011-02-08'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.05 .06], 'pitch_lim_units', 'seconds')
% looks like he is getting noised less, but pitch is not shifting

annotate_exper('2036','2011-02-09','filenum',1:790,'maxFilesPerAnnotation',400)
vcQuickCluster('2036','2011-02-09', 'polygons20110208.mat', [], 'root', 'c:\stetner\data')
% okay maybe the percent noised isnt even going down. arg.
plot_pitch_multiday('2036',{'2011-02-08', '2011-02-09'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.05 .06], 'pitch_lim_units', 'seconds')

%% 2011-02-11

annotate_exper('2036','2011-02-10','maxFilesPerAnnotation',412,'edgeSyllThreshold',-11,'triggerSyllThreshold',-8)

% Since I turned up the gain on my mic amplifier and all of my polygons
% were dependent on amplitude, I need to make new clusters. Saved to
% polygons20110211.mat

vcQuickCluster('2036','2011-02-10','polygons20110211.mat',[],'root','c:\stetner\data\')

plot_pitch_multiday('2036',{'2011-02-10'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.05 .055], 'pitch_lim_units', 'seconds')
% Definitely not learning. It seems like he can escape even if his pitch is
% wrong. Need to work on filters.

% New filters loaded after file 97.

% check to see how things are going
annotate_exper('2036','2011-02-11','filenum',98:190,'edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
vcQuickCluster('2036','2011-02-11','polygons20110211.mat',[],'root','c:\stetner\data\')
plot_pitch_multiday('2036',{'2011-02-11'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.045 .05], 'pitch_lim_units', 'seconds')

% turned off noise 2:07pm to 2:39pm to test rules for 2055.

%% 2011-02-12

annotate_exper('2036','2011-02-11','edgeSyllThreshold',-11,'triggerSyllThreshold',-8,'maxFilesPerAnnotation',470)
vcQuickCluster('2036','2011-02-11','polygons20110211.mat',[],'root','c:\stetner\data\')
plot_pitch_multiday('2036',{'2011-02-11'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.045 .05], 'pitch_lim_units', 'seconds')

% Still not learning! Will give him one more day with existing filters and
% then give up.

%% 2011-02-13
annotate_exper('2036','2011-02-12','edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
vcQuickCluster('2036','2011-02-12','polygons20110211.mat',[],'root','c:\stetner\data\')
plot_pitch_multiday('2036',{'2011-02-11' '2011-02-12'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.045 .05], 'pitch_lim_units', 'seconds')

%% 2011-02-14
annotate_exper('2036','2011-02-13','edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
vcQuickCluster('2036','2011-02-13','polygons20110211.mat',[],'root','c:\stetner\data\')
plot_pitch_multiday('2036',{'2011-02-11' '2011-02-12' '2011-02-13'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.042 .048], 'pitch_lim_units', 'seconds')

% appears to have learned, slowly. will begin experiment by infusing pbs
% today and then drugs tomorrow. need to also update filters today

% Started with rules from 2011-02-11 and increased pitch on pitch rule from
% 685 to 705 Hz. Loaded at 3:53pm (after file 319)

%% 2011-02-15

% Looks like almost every instance of target was hit. Oops. Need to move
% pitch filter down a bit. Updated and loaded after file 3.

%% 2011-02-16

% Annotated by overnight batch.
vcQuickCluster('2036','2011-02-15','polygons20110211.mat',[],'root','c:\stetner\data\')
plot_pitch_multiday('2036',{'2011-02-15'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.045 .05], 'pitch_lim_units', 'seconds', 'n_distribution', 200)
% Looks like there is a shift in pitch, but a small one. Looks like 695 to
% 705 Hz, which looks like it is about 1 standard deviation. I need to do
% further analysis to see if this shift is significant.

% Updated plot_pitch_multiday() to give median, standard deviation and
% ttest from pitch distributions. It says that means are not significantly
% different, so I will continue on PBS today.

% recalibrated speaker volume. Was at 90 dBL (S SPL). Now at 97 dB and
% cannot turn amplifier any higher.

%% 2011-02-17

% Annotated by overnight batch.
vcQuickCluster('2036','2011-02-16','polygons20110211.mat',[],'root','c:\stetner\data\')
plot_pitch_multiday('2036',{'2011-02-15' '2011-02-16'},'cluster_escapes',2,'cluster_hits',3,'pitch_lims', [.045 .05], 'pitch_lim_units', 'seconds')

% learned, but caf broke later in day? Maybe after testing noise