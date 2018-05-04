%% 2011-08-11

annotate_exper('2442', '2011-08-10', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'filenum', 700:931)
vectorClust
% Cluster 1 = escapes
deglitchpitch('2442', '2011-08-10')
rules
% Tested on files 897-931, 59% hit (N=82)
% Tested a few files in MATLAB, no false positives.
% Saved rules to c:\stetner\data\2442\2011-08-11\rules.mat
% 1050-

%% 2011-08-12

annotate_exper('2442', '2011-08-11', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-11', 'c:\stetner\data\2442\polygons 2011-08-11.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-11')
cafplots('2442', '2011-08-11', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.105 .110], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-11\cafplots_vcdb.mat')
% Learned.
% Update filters.
% 1010-
%% 2011-08-15
annotate_exper('2442', '2011-08-12', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
annotate_exper('2442', '2011-08-13', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
annotate_exper('2442', '2011-08-14', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-12', 'c:\stetner\data\2442\polygons 2011-08-11.mat', [], 'root', 'c:\stetner\data')
vcQuickCluster('2442', '2011-08-13', 'c:\stetner\data\2442\polygons 2011-08-11.mat', [], 'root', 'c:\stetner\data')
vcQuickCluster('2442', '2011-08-14', 'c:\stetner\data\2442\polygons 2011-08-11.mat', [], 'root', 'c:\stetner\data')
cafplots('2442', '2011-08-12', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.105 .110], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-12\cafplots_vcdb.mat')
% maybe learning?

cafplots('2442', '2011-08-13', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.105 .110], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-13\cafplots_vcdb.mat')
% no learning

cafplots('2442', '2011-08-14', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.105 .110], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-14\cafplots_vcdb.mat')
% Escaping with bad pitch goodness. Need to take a day off to hopefully
% recover.

%% 2011-08-16

% New rules
% 1070+
% 68% hit (N=146) tested onm files 1193-1234 from 2011-08-15

%% 2011-08-17
annotate_exper('2442', '2011-08-16', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-16', 'c:\stetner\data\2442\polygons 2011-08-16.mat', [], 'root', 'c:\stetner\data')
% Note! These new polygons exclude syllables that do not have high pitch
% goodness in target region. Bird could be learning by making pitch less
% good and I would miss it. Need to check for that.
cafplots('2442', '2011-08-16', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-16\cafplots_vcdb.mat')
% Learning

% Made new filters
% pushing 1098+
% tested on files 1090-1150 in 2011-08-16
% hit 67% (N=181) of escapes

%% 2011-08-18
annotate_exper('2442', '2011-08-17', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-17', 'c:\stetner\data\2442\polygons 2011-08-16.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-17')
cafplots('2442', '2011-08-17', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-17\cafplots_vcdb.mat')
% Learned again
% Lesion today

%% 2011-08-22
% Yesterday (2011-08-21) was first singing after surgery
annotate_exper('2442', '2011-08-21', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vectorClust
% Clustered with 'polygons 2011-08-16.mat'. The polygons still fit.
labeledspecgram('2442', '2011-08-21')
% Looks good. See that I got one call as an escape in file 343. More in
% file 263.
% See if I can get rid of calls in vectorClust
vectorClust
% 'polygons 2011-08-22.mat' tightened up duration x mean_pitch polygon.
% calls have shorter duration and lower mean pitch.
labeledspecgram('2442', '2011-08-21', 343)
labeledspecgram('2442', '2011-08-21', 263)
% All better :)

%% find mean and standard deviation of pitch at target time pre and post
% surgery
target_region = [.090 .092]; % seconds

vcdb_pre = anno2vcdb('2442', '2011-08-17');
cluster_pre = getsf(vcdb_pre, 'imported cluster');
mask_pre = (cluster_pre == 1);
mask_pre = mask_pre & cumsum(mask_pre) >= sum(mask_pre)-100; % last 100
vcdb_pre = vc_feat_mean(vcdb_pre, 'pitch', 'Name', 'target mean pitch', 'Range', target_region, 'RangeUnits', 'seconds');
vcdb_pre = vc_feat_std(vcdb_pre, 'pitch', 'Name', 'target std pitch', 'Range', target_region, 'RangeUnits', 'seconds');
mean_pitch_pre = getsf(vcdb_pre, 'target mean pitch', mask_pre);
std_pitch_pre = getsf(vcdb_pre, 'target std pitch', mask_pre);
pp = {'FaceColor', 'b', 'FaceAlpha', 0.5};
figure(1)
sfhist(vcdb_pre, 'target mean pitch', 'Mask', mask_pre, 'BinWidth', 5, 'PatchProperties' , pp)
a1 = gca;
figure(2)
sfhist(vcdb_pre, 'target std pitch', 'Mask', mask_pre, 'BinWidth', 1, 'PatchProperties' , pp)
a2 = gca;


clear vcdb_pre % to save memory
hold(a1, 'on')
hold(a2, 'on')

vcdb_post = anno2vcdb('2442', '2011-08-21');
cluster_post = getsf(vcdb_post, 'imported cluster');
mask_post = (cluster_post == 1);
mask_post = mask_post & cumsum(mask_post) <= 100; % first 100
vcdb_post = vc_feat_mean(vcdb_post, 'pitch', 'Name', 'target mean pitch', 'Range', target_region, 'RangeUnits', 'seconds');
vcdb_post = vc_feat_std(vcdb_post, 'pitch', 'Name', 'target std pitch', 'Range', target_region, 'RangeUnits', 'seconds');
mean_pitch_post = getsf(vcdb_post, 'target mean pitch', mask_post);
std_pitch_post = getsf(vcdb_post, 'target std pitch', mask_post);
pp = {'FaceColor', 'r', 'FaceAlpha', 0.5};
axes(a1)
sfhist(vcdb_post, 'target mean pitch', 'Mask', mask_post, 'BinWidth', 5, 'PatchProperties' , pp)
xlabel('Mean pitch')
axes(a2)
sfhist(vcdb_post, 'target std pitch', 'Mask', mask_post, 'BinWidth', 1, 'PatchProperties' , pp)
xlabel('Std pitch')

% throw out outliers (more than 3 standard deviations from mean)
z = zscore(mean_pitch_pre);
mean_pitch_pre(abs(z) > 3) = NaN;
z = zscore(mean_pitch_post);
mean_pitch_post(abs(z) > 3) = NaN;
z = zscore(std_pitch_pre);
std_pitch_pre(abs(z) > 3) = NaN;
z = zscore(std_pitch_post);
std_pitch_post(abs(z) > 3) = NaN;

disp('all numbers are mean +/- std')
fprintf(1, 'mean pitch before = %g +/- %g\n', nanmean(mean_pitch_pre), nanstd(mean_pitch_pre))
fprintf(1, 'mean pitch after  = %g +/- %g\n', nanmean(mean_pitch_post), nanstd(mean_pitch_post))
fprintf(1, 't test null hypothesis rejected? %g\n', ttest2(mean_pitch_pre, mean_pitch_post))
fprintf(1, 'std pitch before = %g +/- %g\n', nanmean(std_pitch_pre), nanstd(std_pitch_pre))
fprintf(1, 'std pitch after  = %g +/- %g\n', nanmean(std_pitch_post), nanstd(std_pitch_post))
fprintf(1, 't test null hypothesis rejected? %g\n', ttest2(std_pitch_pre, std_pitch_post))

% all numbers are mean +/- std
% mean pitch before = 1145.71 +/- 23.1206
% mean pitch after  = 1113.73 +/- 13.2724
% t test null hypothesis rejected? 1
% std pitch before = 4.25606 +/- 3.56074
% std pitch after  = 3.21271 +/- 2.57917
% t test null hypothesis rejected? 1

% Using same rules as on 2011-08-17
% 1098+
% tested on files 301-343 of 2011-08-21: 65% hit (N=210)

%% 2011-08-23
annotate_exper('2442', '2011-08-22', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vectorClust % clusters from yesterday look good.
vcQuickCluster('2442', '2011-08-22', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-22')
cafplots('2442', '2011-08-22', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-22\cafplots_vcdb.mat')
% Looks like no learning. continue with same rules, one more day.

%% 2011-08-24
annotate_exper('2442', '2011-08-23', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-23', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-23')
cafplots('2442', '2011-08-23', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-23\cafplots_vcdb.mat')
% Not learning. Getting hit about 80% of time. Adjust so there are slightly
% fewer hits and continue one more day.
rules
% 1088+ 
% 61% hit (N=74) based on files 513-553 in exper 2011-08-23

%% 2011-08-25
annotate_exper('2442', '2011-08-24', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-24', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-24')
cafplots('2442', '2011-08-24', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 100, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-24\cafplots_vcdb.mat')
% no learning. reverse direction.

rules

%% 2011-08-26
annotate_exper('2442', '2011-08-25', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
% Only sang 100 files. Not enough to judge learning.

% Changed filters after file 6 and again after file 61 because I was
% hitting 100% of syllables

% See percent hit and maybe adjust pitch filter
vcQuickCluster('2442', '2011-08-25', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-25')
% Clustering looks good.
cafplots('2442', '2011-08-25', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-25\cafplots_vcdb.mat')
% looks like the middle of the pitch distribution is around 1090 Hz.
% New filters: 1088-

%% 2011-08-27
annotate_exper('2442', '2011-08-26', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-26', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-26')
cafplots('2442', '2011-08-26', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 50, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-26\cafplots_vcdb.mat')

%% 2011-08-29
annotate_exper('2442', '2011-08-27', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
annotate_exper('2442', '2011-08-28', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-28', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-28')
cafplots('2442', '2011-08-28', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-28\cafplots_vcdb.mat')
% Percent hit decreases, but pitch doesn't seem to change. Do CAF for one
% more day. Maybe adjust filters so there are less hits.

% was pushing 1088- now pushing 1092-

%% 2011-08-30
annotate_exper('2442', '2011-08-29', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9, 'fMinSyllDuration', .05, 'maxFilesPerAnnotation', 400)
vcQuickCluster('2442', '2011-08-29', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-29')
% bad segmentation
annotate_exper('2442', '2011-08-29', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -7.5)
vcQuickCluster('2442', '2011-08-29', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-29')
cafplots('2442', '2011-08-29', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-29\cafplots_vcdb.mat')

%% 2011-08-31
annotate_exper('2442', '2011-08-30', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -7.5)
vcQuickCluster('2442', '2011-08-30', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-30')
cafplots('2442', '2011-08-30', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-30\cafplots_vcdb.mat')

% 1082-
% Tested on files 810-856: (.35*84 + 55)/(55+84)=61% hit

%% 2011-09-01
annotate_exper('2442', '2011-08-31', 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -7.5)
vcQuickCluster('2442', '2011-08-31', 'c:\stetner\data\2442\polygons 2011-08-22.mat', [], 'root', 'c:\stetner\data')
labeledspecgram('2442', '2011-08-31')
cafplots('2442', '2011-08-31', ...
    'HitCluster', 2, ...
    'EscapeCluster', 1, ...
    'Range', [.090 .092], ...
    'RangeUnits', 'seconds', ...
    'LastN', 200, ...
    'SaveVcdb', 'c:\stetner\data\2442\2011-08-31\cafplots_vcdb.mat')

