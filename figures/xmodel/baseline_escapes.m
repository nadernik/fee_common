% BASELINE_ESCAPES baseline motifs and RPE, colored by escape/hit

filename = 'c:\stetner\data\figures\xmodel\temporal_resolution_lman49.mat';
escape_color = [.6 0 0]; % red
hit_color = [0 0 0]; % black
plot_fraction = 0.4; % only plot this fraction of baseline motifs
xmax = 400;

d = load(filename);
is_plot = (1:d.total_motifs) <= d.baseline_motifs & rand(1, d.total_motifs) < plot_fraction;
song = squeeze(d.ra_output(1, :, is_plot));
rpe = d.reward(:, is_plot) - d.expected_reward(:, is_plot);
is_escape = d.is_escape(is_plot); % 1=>escape, 0=>hit


figure

a(1) = subplot(2,1,1);
plot(song(:, ~is_escape), 'Color', hit_color, 'LineWidth', 2)
hold on
plot(song(:, is_escape), 'Color', escape_color, 'LineWidth', 2)
ylabel('\Delta Pitch (Hz)')
xlabel('Time (ms)')
title('Baseling song, color coded by escape/hit')
xlim([0 xmax])

a(2) = subplot(2,1,2);
plot(rpe(:, ~is_escape), 'Color', hit_color, 'LineWidth', 2)
hold on
plot(rpe(:, is_escape), 'Color', escape_color, 'LineWidth', 2)
ylabel('RPE (arbitrary units)')
xlabel('Time (ms)')
title('Reward Prediction Error')
xlim([0 xmax])