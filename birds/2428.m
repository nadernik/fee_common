%% 2011-05-28
% First day of singing after isolation
ii = 1;
expers{ii} = loadExper('2428', '2011-05-27', 'c:\stetner\data');
Bout_detect_TO(expers{ii}.dir, expers{ii}.audioCh, [])
combine_boutfiles([expers{ii}.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments % color lim to 17 24
Batch_song_rhythm('2428','2011-05-27',1)
% Looks subsong. I want to record him for one more day though using the TDT
% microphone amplifyer. Right now he is on the Aardvark and the sound
% quality is not great. There is a loud low pitch hiss.

%% 2011-05-29
% Switched to TDT microphone amplifier. Missed first few hours of singing
% (until 00:30) because microphone did not have battery and TDT amp does
% not give phantom power. I set recording thresholds very low to make sure
% to capture everything.
ii = 1;
expers{ii} = loadExper('2428', '2011-05-28', 'c:\stetner\data');
Bout_detect_TO(expers{ii}.dir, expers{ii}.audioCh, [])
combine_boutfiles([expers{ii}.dir filesep 'bouts\analysis_bout.mat'])
Parse_segments % color lim to 17 24
% Very little singing :(
Batch_song_rhythm('2428','2011-05-28',1)
% Distributions are very noisy. I will let him sing for one more day so I
% can get one full day of singing before lesion.

% New settings for aquisitionGui:
%   Song Density: 0.4
%   Power Thres:  1
%   Song Length:  0.5

%% 2011-05-30
% No singing :(

%% 2011-05-31
Parse_segments
files = [18:67, 143:146, 167:185, 188]; % these are all the files with singing from yesterday
Batch_song_rhythm('2428','2011-05-30', 1, files)
% Wait one more day. GOF = 1.9, but rhythmicity looks exponential.

%% 2011-06-01
% No singing

%% 2011-06-02
Parse_segments
files = [49:84, 105:149, 164:194];
Batch_song_rhythm('2428','2011-06-01', 1, files)
% Syllable distribution is not so exponential, but there is also no clear
% protosyllable peak. Rhythmicity still looks exponential. Lesion today.

%% 2011-06-09

% first singing post surgery on 6/3
Parse_segments
Batch_song_rhythm('2428','2011-06-03', 1, 1:125)

% 6/8
Parse_segments
Batch_song_rhythm('2428','2011-06-08', 1, 1:100)

%% 2012-05-28
bird_dir = 'c:\stetner\data\mman lesion\2428';
start_day = datenum(2011, 06, 03);
end_day = start_day + 9;

for day = start_day:end_day
    data_dir = fullfile(bird_dir, datestr(day, 'yyyy-mm-dd'));
    bouts_dir = fullfile(data_dir, 'bouts');
    if exist(bouts_dir, 'dir')
        fprintf('%s already exists. Skipping to next day...\n', bouts_dir)
    else
        fprintf('Now detecting bouts in %s...\n', data_dir)
        load(fullfile(data_dir, 'exper.mat'), 'exper')
        Bout_detect_TO(data_dir, exper.audioCh, [])
    end
end

%%
% 2011-06-03 already done
% 2011-06-04 1:150
% 2011-06-05 1:150
% 2011-06-06 1:155
% 2011-06-07 1:150
% 2011-06-08 already done
% 2011-06-09 1:150
% 2011-06-10 1:150
% 2011-06-11 1:150
% 2011-06-12 1:150

%%

bird_dir = 'c:\stetner\data\mman lesion\2428';
dbase_file = 'bouts\analysis_selected.mat';
category = 10; % for Batch_song_rhythm.m

% Find directories for this bird
d = subdirs(bird_dir);
for ii = 1:length(d)
    filename = fullfile(bird_dir, d(ii).name, dbase_file);
    eg_repair_dbase_dir(filename)
    switch d(ii).name
        case '2011-06-03'
            filenums = 1:125;
            Batch_song_rhythm(filename, category, filenums)
        case '2011-06-08'
            filenums = 1:100;
            Batch_song_rhythm(filename, category, filenums)
        otherwise
            filenums = 1:150;
            Batch_song_rhythm(filename, category, filenums)
    end
end