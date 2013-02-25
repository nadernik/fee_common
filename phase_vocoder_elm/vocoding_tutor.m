%% get the correct path
cd ~/Documents/code/
add_elm_code_paths
%% 
% pick a bird to look at
pathname = PlatformPicker('feebox1', fullfile('shared', 'colony', 'tutorsong'));
pathname = fullfile(pathname, '73', 'Purple37(previous)', 'undirected',...
'2461'); % quite rhythmic at .07 and .15s lag
%pathname = fullfile(pathname, '9', 'Black225Yellow411(current)'); %very repetitive
%pathname = fullfile(pathname, '18', 'LBlue14(current)'); %rhythmic at .2s lag, .1s less so
%pathname = fullfile(pathname, '23', 'Black238(current)', 'directed'); %rhythmic at .2s lag, .1s less so
%pathname = fullfile(pathname, '46', 'LBlue4(current)', '2723'); % rhythmic at .18s lag
%pathname = fullfile(pathname, '70', 'purple32(previous)', 'undirected',
%'2104'); % fairly rhythmic, but without long bouts
%pathname = fullfile(pathname, '72', 'LBlue22(previous)', 'undirected', '2105'); 
DIR = dir(fullfile(pathname, '*.wav'))
close all
%%
close all
%look through some if its files
for i = 31:40 
    figure
    [a,fs] = wavread(fullfile(pathname, DIR(i).name));
    displaySpecgramQuick(a,fs);
    sound(a,fs)
end

%% 
close all
% choose a file that looks good, start and end times in sec
i = 32; start_time = 0; end_time =90;

% segment syllables and display them on top of spectrogram
[a,fs] = wavread(fullfile(pathname, DIR(i).name));
Singing = a(max(1,start_time*fs):(min(end,fs*end_time)));
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
lag = .228/3; %observed from autocorr for 73, purple37
%% separating the intros from the rest of the song (by eye)
intro_split = 1/fs;
INTROS = Singing(1:fs*intro_split);
SONG = Singing(fs*intro_split:end);
%% stretch a version
figure;  h = subplot(2,1,1)
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

