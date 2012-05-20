load('C:\stetner\data\figures\xmodel\temporal_resolution_reward9.mat')
colors.hits = 'r';
colors.escapes = 'g';
colors.before = 'k';
colors.after = 'm';
N = 200;

is_before = (1:total_motifs) <= N;
is_after = (1:total_motifs) > total_motifs-N;

% pitch traces before learning
figure
a(1) = subplot(4,1,1);
hold on
plot(squeeze(ra_output(1,:,is_before & ~is_escape)), 'Color', colors.hits)
plot(squeeze(ra_output(1,:,is_before & is_escape)), 'Color', colors.escapes)
plot(mean(ra_output(1,:,is_before), 3), ':', 'Color', colors.before,'LineWidth', 3)

% eligibility trace across all MSNs in positive lman channel
% assume that across all MSNs, the sum of hvc activity is 1
for motif = 1:baseline_motifs
    etrace(:, motif) = conv(lman_output(1, :, motif), ekernel);
end
rtrace = reward(:,1:baseline_motifs) - expected_reward(:,1:baseline_motifs);
baseline_is_escape = is_escape(1:baseline_motifs);
a(2) = subplot(4, 1, 2);
hold on
plot(etrace(:, ~baseline_is_escape), 'Color', colors.hits)
plot(etrace(:, baseline_is_escape), 'Color', colors.escapes)
a(3) = subplot(4,1,3);
hold on
plot(rtrace(:, ~baseline_is_escape), 'Color', colors.hits)
plot(rtrace(:, baseline_is_escape), 'Color', colors.escapes)



% pitch traces after learning
a(4) = subplot(4,1,4)
hold on
plot(squeeze(ra_output(1,:,is_after & ~is_escape)), 'Color', colors.hits)
plot(squeeze(ra_output(1,:,is_after & is_escape)), 'Color', colors.escapes)
plot(mean(ra_output(1,:,is_after), 3), ':', 'Color', colors.after,'LineWidth', 3)

linkaxes(a, 'x')
xlim([0 size(etrace, 1)])

% histograms before/after
bin_centers = -19.5:1:19.5;
figure
counts = hist(squeeze(ra_output(1,caf_target_time2,is_before)),bin_centers);
stairs(bin_centers, counts, 'Color', colors.before,'LineWidth', 3)
hold on
counts = hist(squeeze(ra_output(1,caf_target_time2,is_after)),bin_centers);
stairs(bin_centers, counts, 'Color', colors.after,'LineWidth', 3)

%% 
