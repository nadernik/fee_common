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