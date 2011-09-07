%% 2011-06-17
exper = loadExper('2452', '2011-06-16', 'c:\stetner\data');
Bout_detect_TO(exper.dir, exper.audioCh, [])
combine_boutfiles([exper.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments

% files = 130:

% Singing is too quiet. Segmenting is bad and will not get a good estimate
% of rhythmicity. Increase gain on mic and try again tomorrow.

%% 2011-06-19
exper = loadExper('2452', '2011-06-17', 'c:\stetner\data');
Bout_detect_TO(exper.dir, exper.audioCh, [])
combine_boutfiles([exper.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments
% no singing :(

%% 2011-06-20

exper = loadExper('2452', '2011-06-19', 'c:\stetner\data');
Bout_detect_TO(exper.dir, exper.audioCh, [])
combine_boutfiles([exper.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments
% No singing again! WTF! I get tons of files filled with calls.

%% 2011-06-21
% Made recording settings really low (0.4/1/0.4) to catch everything! Also
% changed battery in the mic just in case
exper = loadExper('2452', '2011-06-20', 'c:\stetner\data');
Bout_detect_TO(exper.dir, exper.audioCh, [])
combine_boutfiles([exper.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments
% only sang ~10 files at the beginning. wtf. I am just going to inject
% virus instead of mman lesion.