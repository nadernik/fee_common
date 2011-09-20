load('C:\stetner\data\figures\xmodel\temporal_resolution_reward5.mat')
colors.hits = 'r';
colors.escapes = 'g';
colors.before = 'k';
colors.after = 'm';
N = 200;

is_before = (1:total_motifs) <= N;
is_after = (1:total_motifs) > total_motifs-N;

% pitch traces before learning
figure
hold on
plot(squeeze(ra_output(1,:,is_before & ~is_escape)), 'Color', colors.hits)
plot(squeeze(ra_output(1,:,is_before & is_escape)), 'Color', colors.escapes)
plot(mean(ra_output(1,:,is_before), 3), ':', 'Color', colors.before,'LineWidth', 3)

% pitch traces after learning
figure
hold on
plot(squeeze(ra_output(1,:,is_after & ~is_escape)), 'Color', colors.hits)
plot(squeeze(ra_output(1,:,is_after & is_escape)), 'Color', colors.escapes)
plot(mean(ra_output(1,:,is_after), 3), ':', 'Color', colors.after,'LineWidth', 3)

% histograms before/after
bin_centers = -19.5:1:19.5;
figure
counts = hist(squeeze(ra_output(1,caf_target_time2,is_before)),bin_centers);
stairs(bin_centers, counts, 'Color', colors.before,'LineWidth', 3)
hold on
counts = hist(squeeze(ra_output(1,caf_target_time2,is_after)),bin_centers);
stairs(bin_centers, counts, 'Color', colors.after,'LineWidth', 3)