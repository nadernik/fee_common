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