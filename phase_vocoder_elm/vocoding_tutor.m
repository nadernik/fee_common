%% get the correct path
cd ~/Documents/code/
add_elm_code_paths
%% 
% pick a bird to look at
pathname = PlatformPicker('feebox1', fullfile('shared', 'colony', 'tutorsong'));
pathname = fullfile(pathname, '73', 'Purple37(previous)', 'undirected', '2461');
DIR = dir(fullfile(pathname, '*.wav'))
close all
%%
%look through some if its files
for i = 1:10
    figure
    [a,fs] = wavread(fullfile(pathname, DIR(i).name));
    displaySpecgramQuick(a,fs);
    sound(a,fs)
end

%% 
close all
% choose a file that looks good, start and end times in sec
i = 8; start_time = 0; end_time = 2;

% segment syllables and display them on top of spectrogram
[a,fs] = wavread(fullfile(pathname, DIR(i).name));
Singing = a(max(1,start_time*fs):(fs*end_time));
segs = Syllable_segment_Emily(fullfile(pathname, DIR(i).name), 4000); 
displaySpecgramQuick(Singing,fs); hold on
ind = [];
for i = 1:size(segs,1)
    ind = [ind segs(i,1):segs(i,2)];
    plot([segs(i,1)/fs segs(i,2)/fs], [6000 6000], 'r', 'linewidth', 6)
    %syl{j}{i} = song(segs(i,1):segs(i,2));
end

sound(Singing,fs)

%% examine autocorrelation of dB trace
[c, lags] = xcorr(raw2dB(Singing,fs));
figure; 
plot(lags/fs, c);shg

%% separating the intros from the rest of the song (by eye)
intro_split = .84
INTROS = Singing(1:fs*intro_split);
SONG = Singing(fs*intro_split:end);
%% stretch a version
figure; h = subplot(2,1,1)
% set how many times faster
faster_factor = 5/4;
displaySpecgramQuick([INTROS;SONG],fs); hold on
Stretched = pvoc(SONG, faster_factor, 200);
g = subplot(2,1,2)
displaySpecgramQuick([INTROS; Stretched],fs); hold on
linkaxes([h g])
xlim([0 max([numel(Singing)/fs numel([INTROS; Stretched])/fs])])
sound([INTROS;SONG],fs)
sound([INTROS; Stretched],fs)

