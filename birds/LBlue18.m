%% LBlue 18 (Cage 44 tutor)

% Compare the distribution of syllables in feature space to his pupil with
% MMAN lesion. Show that in lesioned bird syllables are less distinct.

% Procedure:
% 1. Detect bouts
% 2. Sort bouts by hand
% 3. Import selected syllables from bouts into vectorClust
% 4. Find good clusters in the tutor bird
% 5. Repeat steps 1-3 for MMAN lesion bird
% 6. Calculate entropy in selected 2-D feature space for each bird
% 
% Need to do cage mates at the same age? Tutor could be more mature because
% he is more than 90 dph

%%

Bout_detect_SAP_TO('C:\stetner\data\tutors\Cage 44\LBlue18(current)\2084')
% 107 bouts detected

Parse_segments
% saved as analysis_selected.mat

vectorClust
% Best separation in duration x meanPitchGoodness
% saved to C:\stetner\data\tutors\Cage
% 44\LBlue18(current)\2084\bouts\vcdb.mat

%% Repeat in his pupil, last day recorded (5/22/11), 97 dph:
Bout_detect_SAP_TO('C:\stetner\data\mman lesion\2296\2313')
% 282 bouts detected

Parse_segments
% went through all bouts. saved results as C:\stetner\data\mman
% lesion\2296\2313\bouts\analysis_selected.mat

vectorClust
% saved C:\stetner\data\mman lesion\2296\2313\bouts\vcdb.mat

%% Repeat in a normal adult from the same tutor
% Liora control bird 2203 isolated at age 44. recording from when the bird
% was 95dph

datapath = 'C:\stetner\data\mman lesion\tutor-matched controls\2203 (cage 44, same as 2296)\2011-04-07';
d = load(fullfile(datapath, 'exper.mat'));
soundchan = d.exper.audioCh;
datachan = [];
Bout_detect_TO(datapath, soundchan, datachan)
% 436 bouts

Parse_segments
% manually selected syllables in bouts 1:200. saved as
% analysis_selected.mat

% only loaded selected syllables from bouts 1:200. saved as vcdb.mat
vectorClust

%%
% close all
tutordata = 'C:\stetner\data\tutors\Cage 44\LBlue18(current)\2084\bouts\vcdb.mat';
% controldata = 'C:\stetner\data\mman lesion\tutor-matched controls\2203 (cage 44, same as 2296)\2011-04-07\bouts\vcdb.mat';
lesiondata = 'C:\stetner\data\mman lesion\2296\2313\bouts\vcdb.mat';
feature_2d_entropy_comparison(tutordata, lesiondata, 'duration', 'mean_pitchGoodness')
