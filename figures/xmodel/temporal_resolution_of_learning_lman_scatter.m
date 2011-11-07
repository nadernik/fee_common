% Scatter plot of LMAN autocorrelation width vs. learning width

N = 200; % average bias from this many motifs at the end to calculate learning
DEBUG_FLAG = 0; % set to 1 to see extra plots
total_files = 150;
width_lman = nan(total_files,1);
width_learning = nan(total_files, 1);
width_reward = nan(total_files, 1);
maxlag = 200;
for n = 1:total_files
    filename = ['c:\stetner\data\figures\xmodel\temporal_resolution_lman' int2str(n) '.mat'];
    if exist(filename, 'file')
        fprintf('File number %03.f of %03.f -- analyzing...\n',n,total_files)
        d = load(filename);
        bias = zeros(d.motif_steps, d.total_motifs);
        for motif = 1:d.total_motifs
            bias(:, motif) = d.weights_on_ra_from_lman*d.weights_on_lman_from_dlm*d.weights_on_dlm_from_pallidus*d.pallidal_output(:,:,motif);
        end
        [c, lags] = autocorrelation_by_columns(squeeze(d.lman_noise(1,:,:)), maxlag);
        acorr_lman = mean(c, 2);
        %[c, lags] = autocorrelation_by_columns(bias(:,end-N:end), maxlag);
        %acorr_learning = mean(c, 2);
        learning = mean(bias(:,end-N:end), 2);
        learning = learning / max(learning);
        width_lman(n) = fwhm(acorr_lman);
        width_learning(n) = fwhm(learning);
        width_reward(n) = fwhm(d.rkernel);
        if DEBUG_FLAG
            plot(acorr_lman)
            hold all
            plot(acorr_learning)
            plot(mean(bias,2))
            legend({'lman', 'learning', 'bias'})
            hold off
        end
    else
        fprintf('File number %03.g of %03.g -- skipping (file does not exist)\n',n,total_files)
    end
end

figure(406)
clf
plot(width_lman, width_learning, 'x', 'MarkerSize', 10)
hold on
plot(width_lman, width_reward, '--r')