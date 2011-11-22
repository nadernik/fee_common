clear all
figure(402)
clf
hold on
N=200;
d = load('c:\stetner\data\figures\xmodel\temporal_resolution_lman49.mat');
actual_learning = mean(-d.pallidal_output(1,:,end-N:end) + d.pallidal_output(2,:,end-N:end), 3);
actual_learning = actual_learning ./ max(actual_learning);
hvc_burst = d.hvc_output(1, 1:9);
reward_kernel = d.rkernel;

for motif = 1:d.total_motifs
    bias(:, motif) = d.weights_on_ra_from_lman*d.weights_on_lman_from_dlm*d.weights_on_dlm_from_pallidus*d.pallidal_output(:,:,motif);
end

maxlag = 100;
[c, lags] = autocorrelation_by_columns(squeeze(d.lman_noise(1,:,:)), maxlag);
lman_autocorrelation = mean(c, 2);

t_hvc = -4:4;
plot(t_hvc,hvc_burst, 'LineWidth', 3, 'Color', [.6 .6 0])
plot(lags,mean(lman_autocorrelation,2), 'LineWidth', 3, 'Color', [0 .6 0])
t_reward = -4*d.std_rkernel:4*d.std_rkernel;
plot(t_reward, reward_kernel,'Color', [0 0 .6], 'LineWidth', 3)
t_learning = (1:d.motif_steps) - d.caf_target_time2;
plot(t_learning,actual_learning,'LineWidth', 3, 'Color', [.6 0 .6])
