
%% making new songs
%clear all; %close all
%syllable library
path = 'C:\Users\emackev\Documents\MATLAB\OferSongs';
[bells,fs] = wavread(fullfile(path, 'bells')); 
[simple,fs] = wavread(fullfile(path, 'simple')); 
[intros, fs] = wavread(fullfile(path, 'Intro1'));

%set parameters
SongLength = round(2.5*fs); 
cosramp = round(.005*fs); 
Gap = round(.03*fs);
NoGaps = 0;
Flattened = 0; 
IMotifI = round(.1*fs);
scalefactor = 20;
normalizeSyls = 1;

A = bells(.675*fs:.747*fs);
C = bells(.242*fs:.301*fs);
D = bells(.34*fs:.384*fs);
B = simple(1.076*fs:1.195*fs);
I0 = [intros(3000:6750)]
I2 = [zeros(size(I0,1)-Gap, size(I0,2)*.7); I0];
I = [zeros(size(I0,1)-Gap, size(I0,2)); I0];
D = bells(.34*fs:.384*fs);

D = I0;
Ddur = length(D)/fs;

nSyl = 30; 
meanDur = .1;
meanGDur = .05;

durs = exprnd(meanDur, 1, nSyl);
Gaps = exprnd(meanGDur, 1, nSyl);

Song = [];
for i = 1:nSyl
    Song = [Song; pvoc(D, Ddur/durs(i), 200); zeros(fs*Gaps(i),1)];
end

sound(Song,fs)
%displaySpecgramQuick(Song,fs)
