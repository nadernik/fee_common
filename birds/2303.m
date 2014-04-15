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

%% 2011-05-23
Bout_detect_SAP_TO('C:\stetner\data\2303\2307')
Bout_detect_SAP_TO('C:\stetner\data\2303\2312')
Parse_segments %2307
% arg! need to sort in electrogui because there are prominent inspiratory
% syllables
electro_gui
% aggressively removing intro notes (e.g. file 6)
Batch_song_rhythm('2303','2307',1,1:50)

% 2312
electro_gui
Batch_song_rhythm('2303','2312',1,1:50)

%% 2012-05-25
bird_dir = 'c:\stetner\data\mman lesion\2303';

for day = 2260:2272
    data_dir = fullfile(bird_dir, int2str(day));
    bouts_dir = fullfile(data_dir, 'bouts');
    if exist(bouts_dir, 'dir')
        fprintf('%s already exists. Skipping to next day...\n', bouts_dir)
    else
        fprintf('Now detecting bouts in %s...\n', data_dir)
        Bout_detect_SAP_TO(data_dir)
    end
end

%%

% 2263 First singing after surgery (already analyzed)
% 2264 Already analyzed
% 2265 Already analyzed
% 2266 1:200
% 2267 1:200 
% 2268 Already analyzed
% 2269 1:200
% 2270 1:200
% 2271 (already analyzed)
% 2272 1:200

%%
bird_dir = 'c:\stetner\data\mman lesion\2303';
dbase_file = 'bouts\analysis_selected.mat';
category = 10; % for Batch_song_rhythm.m

% Find directories for this bird
d = subdirs(bird_dir);
for ii = 1:length(d)
    filename = fullfile(bird_dir, d(ii).name, dbase_file);
    eg_repair_dbase_dir(filename)
    switch d(ii).name
        case {'2263', '2264', '2265'}
            Batch_song_rhythm(filename, category); % all files
        case {'2268', '2271'}
            filenums = 1:400;
            Batch_song_rhythm(filename, category, filenums)
        otherwise
            filenums = 1:200;
            Batch_song_rhythm(filename, category, filenums)
    end
end