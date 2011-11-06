clear all
figure(405)
clf
hold all
N = 200;
DEBUG_FLAG = 0;
total_files = 150;
width_lman = nan(total_files,1);
width_learning = nan(total_files, 1);
width_reward = nan(total_files, 1);
maxlag = 200;
for n = 1:total_files
    n
    filename = ['c:\stetner\data\figures\xmodel\temporal_resolution_lman' int2str(n) '.mat'];
    if exist(filename, 'file')
        d = load(filename);
        bias = zeros(d.motif_steps, d.total_motifs);
        for motif = 1:d.total_motifs
            bias(:, motif) = d.weights_on_ra_from_lman*d.weights_on_lman_from_dlm*d.weights_on_dlm_from_pallidus*d.pallidal_output(:,:,motif);
        end
        [c, lags] = autocorrelation_by_columns(squeeze(d.lman_noise(1,:,:)), maxlag);
        acorr_lman = mean(c, 2);
        [c, lags] = autocorrelation_by_columns(bias(:,end-N:end), maxlag);
        acorr_learning = mean(c, 2);
        width_lman(n) = fwhm(acorr_lman);
        width_learning(n) = fwhm(acorr_learning);
        [c, lags] = autocorrelation_by_columns(d.reward, maxlag);
        acorr_reward = mean(c, 2);
        width_reward(n) = fwhm(acorr_reward);
        if DEBUG_FLAG
            plot(acorr_lman)
            hold all
            plot(acorr_learning)
            plot(mean(bias,2))
            legend({'lman', 'learning', 'bias'})
            hold off
        end
    end
end

figure(406)
clf
plot(width_lman, width_learning, 'x', 'MarkerSize', 10)
hold on
plot(width_lman, width_reward, '--r')