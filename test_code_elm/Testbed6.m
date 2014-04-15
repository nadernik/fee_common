clear all; close all; 
cd ~/../../Volumes/emackev
pathname = 'SongsFromMichale1';
DIR1 = dir([pathname, '/*.wav']); 
ind = 1;
for i = 1:length(DIR1);
    if ~issame(DIR1(i).name(1),'.')
        DIR(ind).name = DIR1(i).name;
        ind = ind+1;
    end
end
Nsongs = size(DIR,2);
fs = 40000
for j = 1:Nsongs
    [song1,fs1] = wavread([pathname,'/', DIR(j).name]);fs1;
    song = resample(song1,fs,fs1);
    segs = Syllable_segment_Emily([pathname,'/', DIR(j).name], 4000); 
    figure; 
    displaySpecgramQuick(song(fs*1.5:fs*2.6),fs); hold on
    ind = []; 
    for i = 1:size(segs,1)
        ind = [ind segs(i,1):segs(i,2)];
        plot([segs(i,1)/fs1 segs(i,2)/fs1], [6000 6000], 'r', 'linewidth', 6)
    end
    sound(song(fs*1.5:fs*2.6),fs)
end

%% plot picked songs and intro notes
figure
j = 2;
[song1,fs1] = wavread([pathname,'/', DIR(j).name]);fs1;
song = resample(song1,fs,fs1);
segs = Syllable_segment_Emily([pathname,'/', DIR(j).name], 4000); 
st=.45*fs/fs1; fin = 1.95*fs/fs1;
song = song(st*fs:fin*fs);
subplot(2,1,1)
displaySpecgramQuick(song,fs); hold on
ind = [];
for i = 1:size(segs,1)
    ind = [ind segs(i,1):segs(i,2)];
    plot([segs(i,1)/fs1-st segs(i,2)/fs1-st], [6000 6000], 'r', 'linewidth', 6)
    %syl{j}{i} = song(segs(i,1):segs(i,2));
end
xlim([0 fin-st]); title('SONG 1')
sound(song,fs)
wavwrite(song,fs, 'Song1')

j = 6;
[song1,fs1] = wavread([pathname,'/', DIR(j).name]);fs1;
song = resample(song1,fs,fs1);
segs = Syllable_segment_Emily([pathname,'/', DIR(j).name], 4000); 
st=.8*fs/fs1; fin = 3.05*fs/fs1;
song = song(st*fs:fin*fs);
subplot(2,1,2);
displaySpecgramQuick(song,fs); hold on
ind = [];
for i = 1:size(segs,1)
    ind = [ind segs(i,1):segs(i,2)];
    plot([segs(i,1)/fs1-st segs(i,2)/fs1-st], [6000 6000], 'r', 'linewidth', 6)
    %syl{j}{i} = song(segs(i,1):segs(i,2));
end
xlim([0 fin-st]); title('SONG 2')
sound(song,fs)
wavwrite(song,fs,'Song2')
set(gcf, 'papersize', [5 4], 'paperposition', [0 0 5 4])
saveas(gcf, 'Song1and2.pdf')


figure; 
j = 7;
[song1,fs1] = wavread([pathname,'/', DIR(j).name]);fs1;
song = resample(song1,fs,fs1);
segs = Syllable_segment_Emily([pathname,'/', DIR(j).name], 4000); 
st=.9*fs/fs1; fin = 2.5*fs/fs1;
song = song(st*fs:fin*fs);
subplot(2,1,1);
displaySpecgramQuick(song,fs); hold on
ind = [];
for i = 1:size(segs,1)
    ind = [ind segs(i,1):segs(i,2)];
    plot([segs(i,1)/fs1-st segs(i,2)/fs1-st], [6000 6000], 'r', 'linewidth', 6)
    %syl{j}{i} = song(segs(i,1):segs(i,2));
end
xlim([0 fin-st]);title('SONG 3')
sound(song,fs)
wavwrite(song,fs,'Song3')

j = 8;
[song1,fs1] = wavread([pathname,'/', DIR(j).name]);fs1;
song = resample(song1,fs,fs1);
segs = Syllable_segment_Emily([pathname,'/', DIR(j).name], 4000); 
st=4.6*fs/fs1; fin = 6.2*fs/fs1;
song = song(st*fs:fin*fs);
subplot(2,1,2);
displaySpecgramQuick(song,fs); hold on
ind = [];
for i = 1:size(segs,1)
    ind = [ind segs(i,1):segs(i,2)];
    plot([segs(i,1)/fs1-st segs(i,2)/fs1-st], [6000 6000], 'r', 'linewidth', 6)
    %syl{j}{i} = song(segs(i,1):segs(i,2));
end
xlim([0 fin-st]); title('SONG 4')
sound(song,fs)
wavwrite(song,fs,'Song4')
set(gcf, 'papersize', [5 4], 'paperposition', [0 0 5 4])
saveas(gcf, 'Song3and4.pdf')

%intros...
figure; 
subplot(2,1,1)
[song1,fs1] = wavread([pathname,'/', DIR(6).name]);fs1;
song = resample(song1,fs,fs1);
displaySpecgramQuick(song(1:fs*.85),fs); hold on
title('INTRO 1')
sound(song(1:fs*.85),fs)
wavwrite(song(1:fs*.85),fs,'Intro1')
subplot(2,1,2)
[song1,fs1] = wavread([pathname,'/', DIR(5).name]);fs1;
song = resample(song1,fs,fs1);
displaySpecgramQuick(song(1:fs*.6),fs); hold on
title('INTRO 2')
sound(song(1:fs*.6),fs)
wavwrite(song(1:fs*.6),fs,'Intro2')
set(gcf, 'papersize', [5 4], 'paperposition', [0 0 5 4])
saveas(gcf, 'Intro1and2.pdf')

%%
[SONG1,fs] = wavread('Song1');fs
[SONG2,fs] = wavread('Song2');fs
[INTRO,fs] = wavread('Intro1');fs
NOintro = zeros(size(INTRO));

PlayData1 = ...
    [[INTRO; SONG1] [NOintro; SONG1]];

PlayData2 = ...
    [[NOintro; SONG2] [INTRO; SONG2]];

% start playing the songs...
g = 2;
for j = 1:4
    for i = 1:10
        sound(PlayData1(:,g),fs)
        pause(3)
    end
    'skipping pause'
    %pause(3*30);
    for i = 1:10
        sound(PlayData2(:,g),fs)
        pause(3)
    end
    'skipping pause'
    %pause(3*30);
end

