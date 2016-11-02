pathname = 'Z:\emackev\InsightsSongs\PinesOfRomeNightingale\';
filename = 'PinesOfRomeNightingale.wav'

[song,fs] = audioread(fullfile(pathname, filename)); 
song = song(:,1); % 1 channel

filedur = 10; % 10 sec
fstarts = 1:(filedur)*fs:length(song); % start times of new files

for fi = 1:length(fstarts)
    s = song(fstarts(fi):min((fstarts(fi)+filedur*fs), end)); 
    audiowrite(fullfile(pathname,['split' num2str(fi) '.wav']), s, fs)
end