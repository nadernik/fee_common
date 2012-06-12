function figure_learning_width_vs_lman(do_simulations)
stretches = logspace(1, -2, 150);
N = 200;
DEBUG_FLAG = 0;
maxlag = 50;

%%
if exist('do_simulations', 'var') && (do_simulations == 1)

    randomized_order = randperm(length(stretches));
    nrun = 0;
    for n = randomized_order
        nrun = nrun +1;
        fprintf(1, 'Run %g of %g\n', nrun, length(stretches))
        save temp n stretches randomized_order nrun
        
        % run simulation
        xmodel_parameters_caf
        xmodel_initialize
        for u = 1:lman_units % for each channel, stretch lman noise
            lman_noise(u, :, :) = generate_lman_noise_streched_spectrum(motif_steps, total_motifs, stretches(n));
        end
        xmodel_run
        
        save(['c:\stetner\data\figures\xmodel\temporal_resolution_lman\mes010\' int2str(n)])
        clear all
        load temp
    end
end

%%
total_files = length(stretches);
width_lman = nan(total_files,1);
width_learning = nan(total_files, 1);

for n = 1:total_files
    n
    filename = ['c:\stetner\data\figures\xmodel\temporal_resolution_lman\mes010\' int2str(n) '.mat'];
    if exist(filename, 'file')
        d = load(filename);
        bias = zeros(d.motif_steps, d.total_motifs);
        for motif = 1:d.total_motifs
            bias(:, motif) = d.weights_on_ra_from_lman*d.weights_on_lman_from_dlm*d.weights_on_dlm_from_pallidus*d.pallidal_output(:,:,motif);
        end
        [c, lags] = autocorrelation_by_columns(squeeze(d.lman_noise(1,:,:)), maxlag);
        acorr_lman = mean(c, 2);
        %[c, lags] = autocorrelation_by_columns(bias(:,end-N:end), maxlag);
        %acorr_learning = mean(c, 2);
        try
        width_lman(n) = fwhm(acorr_lman);
        width_learning(n) = fwhm(bias(:,end));
        catch
            width_lman(n) = nan;
            width_learning(n) = nan;
        end
        
        if DEBUG_FLAG
            figure(1)
            plot(lags, acorr_lman)
            hold all
            plot(lags, acorr_learning)
            y = mean(bias,2);
            plot((1:d.motif_steps)- d.motif_steps/2, y/max(y))
            plot((1:length(d.rkernel)) - length(d.rkernel)/2, d.rkernel/max(d.rkernel))
            legend({'lman', 'learning', 'bias', 'reward'})
            hold off
            
            figure(2)
            imagesc(bias')
            
            pause
        end
    end
end

figure(406)
clf
scatter(width_lman, width_learning, 500, '.')
set(gca, 'FontSize', 16)
xlabel('LMAN width')
ylabel('Learning width')
hold on
plot(xlim, ones(2,1) * fwhm(d.rkernel), 'k')
setticklimx([0,40])
setticklimy([0, 20])
keyboard