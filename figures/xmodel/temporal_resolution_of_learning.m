%% Temporal Resolution of Learning

%% many different LMAN values
stretches = logspace(1, -2, 150);
randomized_order = randperm(length(stretches));
nrun = 0;
for n = randomized_order
    nrun = nrun +1;
    fprintf(1, 'Run %g of %g\n', nrun, length(stretches))
    save temp n stretches randomized_order nrun
    xmodel_parameters_caf
    xmodel_initialize
    for u = 1:lman_units
        lman_noise(u, :, :) = generate_lman_noise_streched_spectrum(motif_steps, total_motifs, stretches(n));
    end
    xmodel_run
    save(['c:\stetner\data\figures\xmodel\temporal_resolution_lman\mes010\' int2str(n)])
    clear all
    load temp
end
    
%% different reward kernels
kernel_widths = [1 5 10 15 20 30 50 100 200 300 400];
for nrun = 1:10
for n = 1:length(kernel_widths)
    fprintf(1, 'Run %g of %g\n', n, length(kernel_widths))
    save temp n kernel_widths nrun
    xmodel_parameters_caf
    std_rkernel = kernel_widths(n);
    std_etrace  = kernel_widths(n);
    xmodel_initialize
    xmodel_run
    save(['c:\stetner\data\figures\xmodel\temporal_resolution_reward_shortnoise' int2str(n) '_' int2str(nrun)])
    clear all
    load temp
end
end
%% (a) Limit on the precision of learning
% Conditional auditory feedback targets a specific moment (1 ms in our
% simulation) for pitch change. The optimal solution is to change the pitch
% at just the target time, but this is not what happens. Our model allows
% the basal ganglia to bias 
filename = 'c:\stetner\data\figures\xmodel\temporal_resolution_lman\mes010\50.mat'; % example run from the middle of the range
d = load(filename);
N = 200;



%% (b) 

figure(402)
clf
hold on

actual_learning = mean(-d.pallidal_output(1,:,end-N:end) + d.pallidal_output(2,:,end-N:end), 3);
actual_learning = actual_learning ./ max(actual_learning);
hvc_burst = d.hvc_output(1, 1:9);
reward_kernel = d.rkernel;

maxlag = 100;
noise = squeeze(d.lman_noise(1,:,:) - d.lman_noise(2,:,:));
lman_autocorrelation = zeros(maxlag * 2 + 1, d.motif_steps);
for motif = 1:d.total_motifs
    [c, t_acor] = xcorr(noise(:, motif), maxlag, 'unbiased');
    lman_autocorrelation(:, motif) = c / max(c);
end

t_learning = (1:d.motif_steps) - d.caf_target_time2;
plot(t_learning,actual_learning,':m', 'LineWidth', 3)
t_hvc = -4:4;
plot(t_hvc,hvc_burst,'y', 'LineWidth', 3)
plot(t_acor,mean(lman_autocorrelation,2),'g', 'LineWidth', 3)
t_reward = -4*d.std_rkernel:4*d.std_rkernel;
plot(t_reward, reward_kernel./max(reward_kernel),'Color', [1, .65, 0], 'LineWidth', 3)


%%
figure(404)
clf
hold all

for n = 1:9
    n
    d = load(['c:\stetner\data\figures\xmodel\temporal_resolution_reward' int2str(n)]);
    actual_learning = mean(-d.pallidal_output(1,:,end-N:end) + d.pallidal_output(2,:,end-N:end), 3);
    actual_learning = actual_learning ./ max(actual_learning);
    plot(actual_learning)
    reward_std(n) = d.std_rkernel;
    abovehalf = actual_learning > 0.5;
    x1 = find(abovehalf, 1, 'first');
    x2 = d.caf_target_time2 - 1 + find(~abovehalf(d.caf_target_time2:end), 1,'first');
    fwhm(n) = t_learning(x2) - t_learning(x1);
    clear d
end
figure(403)
plot(reward_std, fwhm)

%% 
clear all
figure(405)
clf
hold all
N = 200;
DEBUG_FLAG = 0;
total_files = 150;
width_lman = nan(total_files,1);
width_learning = nan(total_files, 1);
maxlag = 50;
for n = 1:total_files
    n
    filename = ['c:\stetner\data\figures\xmodel\temporal_resolution_lman' int2str(n) '.mat'];
    if exist(filename, 'file')
        d = load(filename);
        bias = zeros(d.motif_steps, d.total_motifs);
        for motif = 1:d.total_motifs
            bias(:, motif) = d.weights_on_ra_from_lman*d.weights_on_lman_from_dlm*d.weights_on_dlm_from_pallidus*d.pallidal_output(:,:,motif);
        end
        keyboard
        [c, lags] = autocorrelation_by_columns(squeeze(d.lman_noise(1,:,:)), maxlag);
        acorr_lman = mean(c, 2);
        [c, lags] = autocorrelation_by_columns(bias(:,end-N:end), maxlag);
        acorr_learning = mean(c, 2);
        width_lman(n) = fwhm(acorr_lman);
        width_learning(n) = fwhm(acorr_learning);
        
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
scatter(width_lman, width_learning, 'x', 'MarkerSize', 10)

% for n = 1:106
%     plot(actual_learning(:,n))
%     pause
% end