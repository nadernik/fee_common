dir = 'C:/users/emackev/Documents/MATLAB/AcqGUI/';
bird = '3765';
exper = '2013-06-06';
num = 28; 

exp = loadExper(bird, exper, dir); 
exp.dir = [fullfile(dir, bird, exper) '\'];

audio = loadAudio(exp, num); 
fs = exp.desiredInSampRate;
%% display sound
figure; 
displaySpecgramQuick(audio, fs)
sound(audio, fs)
%% vocode sound
orig_dur = length(orig_sound)/fs; 
desired_dur = 1/7;

desired_sound = pvoc(orig_sound, orig_dur/desired_dur, 200); 

displaySpecgramQuick(desired_sound, fs)
sound(desired_sound,fs)