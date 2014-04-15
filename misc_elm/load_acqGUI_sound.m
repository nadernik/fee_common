dir = 'C:/users/emackev/Documents/MATLAB/AcqGUI/';
bird = '3746';
exper = '2013-06-26';
num =268; 

exp = loadExper(bird, exper, dir); 
exp.dir = [fullfile(dir, bird, exper) '\'];

audio = loadAudio(exp, num); 
fs = exp.desiredInSampRate;
audio = audio(fs*1.3:fs*2.95);
%% display sound
figure; 
h = subplot(211);
displaySpecgramQuick(audio, fs)
g = subplot(212);
plot(1/fs:1/fs:size(audio)/fs, audio); xlabel('Time (s)'); ylabel('sound amplitude')
linkaxes([h g], 'x')
sound(audio, fs)
set(gcf, 'papersize', [8 6], 'paperposition', [0 0 8 6])

Name = 'temp1'
saveas(gcf, ['C:\Users\emackev\Downloads\', Name, '.pdf']); 
wavwrite(audio/max(abs(audio)), fs, ['C:\Users\emackev\Downloads\', Name, '.wav'])
%% vocode sound
orig_dur = length(orig_sound)/fs; 
desired_dur = 1/7;

desired_sound = pvoc(orig_sound, orig_dur/desired_dur, 200); 

displaySpecgramQuick(desired_sound, fs)
sound(desired_sound,fs)