%% 2011-02-04
annotate_exper('2055','2011-02-03','filenum',1300:1653,'maxFilesPerAnnotation',500)

%% 2011-02-05
annotate_exper('2055','2011-02-04','filenum',800:1105,'maxFilesPerAnnotation',500)

%% 2011-02-07
annotate_exper('2055','2011-02-06','maxFilesPerAnnotation',400)

% clustered with polygons20110207.mat, with some manual modifications to
% remove syllables with glitchy pitch estimates. This actually was a lot of
% syllables. Maybe will be a problem

% cluster 1 - long syllable that is easy to find
%       2 - target, long version
%       3 - target, short version
% sometimes target is attached to next sylable, sometimes no.

% Made CAF filters
% syllable 3, 25-30%, mean = 651, median = 654 Hz, sd = 20 Hz

%% 2011-02-09

% Per Michale's suggestion, I turned up the gain on the microphone
% amplifier by 30dB after file 287. Now the small offset from the filter
% does not really affect the data.

%% 2011-02-11

annotate_exper('2055','2011-02-10','maxFilesPerAnnotation',500, 'edgeSyllThreshold',-11,'triggerSyllThreshold',-8)

% started caf at 2:39pm

%% 2011-02-14
annotate_exper('2055','2011-02-11', 'edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
annotate_exper('2055','2011-02-12', 'edgeSyllThreshold',-11,'triggerSyllThreshold',-8)
annotate_exper('2055','2011-02-13', 'edgeSyllThreshold',-11,'triggerSyllThreshold',-8)

% Arg! Bad segmenting! Target syllable is sometimes joined with the
% syllable after it. Played with parameters a bit and trying again:
annotate_exper('2055', '2011-02-13', ...
    'edgeSyllThreshold', -10.5, ...
    'triggerSyllThreshold',-6 , ...
    'fMinIntervalDuration', 0.015, ...
    'filenum', 900:1194)
for filenum = 900:1194
    show_file_with_labeled_syllables('2055', '2011-02-13', filenum)
    pause
end
% arg still sometimes splitting target syllable. try again:
annotate_exper('2055', '2011-02-13', ...
    'edgeSyllThreshold', -10.5, ...
    'triggerSyllThreshold',-6 , ...
    'fMinIntervalDuration', 0.025, ...
    'filenum', 900:1194)
for filenum = 900:1194
    show_file_with_labeled_syllables('2055', '2011-02-13', filenum)
    pause
end
% Looks good :)

% new clusters (polygons20110214.mat)
%   1 = long syllable that is easy to find
%   2 = escapes
%   3 = hits

%% 2011-02-15

vcQuickCluster('2055', '2011-02-14', 'polygons20110214.mat', [], 'root', 'c:\stetner\data\')

% Updated filters: Shifted pitch up to 610 Hz and fiddled with thresholds
% on amplitude-based rules. Loaded at 12:32pm before he sang anything.

% Accidentally tore off implant while flushing drugs :(