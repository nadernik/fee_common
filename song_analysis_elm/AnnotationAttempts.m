birdname = '3292';
expername = '2012-11-24';

% Find good segmentation parameters
annotate_exper(birdname, expername, 'bDebug', true, 'filenum', 5)

%% Test new segmentation parameters
annotate_exper(birdname, expername, 'bDebug', true, 'filenum', 55, 'triggerSyllThreshold', -5, 'edgeSyllThreshold', -9) 
% looks good!

%% Annotate ALL THE FILES
%for most birds: annotate_exper(birdname, expername, 'triggerSyllThreshold', -5, 'edgeSyllThreshold', -9, 'filenum', 1:50) 
%for 3292:
annotate_exper(birdname, expername, 'triggerSyllThreshold', -5, 'edgeSyllThreshold', -8, 'filenum', 1:50)
%%
vectorClust

%% electrogui can read audio files and save them in a format that
%% vectorClust can read.  Click new, then select the folder, and the
%% filename and WaveRead.  Then set the filter to just low frequencies, and
%% set thresholds for good syllable segments.  Save the segmented
%% electrogui version of SongOne and SongTwo, then open in vectorclust

electro_gui
%% now, open in vectorclust, (make sure to click include deselected) and save them as vectorClust databases.
vectorClust

%%
% Electrogui and vectorclust each save their own fileformats, and have their own
% set of fileformats that they can import and export. Electrogui can import
% wavfiles, and vectorClust can import electogui files.  Vectorclust saves
% a variable called vcdb.  After loading this file: 
allsfnames(vcdb); % lists what you can get, e.g. duration
getsf(vcdb, 'duration'); % returns, e.g., durations
%'keys' is a unique key for each sylable. 

%%

vcdb_files = {'3291_2012-11-24_vcdb.mat', '3289_2012-11-24_vcdb.mat','songone_vcdb.mat', 'songtwo_vcdb.mat'};
colors = jet(4);
figure; hold all
for i = 1:4
    load(vcdb_files{i})
    Dur{i} = getsf(vcdb, 'duration');
    PG{i} = getsf(vcdb, 'mean_pitchGoodness');
    plot(Dur{i}, PG{i}, '.','color', colors(i,:));
end






