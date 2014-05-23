% making songs with and without intro notes
%%
clear all; close all; 
cd ~/../../Volumes/emackev
pathname = 'MI_newTutor/c*';
DIR1 = dir(pathname); 

bird = DIR1(3).name;
fullPathname = [pathname(1:end-1), num2str(bird(2:end)), '/',...
    '*.wav'];
DIR = dir(fullPathname)
DIR = DIR(3:end);

[song,fs] = wavread([fullPathname(1:end-5), '18_400806006_9_24_14_25_0.wav']);
displaySpecgramQuick(song, fs)
sound(song,fs)
%%
INTROS=song(.75*fs:1.8*fs); sound(INTROS,fs);
SILENCE=song(3.6*fs:end); sound(SILENCE,fs);
figure; 

subplot(3,1,1)
[BELLS,bellsfs]=wavread('OferSongs/bells.wav'); % use fs=40000, bc that's what I'm recording at
%sound(BELLS,bellsfs)
displaySpecgramQuick(BELLS,fs)
sound(BELLS,fs) 

subplot(3,1,2)
[SIMPLE]=wavread('OferSongs/simple.wav'); % use fs=40000, bc that's what I'm recording at
SIMPLE = SIMPLE(.2*fs:end)/max(abs(SIMPLE));%simple is very quiet
displaySpecgramQuick(SIMPLE,fs);
sound(SIMPLE,fs)

subplot(3,1,3)
[SAMBA,bellsfs]=wavread('OferSongs/samba.wav'); % use fs=40000, bc that's what I'm recording at
displaySpecgramQuick([SAMBA;SAMBA],fs);
sound([SAMBA;SAMBA],fs) 

%%
Songs = {SIMPLE SAMBA BELLS};

for i = 1:length(Songs)
    PlusIntros = [INTROS; Songs{i}; SILENCE(1:.5*fs); INTROS(.75*fs:end); Songs{i}; SILENCE(1:.5*fs); INTROS(.75*fs:end); Songs{i}];
    figure; displaySpecgramQuick(PlusIntros,fs);
    sound(PlusIntros,fs);
end
