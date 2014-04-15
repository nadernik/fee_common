%% Tutor
datapath = 'c:\stetner\data\tutors\Cage 75\Black256(previous)\undirected\2011-04-20';
d = load(fullfile(datapath, 'exper.mat'));
soundchan = d.exper.audioCh;
datachan = [];
Bout_detect_TO(datapath, soundchan, datachan)
%101 bouts
Parse_segments
vectorClust
% duration x mean_pitch is good.

%% Lesioned pupil

Bout_detect_SAP_TO('c:\stetner\data\mman lesion\2303\2313')
% 2035 bouts!!

Parse_segments
% looked at bouts 1:100

vectorClust
% nothing looks like clusters

%% Combine feature entropy measurements from both birds
close all
tutordata = { ...
    'C:\stetner\data\tutors\Cage 44\LBlue18(current)\2084\bouts\vcdb.mat', ...
    'c:\stetner\data\tutors\Cage 75\Black256(previous)\undirected\2011-04-20\bouts\vcdb.mat'};
lesiondata = { ...
    'c:\stetner\data\mman lesion\2296\2313\bouts\vcdb.mat', ...
    'C:\stetner\data\mman lesion\2303\2313\bouts\vcdb.mat'};
xfeat = {'duration', 'duration'};
yfeat = {'mean_pitchGoodness', 'mean_pitch'};

total_pairs = length(lesiondata); % number of lesion-tutor pairs in the dataset
for n = 1:total_pairs
    [entropy_tutor(n), entropy_lesion(n), axh(n)] = feature_2d_entropy_comparison(tutordata{n}, lesiondata{n}, xfeat{n}, yfeat{n});
end

figure
bar([mean(entropy_tutor), mean(entropy_lesion)])
hold on
errorbar(1, mean(entropy_tutor),  std(entropy_tutor)  / total_pairs)
errorbar(2, mean(entropy_lesion), std(entropy_lesion) / total_pairs)

[p, h] = ranksum(entropy_tutor, entropy_lesion);
if h == 1
    disp('Rejected null hypothesis that entropy of tutor and lesion are the same.')
    p
else
    disp('Could not reject null hypothesis that entropy of tutor and lesion are the same')
    p
end

% scatter plots
setticklimx(axh(1).scatter_tutor, [0 0.4])
setticklimx(axh(1).scatter_lesion, [0 0.4])
setticklimx(axh(2).scatter_tutor, [0 0.4])
setticklimx(axh(2).scatter_lesion, [0 0.4])
xlabel(axh(1).scatter_tutor, 'Duration (s)')
xlabel(axh(1).scatter_lesion, 'Duration (s)')
xlabel(axh(2).scatter_tutor, 'Duration (s)')
xlabel(axh(2).scatter_lesion, 'Duration (s)')

% mean pitch goodness
setticklimy(axh(1).scatter_tutor, [0 0.4])
setticklimy(axh(1).scatter_lesion, [0 0.4])

% mean Pitch
setticklimy(axh(2).scatter_tutor, [600 1300])
setticklimy(axh(2).scatter_lesion, [600 1300])
ylabel('Mean Pitch (Hz)')

set(gca, 'XTickLabel', {'Tutor', 'Lesion'})
ylabel('Entropy (bits)')
xlim([0.5 2.5])
axis square

%% Maturity index
clear all

% Use parameters from Aronov et al. 2008
total_bouts = 10;
max_interval_in_bout = 0.5; % seconds
min_bout_duration = 2; % seconds

% find all bouts
load('c:\stetner\data\mman lesion\2303\2313\bouts\analysis_selected.mat', 'dbase')
filenums = 1:100;
dbase = Select_syllable_within_bout(dbase, max_interval_in_bout, min_bout_duration, filenums);

% find all files that contain a bout
files_with_bout = find(cellfun(@(x) ~isempty(x), dbase.BoutTimes, 'UniformOutput', true));

% select random files that have bouts
assert(length(files_with_bout) > total_bouts)
files = randsample(files_with_bout, total_bouts);

nc = 0;
maturity_index = zeros(1, total_bouts*(total_bouts-1)/2);
for i1 = 1:total_bouts
    [full_audio1 fs dt label props] = eval(['egl_' dbase.SoundLoader '([''' dbase.PathName '\' dbase.SoundFiles(files(i1)).name '''],1)']);
    bout_audio1 = full_audio1(dbase.BoutTimes{files(i1)}(1, 1):dbase.BoutTimes{files(i1)}(1, 2));
    for i2 = (i1 + 1):total_bouts
        nc = nc + 1;
        [full_audio2 fs dt label props] = eval(['egl_' dbase.SoundLoader '([''' dbase.PathName '\' dbase.SoundFiles(files(i2)).name '''],1)']);
        bout_audio2 = full_audio1(dbase.BoutTimes{files(i2)}(1, 1):dbase.BoutTimes{files(i2)}(1, 2));
        maturity_index(nc) = SpecCrossCorr_YM2(bout_audio1, bout_audio2, dbase.Fs);
    end
end

%% Spectrum cross correlogram
clear
load('c:\stetner\data\mman lesion\2303\2313\bouts\analysis_selected.mat', 'dbase')
filenums = 1:100;
MaxInterval = 0.3; % [s] % maximum gap interval
MinBoutDuration = 0.5; % [s] minimum bout duraion

dbase = Select_syllable_within_bout(dbase, MaxInterval, MinBoutDuration, filenums);
% find all files that contain a bout
files_with_bout = find(cellfun(@(x) ~isempty(x), dbase.BoutTimes, 'UniformOutput', true));
% select two random files that have bouts
files = randsample(files_with_bout, 2);
% get the audio from a random bout in each of these files
for n = 1:length(files)
    file = files(n);
    [fullaudio fs dt label props] = eval(['egl_' dbase.SoundLoader '([''' dbase.PathName '\' dbase.SoundFiles(file).name '''],1)']);
    nbout = randsample(size(dbase.BoutTimes{file}, 1), 1);
    boutaudio{n} = fullaudio(dbase.BoutTimes{file}(nbout, 1):dbase.BoutTimes{file}(nbout, 2));
end

% do crosscorrelogram on the audio
spectrum_xcorr(boutaudio{1}, boutaudio{2}, dbase.Fs)