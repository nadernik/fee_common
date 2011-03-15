%% 2011-02-04
annotate_exper('mes003','2011-02-03')

% clustered in vectorClust:
%   1 is long syllable that is easy to detect
%   2 is target syllable
% saved to polygons.mat
% no manual inclusions/exclusions

% creating rules for the first time
% targeting cluster 2, 60-70%.
% mean = 641, median = 640, sd = 11.2
% this range is very similar to 2089, but the standard deviation is much
% smaller (20.6 vs 11.2). I will try the same pitch filter to see if it
% works here.

%% 2011-02-08

annotate_exper('mes003','2011-02-08','filenum',600:888)
vcQuickCluster('mes003','2011-02-08', 'polygons.mat', [], 'root', 'c:\stetner\data\')

% making rules
% cluster 2, 60-70%, mean=median=638, sd=9.31
% increased syll threshold from -80 to -72 to compensate for TDT offset

%% 2011-02-09

% CAF wasn't working, so after file 21 changed syll threshold to -108. Now
% it works.

%% 2011-02-11

% turned off noise 2:07pm to 2:39pm to test rules for 2055.

%% 2011-02-12
annotate_exper('mes003','2011-02-10','edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
annotate_exper('mes003','2011-02-11','edgeSyllThreshold',-11,'triggerSyllThreshold',-8)

%% 2011-02-15

annotate_exper('mes003','2011-02-09','edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
annotate_exper('mes003','2011-02-12','edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
annotate_exper('mes003','2011-02-13','edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
% exper 2011-02-14 was annotated last night

for dotm = 9:14
    expername = sprintf('2011-02-%02.f', dotm);
    deglitch_all_pitch('mes003',expername);
    vcQuickCluster('mes003', expername, 'polygons20110215.mat', [], 'root', 'c:\stetner\data\')
end

plot_pitch_multiday('mes003', ...
    {'2011-02-09' '2011-02-10' '2011-02-11'}, ...
    'cluster_escapes', 1, ...
    'pitch_lims', [.080 .085], ...
    'pitch_lim_units', 'seconds')

%% 2011-02-22

vcQuickCluster('mes003', '2011-02-21', 'polygons20110222.mat', [], 'root', 'c:\stetner\data\')
plot_pitch_multiday('mes003', ...
    {'2011-02-21'}, ...
    'cluster_escapes', 1, ...
    'pitch_lims', [.095 .1], ...
    'pitch_lim_units', 'seconds')

%% 2011-02-23

% did not sing very much even tho he was on PBS

vcQuickCluster('mes003', '2011-02-22', 'polygons20110222.mat', 1, 'root', 'c:\stetner\data\')

plot_pitch_multiday('mes003', ...
    {'2011-02-22'}, ...
    'cluster_escapes', 1, ...
    'pitch_lims', [.087 .090], ...
    'pitch_lim_units', 'seconds')

%% 2011-02-24

vcQuickCluster('mes003', '2011-02-23', 'polygons20110222.mat', 1, 'root', 'c:\stetner\data\')

plot_pitch_multiday('mes003', ...
    {'2011-02-23'}, ...
    'cluster_escapes', 1, ...
    'pitch_lims', [.087 .090], ...
    'pitch_lim_units', 'seconds')

% Made new rules, pushing down.

%% 2011-02-25
vcQuickCluster('mes003', '2011-02-24', 'polygons20110222.mat', 1, 'root', 'c:\stetner\data\')

plot_pitch_multiday('mes003', ...
    {'2011-02-24'}, ...
    'cluster_escapes', 1, ...
    'pitch_lims', [.087 .090], ...
    'pitch_lim_units', 'seconds', ...
    'n_distribution', 200)

time_in = datenum([2011 02 24 10 59 00]); % 10:59am
time_out = datenum([2011 02 24 23 09 00]); % 11:09pm
conc = 1.13e-3; %Molar
add_drugs_to_annotation('mes003', '2011-02-24', 'CNQX + APV', conc, time_in, time_out)

%% 2011-02-27
annotate_exper('mes003', '2011-02-27', ...
                'edgeSyllThreshold', -11, ...
                'triggerSyllThreshold', -8, ...
                'filenum', 1:582)
            
vcQuickCluster('mes003', '2011-02-27', 'polygons20110227.mat', [], 'root', 'c:\stetner\data\')

plot_pitch_multiday('mes003', ...
    {'2011-02-27'}, ...
    'cluster_escapes', 1, ...
    'cluster_hits', 2, ...
    'pitch_lims', [.087 .090], ...
    'pitch_lim_units', 'seconds', ...
    'n_distribution', 200)

%% 2011-02-28
annotate_exper('mes003', '2011-02-28', ...
                'edgeSyllThreshold', -11, ...
                'triggerSyllThreshold', -8)

%% 2011-03-02

vcQuickCluster('mes003', '2011-03-01', 'polygons20110227.mat', 1, 'root', 'c:\stetner\data\')
% Need to recluster due to drift.
vcQuickCluster('mes003', '2011-03-01', 'polygons20110302.mat', [], 'root', 'c:\stetner\data\')
plot_pitch_multiday('mes003', ...
    {'2011-03-01'}, ...
    'cluster_escapes', 1, ...
    'cluster_hits', 2, ...
    'pitch_lims', [.087 .090], ...
    'pitch_lim_units', 'seconds', ...
    'n_distribution', 200)
% Looks like he didn't learn. Reverse direction of CAF.

%% 2011-03-03
vcQuickCluster('mes003', '2011-03-02', 'polygons20110303.mat', [], 'root', 'c:\stetner\data\')
plot_pitch_multiday('mes003', ...
    {'2011-03-02'}, ...
    'cluster_escapes', 1, ...
    'cluster_hits', 2, ...
    'pitch_lims', [.087 .090], ...
    'pitch_lim_units', 'seconds', ...
    'n_distribution', 200)
% Hit/escape does not seem to be based on pitch over target interval.
% Adjusted filters by restricting syll rule to 80-90ms into syllable (much
% shorter region than before) and changing pitch threshold to hit ~half of
% syllables.

%% 2011-03-04

% Didn't sing yesterday.

%% 2011-03-07
annotate_exper('mes003', '2011-03-07', ...
                'edgeSyllThreshold', -11, ...
                'triggerSyllThreshold', -8, ...
                'filenum', 1:116)
% too little variability left

%% 2011-03-09
Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 19 12 50 00]);
Drug.TimeOut       = datenum([2011 02 20 01 30 00]);
annodrugs('mes003', '2011-02-19', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3.38e-3;
Drug.TimeIn        = datenum([2011 02 20 12 30 00]);
Drug.TimeOut       = datenum([2011 02 21 00 31 00]);
annodrugs('mes003', '2011-02-20', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 21 11 26 00]);
Drug.TimeOut       = Inf;
annodrugs('mes003', '2011-02-21', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2011 02 22 11 46 00]);
Drug.TimeOut       = datenum([2011 02 22 10 05 00]);
annodrugs('mes003', '2011-02-22', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 23 11 30 00]);
Drug.TimeOut       = datenum([2011 02 24 01 07 00]);
annodrugs('mes003', '2011-02-23', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 1.13e-3;
Drug.TimeIn        = datenum([2011 02 24 10 59 00]);
Drug.TimeOut       = datenum([2011 02 24 23 09 00]);
annodrugs('mes003', '2011-02-24', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 25 11 31 00]);
Drug.TimeOut       = datenum([2011 02 26 01 14 00]);
annodrugs('mes003', '2011-02-25', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 02 26 11 35 00]);
Drug.TimeOut       = datenum([2011 02 27 00 43 00]);
annodrugs('mes003', '2011-02-26', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 1.13e-3;
Drug.TimeIn        = datenum([2011 02 27 19 23 00]);
Drug.TimeOut       = datenum([2011 02 28 00 07 00]);
annodrugs('mes003', '2011-02-27', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 1.13e-3;
Drug.TimeIn        = datenum([2011 03 02 11 44 00]);
Drug.TimeOut       = datenum([2011 03 03 00 13 00]);
annodrugs('mes003', '2011-03-02', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2011 03 03 12 05 00]);
Drug.TimeOut       = datenum([2011 03 03 20 52 00]);
annodrugs('mes003', '2011-03-03', Drug)

% Drug.Name          = 'CNQX + APV';
% Drug.Concentration = 2.25e-3;
% Drug.TimeIn        = datenum([2011 03 04 11 56 00]);
% Drug.TimeOut       = datenum([2011 03 04 22 30 00]);
% annodrugs('mes003', '2011-03-04', Drug)

expernames = {};
for d = datenum('2/18/2011'):datenum('3/3/2011')
    expernames{end+1} = datestr(d, 'yyyy-mm-dd');
end
expernames = expernames(~strcmp(expernames, '2011-02-28'));
N = singingwithdrugs2('mes003', expernames)
figure
hold on
c = [0 0 0; 1 .75 .75; 1 .5 .5; 1 .25 .25; 1 0 0];
for ii = 1:5
    plot(N(1:end-1, ii),'Color',c(ii,:), 'LineWidth', 3)
end
xlabel('Hours after drug infusion')
ylabel('Files recorded')