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