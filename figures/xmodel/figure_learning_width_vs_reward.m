function figure_learning_width_vs_reward(do_simulations)
kernel_widths = 0.25:0.25:15;
maxlag = 20;

%%
if exist('do_simulations', 'var') && (do_simulations == 1)
    for n = 1:length(kernel_widths)
        fprintf(1, 'Run %g of %g\n', n, length(kernel_widths))

        % Run simulation
        xmodel_parameters_caf
        std_rkernel = kernel_widths(n); % change width of reward
        std_etrace  = kernel_widths(n); % change width of eligibility trace to match reward
        xmodel_initialize
        xmodel_run

        % Clean up and save results
        save(['c:\stetner\data\figures\xmodel\temporal_resolution_reward_' int2str(n)])
        save temp n kernel_widths
        clear all
        load temp
    end
end

%%
for n = 1:length(kernel_widths)
    n
    d = load(['c:\stetner\data\figures\xmodel\temporal_resolution_reward_' int2str(n)]);
    
    % Calculate learning as the width of bias on the last motif
    bias = zeros(d.motif_steps, d.total_motifs);
    for motif = 1:d.total_motifs
        bias(:, motif) = d.weights_on_ra_from_lman*d.weights_on_lman_from_dlm*d.weights_on_dlm_from_pallidus*d.pallidal_output(:,:,motif);
    end
    width_learning(n) = fwhm(bias(:,end));

    % Width of autocorrelation of LMAN fluctuations
    [c, lags] = autocorrelation_by_columns(squeeze(d.lman_noise(1,:,:)), maxlag);
    acorr_lman = mean(c, 2);
    width_lman(n) = fwhm(acorr_lman);
    
    % Width of reward is the full width at half max of the reward kernel
    width_reward(n) = fwhm(d.rkernel);
    
end

figure
scatter(width_reward, width_learning, 500, '.')
hold on
plot(xlim, mean(width_lman)*ones(2,1),'-k')
set(gca, 'FontSize', 16)
xlabel('Reward width (ms)')
ylabel('Learning width (ms)')
setticklimx([0,40])
setticklimy([0, 20])


save('c:\stetner\data\figures\xmodel\learning_width_vs_reward.mat', 'width_reward', 'width_learning', 'width_lman')

