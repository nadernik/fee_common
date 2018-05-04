
%% making new songs
%clear all; close all
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



% %decide order
% Syl{1} = A;
% Syl{2} = B;
% Syl{3} = C;
% Syl{4} = D; 

%decide order

Syl{1} = I;
Syl{2} = I; 
Syl{3} = I;
Syl{4} = I2; 
Syl{5} = A;
Syl{6} = B;
Syl{7} = C;
Syl{8} = D;
Syl{9} = D; 
Syl{10} = B; 
Syl{11} = D;
Syl{12} = B;


PrevOnset = 0; 
PrevDur = 0; 
Seed = zeros(numel(Syl), SongLength);
for syli = 1:numel(Syl)
    S = Syl{syli};
    if ~NoGaps
        OnsetS = PrevOnset+PrevDur+Gap;
    elseif syli ~= 1;
        OnsetS = PrevOnset+PrevDur-2*(cosramp);
    else
        OnsetS = 0;
    end
    PrevOnset = OnsetS; 
    PrevDur = numel(S);
    if normalizeSyls
        S2 = pvocnormalized(S,1,200);
        S = S*max(S2)/max(S);
    end
    window = [.5 - (cos(0:(pi/(cosramp)):pi)/2) ones(1,numel(S)-2*cosramp-2) ...
        .5+(cos(0:(pi/(cosramp)):pi)/2)]';
    Seed(syli,:) = [zeros(1, OnsetS) (S.*window)' zeros(1, (SongLength-OnsetS)-numel(S))];
end

All = sum(Seed);
All = All(1:PrevOnset+PrevDur);
if Flattened
    All = pvocnormalized(All, 1,200);
    All = All';
end
All = [zeros(1,IMotifI ) All zeros(1,IMotifI)];% All zeros(1,IMotifI)];
All = All*scalefactor;
All(1:.75*fs) = All(1:.75*fs)/2; %Just to make the intros softer
subplot(211)
plot(1/fs:1/fs:numel(All)/fs, All)
subplot(212)
displaySpecgramQuick(All,fs)
sound(All,fs)
shg


%% gapfreeing and flattening another song
close all; clear all

%to use purple song:
% path = 'C:\Users\emackev\Documents\MATLAB\Tutors';
% [song,fs] = wavread(fullfile(path, 'Purple40_3803_cage42_tutor.wav')); 
% load(fullfile(path, 'analysis_purple40'));%load(fullfile(path, 'analysis_simple_bp_860_8600'));

%to use simple song: 
path = 'C:\Users\emackev\Documents\MATLAB\OferSongs';
[song,fs] = wavread(fullfile(path, 'simple.wav')); 
load(fullfile(path, 'analysis_simple_bp_860_8600'));
%set syllables
%segment in electrogui, set high threshold so that you don't include any
%preonset gap (don't want to flatten up the noise)
segs = dbase.SegmentTimes{end}; 

for i = 1:size(segs,1)
    Syl{i} = song(segs(i,1):segs(i,2));
end

%set parameters
SongLength = round(2*fs); 
cosramp = round(.005*fs); 
Gap = round(.03*fs);
NoGaps = 1;
Flattened = 1; 
IMotifI = 0;%.1*fs;
scalefactor = 15;
normalizeSyls = 0; 
NMotifs = 2;

PrevOnset = 0; 
PrevDur = 0; 
Seed = zeros(numel(Syl), SongLength);
for syli = 1:numel(Syl)
    S = Syl{syli};
    if ~NoGaps
        OnsetS = PrevOnset+PrevDur+Gap;
    elseif syli ~= 1;
        OnsetS = PrevOnset+PrevDur-2*(cosramp);
    else
        OnsetS = 0;
    end
    PrevOnset = OnsetS; 
    PrevDur = numel(S);
    if normalizeSyls
        S2 = pvocnormalized(S,1,200);
        S = S*max(S2)/max(S);
    end
    window = [.5 - (cos(0:(pi/(cosramp)):pi)/2) ones(1,numel(S)-2*cosramp-2) ...
        .5+(cos(0:(pi/(cosramp)):pi)/2)]';
    Seed(syli,:) = [zeros(1, OnsetS) (S.*window)' zeros(1, (SongLength-OnsetS)-numel(S))];
end

All = sum(Seed(:,1:OnsetS));
All1 = All; 
for i = 1:NMotifs-1
    All1 = [All1 zeros(1,IMotifI) All];
end
All = All1;
%All = All(1:PrevOnset+PrevDur);
if Flattened
    All = pvocnormalized(All, 1,200);
    All = All';
end

All = All*scalefactor;
h = subplot(211);
plot(1/fs:1/fs:numel(All)/fs, All)
g = subplot(212);
displaySpecgramQuick(All,fs)
linkaxes([h g], 'x')
shg
sound(All,fs)

