% BASELINE_ESCAPES baseline motifs and RPE, colored by escape/hit

filename = 'c:\stetner\data\figures\xmodel\temporal_resolution_lman49.mat';
escape_color = [1 0 0]; % red
hit_color = [0 0 0]; % black

d = load(filename);
song = squeeze(d.ra_output(1, :, 1:d.baseline_motifs));
rpe = d.reward(:, 1:d.baseline_motifs) - d.expected_reward(:, 1:d.baseline_motifs);
is_escape = d.is_escape(1:d.baseline_motifs); % 1=>escape, 0=>hit
xmax = size(rpe, 1);

figure

a(1) = subplot(2,1,1);
plot(song(:, ~is_escape), 'Color', hit_color)
hold on
plot(song(:, is_escape), 'Color', escape_color)
ylabel('\Delta Pitch (Hz)')
xlabel('Time (ms)')
title('Baseling song, color coded by escape/hit')
xlim([0 xmax])

a(2) = subplot(2,1,2);
plot(rpe(:, ~is_escape), 'Color', hit_color)
hold on
plot(rpe(:, is_escape), 'Color', escape_color)
ylabel('RPE (arbitrary units)')
xlabel('Time (ms)')
title('Reward Prediction Error')
xlim([0 xmax])