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

%% 2011-03-08

annotate_exper('2055', '2011-01-28', ...
    'edgeSyllThreshold', -14, ...
    'triggerSyllThreshold',-10 , ...
    'fMinIntervalDuration', 0.025)


%% 2011-03-09

% check to see if clustered
close all; load(annofilename('2055', '2011-01-28', 'type', 'misc')); hist([misc.segs.segType])

annotate_exper('2055', '2011-01-23', ...
    'edgeSyllThreshold', -14, ...
    'triggerSyllThreshold',-10 , ...
    'fMinIntervalDuration', 0.025)
% pretty much no singing

annotate_exper('2055', '2011-01-24', ...
    'edgeSyllThreshold', -14, ...
    'triggerSyllThreshold',-10 , ...
    'fMinIntervalDuration', 0.025, 'filenum', 22, 'bDebug', true)


annotate_exper('2055', '2011-01-25', ...
    'edgeSyllThreshold', -14, ...
    'triggerSyllThreshold',-10 , ...
    'fMinIntervalDuration', 0.025)

%% 2011-03-09
Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2011 01 23 13 41 00]);
Drug.TimeOut       = Inf; 
annodrugs('2055', '2011-01-23', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3.38e-3;
Drug.TimeIn        = -Inf;
Drug.TimeOut       = datenum([2011 01 25 00 00 00]); 
annodrugs('2055', '2011-01-24', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2011 01 25 13 49 00]);
Drug.TimeOut       = datenum([2011 01 25 22 05 00]);
annodrugs('2055', '2011-01-25', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2011 01 26 12 58 00]);
Drug.TimeOut       = Inf;
annodrugs('2055', '2011-01-26', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2011 01 27 13 45 00]);
Drug.TimeOut       = Inf;
annodrugs('2055', '2011-01-27', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2011 02 02 11 42 00]);
Drug.TimeOut       = Inf;
annodrugs('2055', '2011-02-02', Drug)

% skip 2/14 and 2/15

expernames = {'2011-01-22', '2011-01-23', '2011-01-25', ...
    '2011-01-26', '2011-01-27', '2011-01-28' };
[conc, N] = singingwithdrugs('2055', expernames, 19, 22);
scatter(conc, N)

N = singingwithdrugs2('2055', expernames)
plot(N)