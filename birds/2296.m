%% 2011-04-01
Bout_detect_SAP_TO('C:\stetner\data\2296\2260')
Parse_segments('c:\stetner\data\2296\2260\bouts\analysis.mat')
Batch_song_rhythm('2296','2260',1);
% No bump

Bout_detect_SAP_TO('C:\stetner\data\2296\2262')
Parse_segments('c:\stetner\data\2296\2262\bouts\analysis.mat')
Batch_song_rhythm('2296','2262',1)
% Still no bump

%% 2011-04-04
Bout_detect_SAP_TO('C:\stetner\data\2296\2264')
Parse_segments('c:\stetner\data\2296\2264\bouts\analysis.mat')
Batch_song_rhythm('2296','2264',1)
% STILL no protosyllable peak

%% 2011-04-05
Bout_detect_SAP_TO('C:\stetner\data\2296\2265')
Parse_segments
Batch_song_rhythm('2296','2265',1)
% Something around 5 Hz, but it should be lower freq. This is probably
% nothing. 

%% 2011-04-07
Bout_detect_SAP_TO('C:\stetner\data\2296\2267')
Parse_segments
Batch_song_rhythm('2296','2267',1)
% still nothing. what is wrong with this guy?!??!?!?!?

%% 2011-04-11

Bout_detect_SAP_TO('C:\stetner\data\2296\2271')
Parse_segments
Batch_song_rhythm('2296','2271',1)
% Still subsong.

%% 2011-04-13
Bout_detect_SAP_TO('C:\stetner\data\2296\2273')
Parse_segments
Batch_song_rhythm('2296','2273',1,1:402)
% Still subsong.

%% 2011-04-15
Bout_detect_SAP_TO('C:\stetner\data\2296\2275')
Parse_segments
Batch_song_rhythm('2296','2275',1)
% Maybe a small peak.

%% 2011-04-18
Bout_detect_SAP_TO('C:\stetner\data\2296\2278')
Parse_segments
Batch_song_rhythm('2296','2278',1, 1:300)
% No surgery yet.

%% 2011-04-19
Bout_detect_SAP_TO('C:\stetner\data\2296\2279')
Parse_segments
Batch_song_rhythm('2296','2279',1, 1:300)
% Do surgery NOW!

%% 2011-04-25
% First singing post surgery
Bout_detect_SAP_TO('C:\stetner\data\2296\2284') % hardly any singing
Bout_detect_SAP_TO('C:\stetner\data\2296\2285')
Parse_segments
Batch_song_rhythm('2296','2285',1)
% Syllable pattern rhythmicity is still strong even though the song does
% not sound rhythmic to my ear. Proto-syllable peak in duration
% distribution went away.

%% 2011-04-26
% Song looks like it got MORE rhythmic after surgery, but maybe that is
% because I didn not look at the song on the day of surgery:
Bout_detect_SAP_TO('C:\stetner\data\2296\2280')
Parse_segments
Batch_song_rhythm('2296','2280',1,1:200)
% Looks the same :(

% Try to see if sequence changes after lesion. Use vectorClust to pick out
% protosyllables.
vectorClust
% Okay so, cluster 2 is protosyllable that goes from 4kHz to harmonic stack
% around 500 Hz. Cluster 1 is any syllable that comes before 2 that is
% about 100 ms long. I know there is one more protosyllable, but I couldn't
% cluster it because it is not segmented reliably. This could be a problem
% because this syllable is definitely there even post lesion. 

% Applied these clusters to selected syllables from 2280 (pre lesion) and
% 2285 (post lesion). 

% Calculate proportion of syllable 2 preceded by syllable 1
% pre lesion
load('c:\stetner\data\2296\2280\vcdb.mat')
ones = sum(vcdb.d.cn == 1);
twos = sum(vcdb.d.cn == 2);
fprintf(1, '%g/%g = %g%% pre-lesion\n', ones, twos, ones/twos*100)
load('c:\stetner\data\2296\2285\vcdb.mat')
ones = sum(vcdb.d.cn == 1);
twos = sum(vcdb.d.cn == 2);
fprintf(1, '%g/%g = %g%% post-lesion\n', ones, twos, ones/twos*100)
% Results:
% 137/180 = 76.1111% pre-lesion
% 20/60 = 33.3333% post-lesion

%% 2011-04-30
Bout_detect_SAP_TO('C:\stetner\data\2296\2290')
Parse_segments
Batch_song_rhythm('2296','2290',1,1:200)

%% 2011-05-05
Bout_detect_SAP_TO('C:\stetner\data\2296\2295')
% Abnormal song. Very harmonic. See file 3, 17 (is this even song?)
% Much less singing than normal and when I changed his cage he didn't look
% too good. Feathers ruffled. Hopefully it was because he was low on food.
Parse_segments
Batch_song_rhythm('2296','2295',1)

%% 2011-05-12
Bout_detect_SAP_TO('C:\stetner\data\2296\2300')
Parse_segments
Batch_song_rhythm('2296','2300',1, 1:200)

%% 2011-05-20
Bout_detect_SAP_TO('C:\stetner\data\2296\2305')
Bout_detect_SAP_TO('C:\stetner\data\2296\2310')
Parse_segments
Batch_song_rhythm('2296','2305',1, 1:100)


%% 2011-05-22
Parse_segments
% Hard to tell what is singing (e.g. file 65)
Batch_song_rhythm('2296','2310',1, 1:150)
% did not make special effort to exclude intro notes because it was hard to
% tell where singing began
% Sac today. Bird does not look good. feathers ruffled
% s

%% 2012-05-25
% Analyze rhythmicity across days to make a figure for Michale to use as
% preliminary data in his grant. I need to analyze data from days -1 to 9
% where 0 is the first day that the goodness of fit of an exponential to
% the syllable duration distribution is >= 2. In MMAN lesion birds, use the
% day of lesion as day 0.

bird_dir = 'c:\stetner\data\mman lesion\2296';

for day = 2278:2294
    data_dir = fullfile(bird_dir, int2str(day));
    bouts_dir = fullfile(data_dir, 'bouts');
    if exist(bouts_dir, 'dir')
        fprintf('%s already exists. Skipping to next day...\n', bouts_dir)
    else
        fprintf('Now detecting bouts in %s...\n', data_dir)
        Bout_detect_SAP_TO(data_dir)
    end
end

Parse_segments

% 2285 First day singing post surgery (already analyzed)
% 2286 Stuttering single syllable, eg bout 125. Selected files 1:250
%      Unreliable segmentation of stuttered syllable eg bout 184
% 2287 1:250
% 2288 1:250
% 2289 1:250 
% 2290 (already analyzed)
% 2291 1:250
% 2292 1:250
% 2293 all (1:159)
% 2294 1:252

%%
bird_dir = 'c:\stetner\data\mman lesion\2296';
dbase_file = 'bouts\analysis_selected.mat';
category = 10; % for Batch_song_rhythm.m

% Find directories for this bird
d = subdirs(bird_dir);
for ii = 1:length(d)
    filename = fullfile(bird_dir, d(ii).name, dbase_file);
    eg_repair_dbase_dir(filename)
    switch d(ii).name
        case '2285'
            Batch_song_rhythm(filename, category); % all files
        case '2290'
            filenums = 1:200;
            Batch_song_rhythm(filename, category, filenums)
        case '2293'
            Batch_song_rhythm(filename, category); % all files
        otherwise
            filenums = 1:250;
            Batch_song_rhythm(filename, category, filenums)
    end
end