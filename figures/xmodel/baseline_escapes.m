% BASELINE_ESCAPES baseline motifs and RPE, colored by escape/hit

filename = 'c:\stetner\data\figures\xmodel\temporal_resolution_lman49.mat';
escape_color = [.6 0 0]; % red
hit_color = [0 0 0]; % black

d = load(filename);
ind = 1:d.total_motifs < d.baseline_motifs & rand(1,d.total_motifs) < 0.3;
song = squeeze(d.ra_output(1, :, ind));
rpe = d.reward(:, ind) - d.expected_reward(:, ind);
is_escape = d.is_escape(ind); % 1=>escape, 0=>hit

for motif = 1:d.total_motifs
    bias(:, motif) = d.weights_on_ra_from_lman*d.weights_on_lman_from_dlm*d.weights_on_dlm_from_pallidus*d.pallidal_output(:,:,motif);
end

xmax = 400;

figure

a(1) = subplot(3,1,1);
plot(song(:, ~is_escape), 'Color', hit_color, 'LineWidth', 2)
hold on
plot(song(:, is_escape), 'Color', escape_color, 'LineWidth', 2)
ylabel('\Delta Pitch (Hz)')
xlabel('Time (ms)')
title('Song before learning')
xlim([0 xmax])

a(2) = subplot(3,1,2);
plot(rpe(:, ~is_escape), 'Color', hit_color, 'LineWidth', 2)
hold on
plot(rpe(:, is_escape), 'Color', escape_color, 'LineWidth', 2)
ylabel('RPE (arbitrary units)')
xlabel('Time (ms)')
title('Reward Prediction Error')
xlim([0 xmax])

a(3) = subplot(3,1,3);
plot(mean(bias(:,1:d.baseline_motifs), 2), 'Color', [0 0 0], 'LineWidth', 3)
hold on
plot(mean(bias(:,end-d.baseline_motifs:end), 2), 'Color', [.6 0 .6], 'LineWidth', 3)
title('Average song, before and after learning')
xlim([0 xmax])