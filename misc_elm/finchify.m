clc; clear all; close all
% song templates
[snd0,fs1] = audioread('Z:\emackev\Tutors\SimpleTutor.wav');
snd1 = snd0(5500:9000); 
% [snd0,fs1] = audioread('C:\Users\emackev\Documents\taskhost_3832\Capture_148a30.wav');
% snd1 = snd0(:,1); 
% [snd0,fs1] = audioread('C:\Users\emackev\Downloads\DPurple141_d000004_20150113T110117chan4.wav');
% snd1 = snd0(127100:133900); 
% snd1 = snd0(40000:80000); 
nSmoothEnding = min(length(snd1), .3*fs1); 
snd1((end-nSmoothEnding+1):end) = ...
    snd1((end-nSmoothEnding+1):end).*...
    (cos((1:nSmoothEnding)/nSmoothEnding*pi)'/2+.5);

% load song 
[snd2,fs2] = audioread('C:\Users\emackev\Downloads\wwyamc.wav');
snd2 = snd2(:,1);
% [snd2,fs2] = audioread('C:\Users\emackev\Downloads\NN2015.wav');
% snd2 = snd2((5*60+56)*fs2:(6*60+20)*fs2,1);

fs = min(fs1,fs2); 
sndA = interp1((1:length(snd1))/fs1, snd1, (1:length(snd1)/fs1*fs)/fs)'; 
sndB = interp1((1:length(snd2))/fs2, snd2, (1:length(snd2)/fs2*fs)/fs)'; 

DT = .01; 
TimeA = (1:length(sndA)/DT/fs)*DT; 

[pitchA, aperiodicityA] = fun_pitch(sndA,fs,TimeA); 
mpA = median(pitchA(~isnan(pitchA))); %
soundsc(sndA,fs)
%%
TimeB = (1:length(sndB)/DT/fs)*DT; 

[pitch, aperiodicity] = fun_pitch(snd2,fs2,TimeB); 
% plot(Time,pitch/max(pitch(:)))
% hold on
% plot(Time,aperiodicity); 
Thres = .1; 
% find neg and pos aperiodicity crossings, to use as syllable boundaries
aperiodicity = smooth(aperiodicity,5); 
aperiodicity(aperiodicity<=0) = Thres/10; 
Offs = find(aperiodicity(1:end-1)<Thres & aperiodicity(2:end)>Thres); 
Ons = find(aperiodicity(1:end-1)>Thres & aperiodicity(2:end)<Thres); 
if Offs(1)<Ons(1); Offs(1) = []; end
% initialize the artificial song
Asong = sndB*0; 

% for each syllable
for syli = 1:min(length(Ons), length(Offs)); 
    % shift the pitch and duration of the finch syllable
    desPitch = median(pitch(Ons(syli):Offs(syli)))*2; 
    desDur = (Offs(syli)-Ons(syli))*fs*DT/2;
    intDur = desDur*desPitch/mpA; % intermediate duration so warping it will create the right pitch shift and duration
    intSnd = pvoc(sndA, length(sndA)/intDur); 
    intSnd(end:intDur) = 0; 
    intSnd(intDur:end) = []; 
    shifted = interp1(1:intDur, intSnd, (1:desDur)*intDur/desDur);
    nSmoothEnding = min(length(shifted), 1*DT*fs); 
    shifted((end-nSmoothEnding+1):end) = ...
        shifted((end-nSmoothEnding+1):end).*...
        (cos((1:nSmoothEnding)/nSmoothEnding*pi)/2+.5);
    % place the shifted finch syllable in the artificial song
    Asong(Ons(syli)*fs*DT + (1:desDur)) = shifted; 
end
sound(Asong,fs);

audiowrite('C:\Users\emackev\Downloads\tmp.wav', [Asong(:) sndB],fs)

%%
[snd3,fs3] = audioread('C:\Users\emackev\Downloads\ENN.wav');
snd3 = snd3((32)*fs2:end,1);
audiowrite('C:\Users\emackev\Downloads\MerryChristmasGGFromEandBirds.wav', [[snd3 snd3]; [Asong(:) sndB]],fs)
