birdname = '2469';
expername_pre = '2011-09-05';
expername_post = '2011-09-07';
target_region = [.090 .092]; % seconds
N = 100; % number of syllables in each group (i.e. last N syllables before surgery compared to first N syllables after)

vcdb_pre = anno2vcdb(birdname, expername_pre);
cluster_pre = getsf(vcdb_pre, 'imported cluster');
vcdb_pre = vc_feat_mean(vcdb_pre, 'pitch', 'Name', 'target mean pitch', 'Range', target_region, 'RangeUnits', 'seconds');
vcdb_pre = vc_feat_std(vcdb_pre, 'pitch', 'Name', 'target std pitch', 'Range', target_region, 'RangeUnits', 'seconds');

mask_pre = (cluster_pre == 2) | (cluster_pre == 4);
mean_pitch_pre = getsf(vcdb_pre, 'target mean pitch', mask_pre);
std_pitch_pre = getsf(vcdb_pre, 'target std pitch', mask_pre);

% Remove outliers (pitch is more than 2 standard deviations from mean)
while true
    z = zeros(size(mask_pre));
    old_mask = mask_pre;
    z(old_mask) = zscore(mean_pitch_pre);
    mask_pre = mask_pre & abs(z) < 3;

    % Remove outliers (std_pitch is more than 2 standard deviations from mean)
    z(old_mask) = zscore(std_pitch_pre);
    mask_pre = mask_pre & abs(z) < 3;

    if all(old_mask == mask_pre)
        break
    end

    mean_pitch_pre = getsf(vcdb_pre, 'target mean pitch', mask_pre);
    std_pitch_pre = getsf(vcdb_pre, 'target std pitch', mask_pre);
end

% Finally, take only the last 100 renditions of the target syllable before
% surgery
mask_pre = mask_pre & cumsum(mask_pre) >= sum(mask_pre)-N;
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

vcdb_post = anno2vcdb(birdname, expername_post);
cluster_post = getsf(vcdb_post, 'imported cluster');
mask_post = (cluster_post == 2) | (cluster_post == 4);
vcdb_post = vc_feat_mean(vcdb_post, 'pitch', 'Name', 'target mean pitch', 'Range', target_region, 'RangeUnits', 'seconds');
vcdb_post = vc_feat_std(vcdb_post, 'pitch', 'Name', 'target std pitch', 'Range', target_region, 'RangeUnits', 'seconds');
mean_pitch_post = getsf(vcdb_post, 'target mean pitch', mask_post);
std_pitch_post = getsf(vcdb_post, 'target std pitch', mask_post);


while true
    % Remove outliers (pitch is more than three standard deviations from mean)
    z = zeros(size(mask_post));
    old_mask = mask_post;
    z(old_mask) = zscore(mean_pitch_post);
    mask_post = mask_post & abs(z) < 3;

    % Remove outliers (std_pitch is more than 3 standard deviations from mean)
    z(old_mask) = zscore(std_pitch_post);
    mask_post = mask_post & abs(z) < 3;
    
    if all(old_mask == mask_post)
        break
    end
    
    mean_pitch_post = getsf(vcdb_post, 'target mean pitch', mask_post);
    std_pitch_post = getsf(vcdb_post, 'target std pitch', mask_post);
end

% Finally, take only the last 100 renditions of the target syllable before
% surgery
mask_post = mask_post & cumsum(mask_post) <= N; % first N
mean_pitch_post = getsf(vcdb_post, 'target mean pitch', mask_post);
std_pitch_post = getsf(vcdb_post, 'target std pitch', mask_post);

pp = {'FaceColor', 'r', 'FaceAlpha', 0.5};
axes(a1)
sfhist(vcdb_post, 'target mean pitch', 'Mask', mask_post, 'BinWidth', 5, 'PatchProperties' , pp)
xlabel('Mean pitch')
axes(a2)
sfhist(vcdb_post, 'target std pitch', 'Mask', mask_post, 'BinWidth', 1, 'PatchProperties' , pp)
xlabel('Std pitch')

disp('all numbers are mean +/- std')
fprintf(1, 'mean pitch before = %g +/- %g\n', nanmean(mean_pitch_pre), nanstd(mean_pitch_pre))
fprintf(1, 'mean pitch after  = %g +/- %g\n', nanmean(mean_pitch_post), nanstd(mean_pitch_post))
fprintf(1, 't test null hypothesis rejected? %g\n', ttest2(mean_pitch_pre, mean_pitch_post))
fprintf(1, 'std pitch before = %g +/- %g\n', nanmean(std_pitch_pre), nanstd(std_pitch_pre))
fprintf(1, 'std pitch after  = %g +/- %g\n', nanmean(std_pitch_post), nanstd(std_pitch_post))
fprintf(1, 't test null hypothesis rejected? %g\n', ttest2(std_pitch_pre, std_pitch_post))

% all numbers are mean +/- std
% mean pitch before = 734.719 +/- 11.2603
% mean pitch after  = 731.746 +/- 10.0959
% t test null hypothesis rejected? 0
% std pitch before = 2.0223 +/- 1.61098
% std pitch after  = 1.68903 +/- 1.47088
% t test null hypothesis rejected? 0