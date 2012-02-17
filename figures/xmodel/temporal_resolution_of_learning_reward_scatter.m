datapath = 'c:\stetner\data\figures\xmodel\';
for ii = 1:11
    for run = 1:3
        filename = sprintf('%stemporal_resolution_reward_shortnoise%.0f_%.0f.mat', datapath, ii, run)
        load(filename);
        xmodel_calculate_bias;
        is_baseline = (1:total_motifs) <= baseline_motifs;
        baseline_escapes = squeeze(ra_output(1,:, is_baseline & is_escape));
        [c, lags] = autocorrelation_by_columns(squeeze(lman_noise(1,:,:)), 20);
        lman_autocorrelation = mean(c, 2);
        learning = bias(:,end) / max(bias(:,end));
        fwhm_learning(run, ii) = fwhm(learning);
        fwhm_lman(run, ii)     = fwhm(lman_autocorrelation);
        fwhm_reward(run,ii)    = fwhm(rkernel);
        fwhm_escapes(run,ii)   = fwhm(mean(baseline_escapes,2));
    end
end

figure
scatter(fwhm_reward(:), fwhm_learning(:))
xlabel('Reward width (ms)')
ylabel('Learning width (ms)')
hold on
plot(fwhm_reward(:), fwhm_lman(:), 'Color', [0 .6 0])

figure
sembyfactor(fwhm_learning(:), fwhm_reward(:))
xlabel('Reward width (ms)')
ylabel('Learning width (ms)')
hold on
plot(fwhm_reward(:), fwhm_lman(:), 'Color', [0 .6 0])