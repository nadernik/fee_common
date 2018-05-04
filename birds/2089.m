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
plot_pitch_multiday('2089',{'2011-02-20' '2011-02-21'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.107 .112], 'pitch_lim_units', 'seconds')

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
vcQuickCluster('2089', '2011-02-26', 'polygons20110223.mat', [], 'root','c:\stetner\data\')

annotate_exper('2089', '2011-02-27', ... 
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02, ...
    'filenum', 1:670)
vcQuickCluster('2089', '2011-02-27', 'polygons20110223.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-02-25', '2011-02-26' '2011-02-27'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')
% did not learn. no drugs today :(
% tomorrow start pushing up

%% 2011-02-28

overnight_pitch_distribution_shift('2089', '2011-02-26', '2011-02-27', ...
    'clusters', [1 2], ...
    'minpg', 0.3, ...
    'range', [.029 .032], ...
    'rangeunits', 'seconds');

overnight_pitch_distribution_shift('2089', '2011-02-26', '2011-02-27', 'clusters', [1 2], 'minpg', 0.3, 'range', [.029 .032], 'rangeunits', 'seconds');

%% 2011-03-01
annotate_exper('2089', '2011-02-28', ...
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02)
vcQuickCluster('2089', '2011-02-28', 'polygons20110223.mat', [], 'root','c:\stetner\data\')

plot_pitch_multiday('2089',{'2011-02-28'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')
% no learning. need to reverse direction of caf.

%% 2011-03-02

vcQuickCluster('2089', '2011-03-01', 'polygons20110223.mat', 1, 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-03-01'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')
% Great learning! Update rules to push up further.


%% 2011-03-03

vcQuickCluster('2089', '2011-03-02', 'polygons20110223.mat', [], 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-03-02'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')

%% 2011-03-04

vcQuickCluster('2089', '2011-03-03', 'polygons20110223.mat', 2, 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-03-03'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')

% No learning. Start pushing down.

%% 2011-03-05
vcQuickCluster('2089', '2011-03-04', 'polygons20110223.mat', 1, 'root','c:\stetner\data\')
plot_pitch_multiday('2089',{'2011-03-04'}, 'cluster_escapes', 1, 'cluster_hits', 2, 'pitch_lims', [.029 .032], 'pitch_lim_units', 'seconds')
% good learning in spite of drugs

%% 2011-03-07
caf_plots('2089', '2011-03-04', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200);

annotate_exper('2089', '2011-03-07', ...
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02, ...
    'filenum', 250:444)
% adjusted clusters -- escapes are slightly louder than they used to be
vcQuickCluster('2089', '2011-03-07', 'polygons20110307.mat', 1, 'root','c:\stetner\data\')
% Made new filters, pushing down further

%% 2011-03-08
vcQuickCluster('2089', '2011-03-07', 'polygons20110307.mat', 1, 'root','c:\stetner\data\')
cafplots('2089', '2011-03-07', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200);

%% 2011-03-09
annotate_exper('2089', '2011-03-08', ...
    'edgeSyllThreshold', -11, ...
    'triggerSyllThreshold', -7, ...
    'fMinIntervalDuration', 0.02)
vcQuickCluster('2089', '2011-03-08', 'polygons20110307.mat', 2, 'root','c:\stetner\data\')
cafplots('2089', '2011-03-08', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50);
% looks like no learning, but too few files to tell for sure.

%%
Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 16 11 26 00]);
Drug.TimeOut       = Inf;
annodrugs('2089', '2011-02-16', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3.38e-3;
Drug.TimeIn        = datenum([2011 02 17 11 26 00]);
Drug.TimeOut       = datenum([2011 02 18 00 11 00]);
annodrugs('2089', '2011-02-17', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3.38e-3;
Drug.TimeIn        = datenum([2011 02 18 11 27 00]);
Drug.TimeOut       = datenum([2011 02 18 22 59 00]);
annodrugs('2089', '2011-02-18', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 4.5e-3;
Drug.TimeIn        = datenum([2011 02 19 12 43 00]);
Drug.TimeOut       = datenum([2011 02 20 01 12 00]);
annodrugs('2089', '2011-02-19', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 4.5e-3;
Drug.TimeIn        = datenum([2011 02 20 12 34 00]);
Drug.TimeOut       = datenum([2011 02 21 00 34 00]);
annodrugs('2089', '2011-02-20', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 21 11 28 00]);
Drug.TimeOut       = Inf;
annodrugs('2089', '2011-02-21', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 22 11 46 00]);
Drug.TimeOut       = datenum([2011 02 22 22 09 00]);
annodrugs('2089', '2011-02-22', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 23 11 36 00]);
Drug.TimeOut       = datenum([2011 02 24 01 10 00]);
annodrugs('2089', '2011-02-23', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 4.5e-3;
Drug.TimeIn        = datenum([2011 02 24 11 05 00]);
Drug.TimeOut       = datenum([2011 02 24 23 05 00]);
annodrugs('2089', '2011-02-24', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 25 11 33 00]);
Drug.TimeOut       = datenum([2011 02 26 01 17 00]);
annodrugs('2089', '2011-02-25', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 1.13e-3;
Drug.TimeIn        = datenum([2011 02 26 11 39 00]);
Drug.TimeOut       = datenum([2011 02 27 00 50 00]);
annodrugs('2089', '2011-02-26', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 27 12 33 00]);
Drug.TimeOut       = datenum([2011 02 28 00 10 00]);
annodrugs('2089', '2011-02-27', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 1.13e-3;
Drug.TimeIn        = datenum([2011 03 02 11 54 00]);
Drug.TimeOut       = datenum([2011 03 03 00 17 00]);
annodrugs('2089', '2011-03-02', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 03 03 12 08 00]);
Drug.TimeOut       = datenum([2011 03 03 20 57 00]);
annodrugs('2089', '2011-03-03', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2011 03 04 11 59 00]);
Drug.TimeOut       = datenum([2011 03 04 22 33 00]);
annodrugs('2089', '2011-03-04', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 03 07 18 27 00]);
Drug.TimeOut       = Inf;
annodrugs('2089', '2011-03-07', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 4.5e-3;
Drug.TimeIn        = datenum([2011 03 08 12 25 00]);
Drug.TimeOut       = datenum([2011 03 08 21 49 00]);
annodrugs('2089', '2011-03-08', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 03 09 12 25 00]);
Drug.TimeOut       = datenum([2011 03 09 00 17 00]); %FIXME
annodrugs('2089', '2011-03-09', Drug)


expernames = {};
for d = datenum('2/15/2011'):datenum('3/3/2011')
    expernames{end+1} = datestr(d, 'yyyy-mm-dd');
end
N = singingwithdrugs2('2089', expernames)
figure
hold on
c = [0 0 0; 1 .75 .75; 1 .5 .5; 1 .25 .25; 1 0 0];
for ii = 1:5
    plot(N(1:end-1, ii),'Color',c(ii,:), 'LineWidth', 3)
end
xlabel('Hours after drug infusion')
ylabel('Files recorded')


%% figure for lab meeting

close all
cafplots('2089', '2011-03-02', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds');
cafplots('2089', '2011-03-03', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds');
cafplots('2089', '2011-03-04', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds');

%% fig 2

cafplots('2089', '2011-02-25', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds', 'LastN', 200);

%% 2011-03-10
vcQuickCluster('2089', '2011-03-09', 'polygons20110307.mat', 1, 'root','c:\stetner\data\')
cafplots('2089', '2011-03-09', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100);
% Good learning, and fast.

%% 2011-03-11
vcQuickCluster('2089', '2011-03-10', 'polygons20110307.mat', 2, 'root','c:\stetner\data\')
cafplots('2089', '2011-03-10', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds');

% Reverse direction of CAF in middle of day
annotate_exper('2089', '2011-03-11', ...
                'edgeSyllThreshold', -11, ...
                'triggerSyllThreshold', -7, ...
                'fMinIntervalDuration', 0.02, ...
                'filenum', 340:398)
vcQuickCluster('2089', '2011-03-11', 'polygons20110307.mat', 1, 'root','c:\stetner\data\')
% reversed after file 416.

%% 2011-03-13
vcQuickCluster('2089', '2011-03-11', 'polygons20110307.mat', 2, 'root','c:\stetner\data\')
cafplots('2089', '2011-03-11', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds');

vcQuickCluster('2089', '2011-03-12', 'polygons20110307.mat', 1, 'root','c:\stetner\data\')
cafplots('2089', '2011-03-12', ...
    'EscapeCluster', 1, ...
    'HitCluster', 2, ...
    'Range', [.029 .032], ...
    'RangeUnits', 'seconds');
% Did not learn very much. Continue with same filters.