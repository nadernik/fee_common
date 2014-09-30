%%

%use intro notes 1
clear all; close all; 
%cd ~/../../Volumes/emackev
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
fs = 44100;

figure;
j = 1;
subplot(2,1,1)
[song1,fs1] = wavread([pathname,'/', DIR(j).name]);fs1;
song = resample(song1,fs,fs1);
A = song(fs*1.87:fs*2.65);
displaySpecgramQuick([A A],fs); hold on
xlabel('')
title('SONG 1')
sound([A A],fs)
wavwrite([A A], fs, 'SongOne')

fs = 40000
j = 8;
[song1,fs1] = wavread([pathname,'/', DIR(j).name]);fs1;
song = mean(song1,2);
song = resample(song1,fs,fs1);
st=4.6; fin = 6.2;
song = song(st*fs:fin*fs);
subplot(2,1,2);
displaySpecgramQuick(song,fs); hold on
title('SONG 2')
sound(song,fs)
wavwrite(song,fs,'SongTwo')

set(gcf, 'papersize', [5 4], 'paperposition', [0 0 5 4])
saveas(gcf, 'SongOneAndTwo.pdf')


figure; 
[song1,fs1] = wavread([pathname,'/', DIR(6).name]);fs1;
song = resample(song1,fs,fs1);
displaySpecgramQuick(song(1:fs*.85),fs); hold on
title('INTRO 1')
sound(song(1:fs*.85),fs)
wavwrite(song(1:fs*.85),fs,'Intro1')
