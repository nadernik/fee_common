%% 2011-03-26

% Yesterday was the first day he sang.
files = 455:481;
Batch_song_rhythm('2303','2011-03-25',1,files);

% Small bumps in syllable pattern. Let him sing today and lesion tomorrow.

%% 2011-03-31
Bout_detect_SAP_TO('C:\stetner\data\2303\2260')
Bout_detect_SAP_TO('C:\stetner\data\2303\2261')
Batch_song_rhythm('2303','2261',1,1:212);
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