%% 2011-03-26

% Yesterday was the first day he sang.
files = 455:481;
Batch_song_rhythm('2303','2011-03-25',1,files);

% Small bumps in syllable pattern. Let him sing today and lesion tomorrow.

%% 2011-03-31
Bout_detect_SAP_TO('C:\stetner\data\2303\2260')
Bout_detect_SAP_TO('C:\stetner\data\2303\2261')
clos
%Tiny bump yesterday. Do lesion today.

%% 2011-04-04

% Day of surgery (2261)

% 1 day post surgery (DPS), no singing

% 2 DPS
Bout_detect_SAP_TO('C:\stetner\data\2303\2263')
Parse_segments
Batch_song_rhythm('2303','2263',1);

% (3) 2011-04-03
Bout_detect_SAP_TO('C:\stetner\data\2303\2264')
Parse_segments
Batch_song_rhythm('2303','2264',1);

%% 2011-04-05

% 4 dps
Bout_detect_SAP_TO('C:\stetner\data\2303\2265')
Parse_segments
Batch_song_rhythm('2303','2265',1);

%% 2011-04-08

Bout_detect_SAP_TO('C:\stetner\data\2303\2268')
Parse_segments % only looked at files 1:400
Batch_song_rhythm('2303','2268',1,1:400);
% Protosyllable peak!



%% 2011-04-11
Bout_detect_SAP_TO('C:\stetner\data\2303\2271')
Parse_segments % only looked at files 1:400
Batch_song_rhythm('2303','2271',1,1:400);

%% 2011-04-14
Bout_detect_SAP_TO('C:\stetner\data\2303\2274')
Parse_segments
Batch_song_rhythm('2303','2274',1,1:200);

%% 2011-04-18
Bout_detect_SAP_TO('C:\stetner\data\2303\2278')
Parse_segments
Batch_song_rhythm('2303','2278',1,1:200);

%% 2011-04-21
Bout_detect_SAP_TO('C:\stetner\data\2303\2281')
Parse_segments
Batch_song_rhythm('2303','2281',1,1:205);

%% 2011-04-27
Bout_detect_SAP_TO('C:\stetner\data\2303\2287')
% In the past I have just taken the first 200-300 files, but this may be
% biased because I am only getting the morning singing on most days. Maybe
% I should take some from beginning and some from the end? But he always
% seems to sing a similar number of files so I will just keep on doing what
% i have been doing.
Parse_segments
% File 29 lots of intro notes, 80, 85
% Made an effort to exclude intro notes that were not embedded in song.
Batch_song_rhythm('2303','2287',1,1:200);

%% 2011-05-02
Bout_detect_SAP_TO('C:\stetner\data\2303\2292')
Parse_segments
% A lot of intro notes! tried to exclude most of them.
Batch_song_rhythm('2303','2292',1,1:200);

%% 2011-05-08
Bout_detect_SAP_TO('C:\stetner\data\2303\2297')
Parse_segments
% lots of intro notes see file 3. long stacks interpsersed with song like
% file 184
Batch_song_rhythm('2303','2297',1,1:200);

%% 2011-05-12
Bout_detect_SAP_TO('C:\stetner\data\2303\2302')
Parse_segments
% motif in file 3?
% inspirations are being counted as syllables 
electro_gui
% sorted in electrogui so i could zoom in and make sure to exclude
% inspiratory syllables
Batch_song_rhythm('2303','2302',1,49:101)