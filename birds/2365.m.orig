%%
% MMAN Lesion
% Is MMAN required for the song rhythmicity that develops at the end of
% subsong? Lesion MMAN just after rhythmicity starts to develop and see if:
% (1) Existing rhythmicity disappears, implying that MMAN is storing
%       rhythmicity "bias"
% (2) Further rhytmicity does not develop, implying that MMAN is required
%       for learning rhythmicity.
% Isolate while in subsong and analyze song daily to look for rhythmicity
% developing using analysis code written by Tatsuo. A day or two after
% rhythmicity is visible, lesion MMAN and continue analyzing rhythmicity
% every few days.
%
% Need objective measure for when to lesion
% How long to track?

%% 2011-04-30
Bout_detect_SAP_TO('C:\stetner\data\2365\2289')
Parse_segments
Batch_song_rhythm('2365','2289',1, 1:200)
% subsong. good singer!

%% 2011-05-02
Bout_detect_SAP_TO('C:\stetner\data\2365\2292')
Parse_segments
Batch_song_rhythm('2365','2292',1, 1:200)
% Plastic song!
% GOF is 0.87847
% Lesion today!

%% 2011-05-04
exper = loadExper('2365', '2011-05-03', 'c:\stetner\data');
Bout_detect_TO(exper.dir, exper.audioCh, [])
combine_boutfiles([exper.dir filesep 'bouts\analysis.mat'])
Parse_segments
% Sometimes segmenting is bad because some syllables are only high
% frequencies (none in 1k to 4kHz which is used for segmentation). Example:
% syllable 'i' in file 120
Batch_song_rhythm('2365','2011-05-03',1)

%% 2011-05-07
exper = loadExper('2365', '2011-05-06', 'c:\stetner\data');
Bout_detect_TO(exper.dir, exper.audioCh, [])
combine_boutfiles([exper.dir filesep 'bouts\analysis.mat'])
Parse_segments

%% 2011-05-09
exper = loadExper('2365', '2011-05-08', 'c:\stetner\data');
combine_boutfiles([exper.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments
Batch_song_rhythm('2365','2011-05-08',1, 1:160)
% analysis looks like subsong, but when i listened to his song i DEFINITELY
% heard protosyllables

%% 2011-05-23

% acquisitionGui crashed, so I didn't get data on:
%   2011-05-10
%   2011-05-11
%   2011-05-12
%   2011-05-13
%   2011-05-14
%   2011-05-15
%   2011-05-19
%   2011-05-21

% In 2011-05-16 there is data through 5/18 because I forgot to restart acquisitionGui

% 2011-05-22 computer hard drive filled up so I only have recordings from
% the beginning of the night.

Parse_segments %2011-05-16
% motif? file 18
% chaining calls? file 19 -- in almost every file
% part of high pitched syllable is not segmented because it is outside 1-4
% kHz range. example in file 31
Batch_song_rhythm('2365','2011-05-16',1, 1:100)


exper = loadExper('2365', '2011-05-22', 'c:\stetner\data\')
Bout_detect_TO(exper.dir, exper.audioCh, [])
combine_boutfiles([exper.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments %2011-05-22
Batch_song_rhythm('2365','2011-05-22',1, 1:100)

%% 2011-05-28
Parse_segments
% Looks like he is developing normally, with a motif (file 12)
Batch_song_rhythm('2365','2011-05-27',1, 1:100)
