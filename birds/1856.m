%% 2011-10-10
% First day of CAF will be today!
annotate_exper('1856', '2011-10-09', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9)
vectorClust
% "polygons 2011-10-09.mat"
%   1 = escapes
labeledspecgram('1856', '2011-10-09')
rules
% 1364 +/- 18.2 Hz (median +/- std)
% NOTE! he stutters the target syllable at the end of each motif

%% 2011-10-11
annotate_exper('1856', '2011-10-10', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9)
% only sang 47 files :(
% continue with same filters
vectorClust
% "polygons 2011-10-10.mat"
%   1 = escapes
%   2 = hits
cafplots('1856', '2011-10-10', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-10\cafplots_vcdb.mat')

% calculate % hit over whole night
load('c:\stetner\data\1856\2011-10-10\cafplots_vcdb.mat')
pcthit = sum(handles.vcdb.d.cn ==2) / sum(handles.vcdb.d.cn ~=-1)
% 77.7% hit. make filters a little more relaxed and continue

%% 2011-10-12
annotate_exper('1856', '2011-10-11', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9)
vcQuickCluster('1856', '2011-10-11', 'c:\stetner\data\1856\polygons 2011-10-10.mat', [])
cafplots('1856', '2011-10-11', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-11\cafplots_vcdb.mat')
% not enough singing. continue with the same filters

%% 2011-10-13
labeledspecgram('1856', '2011-10-12')
% only 7 files! jerk! actually acquisitionGui reset at 1am

%% 2011-10-14
labeledspecgram('1856', '2011-10-13')
% 148 files, clustering good.
cafplots('1856', '2011-10-13', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-13\cafplots_vcdb.mat')

% compare last 200 of 10/13 with the last 200 of 10/11
n = 200;

load('c:\stetner\data\1856\2011-10-11\cafplots_vcdb.mat');
is_hit_or_escape = handles.vcdb.d.cn == 1 | handles.vcdb.d.cn == 2;
lastn = cumsum(is_hit_or_escape) > (sum(is_hit_or_escape) - n);
pitch_before = getsf(handles.vcdb, 'pitchtarg', is_hit_or_escape & lastn);
clear handles

load('c:\stetner\data\1856\2011-10-13\cafplots_vcdb.mat');
is_hit_or_escape = handles.vcdb.d.cn == 1 | handles.vcdb.d.cn == 2;
lastn = cumsum(is_hit_or_escape) > (sum(is_hit_or_escape) - n);
pitch_after = getsf(handles.vcdb, 'pitchtarg', is_hit_or_escape & lastn);
clear handles

figure
bins = min(min(pitch_before), min(pitch_after)):5:max(max(pitch_before), max(pitch_after));
n1 = histc(pitch_before, bins);
stairs(bins, n1, 'b')
hold on
n2 = histc(pitch_after, bins);
stairs(bins, n2, 'r')

pitch_difference = mean(pitch_after) - mean(pitch_before);
did_learn = ttest2(pitch_before, pitch_after, .01, 'right')
% Did learn! -15 Hz!
% Push down again!

%% 2011-10-15
labeledspecgram('1856', '2011-10-14')
cafplots('1856', '2011-10-14', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-14\cafplots_vcdb.mat')

annotate_exper('1856', '2011-10-15', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'filenum', 1:87)
vcQuickCluster('1856', '2011-10-15', 'c:\stetner\data\1856\polygons 2011-10-10.mat', [])
cafplots('1856', '2011-10-15', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-15\cafplots_vcdb.mat')

%% 2011-10-17
labeledspecgram('1856', '2011-10-16')
cafplots('1856', '2011-10-16', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-16\cafplots_vcdb.mat')
% compare last 200 of 10/13 with the last 200 of 10/16
n = 200;

load('c:\stetner\data\1856\2011-10-13\cafplots_vcdb.mat');
is_hit_or_escape = handles.vcdb.d.cn == 1 | handles.vcdb.d.cn == 2;
lastn = cumsum(is_hit_or_escape) > (sum(is_hit_or_escape) - n);
pitch_before = getsf(handles.vcdb, 'pitchtarg', is_hit_or_escape & lastn);
clear handles

load('c:\stetner\data\1856\2011-10-16\cafplots_vcdb.mat');
is_hit_or_escape = handles.vcdb.d.cn == 1 | handles.vcdb.d.cn == 2;
lastn = cumsum(is_hit_or_escape) > (sum(is_hit_or_escape) - n);
pitch_after = getsf(handles.vcdb, 'pitchtarg', is_hit_or_escape & lastn);
clear handles

figure
bins = min(min(pitch_before), min(pitch_after)):5:max(max(pitch_before), max(pitch_after));
n1 = histc(pitch_before, bins);
stairs(bins, n1, 'b')
hold on
n2 = histc(pitch_after, bins);
stairs(bins, n2, 'r')

pitch_difference = mean(pitch_after) - mean(pitch_before)
did_learn = ttest2(pitch_before, pitch_after, .01, 'right')

% -17 Hz (did learn)
% now reverse and push up for 2 days

rules

%% 2011-10-18
labeledspecgram('1856', '2011-10-17')
cafplots('1856', '2011-10-17', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-17\cafplots_vcdb.mat')
rules

%% 2011-10-19
labeledspecgram('1856', '2011-10-18')
cafplots('1856', '2011-10-18', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-18\cafplots_vcdb.mat')
% Learned again. ready to lesion, but i don't have time today. push up one
% more time just for fun and lesion tomorrow
rules

%% 2011-10-20
labeledspecgram('1856', '2011-10-19')
cafplots('1856', '2011-10-19', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.040 .042], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\1856\2011-10-19\cafplots_vcdb.mat')
