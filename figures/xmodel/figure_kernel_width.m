%% What is the effect of changing the width of the reward/eligibility
%% kernels?

kernel_widths = 2.^(0:6);
total_runs = 10;
datapath = 'c:\stetner\data\figures\xmodel\mes010\';

for irun = 1:total_runs
for ikw = 1:length(kernel_widths)
    xmodel_parameters_extra_noise % Use the same parameters as the curse of dimensionality figure
    
    % Change the kernel widths on every iteration
    std_etrace  = kernel_widths(ikw); % Eligibility trace
    std_rkernel = kernel_widths(ikw); % Reward
    
    % Run the simulation
    xmodel_initialize
    xmodel_run
    
    % Save results
    filename = sprintf('%skernel_width_%03.f_run_%02.f', datapath, kernel_widths(ikw), irun);
    save(filename)
end
end

%%
kernel_widths = 2.^(0:6);
total_runs = 10;
datapath = 'c:\stetner\data\figures\xmodel\';
threshold = 1/2/exp(2) * 50;

for ikw = 1:length(kernel_widths)
    for irun = 1:total_runs
        filename = sprintf('%skernel_width_%03.f_run_%02.f', datapath, kernel_widths(ikw), irun)
        load(filename)
        xmodel_calculate_bias
        error = bias - template' * ones(1, total_motifs);
        mse(:,irun,ikw) = mean(error.^2, 1);
        ttl(irun, ikw) = find(mse(:,irun,ikw) < threshold, 1, 'first'); % time to learn is when mse first falls below threshold
    end
end

figure
y = squeeze(mean(mse, 2));
plot(y(baseline_motifs:end, :))
hold on
plot(xlim, threshold*[1 1], '--k')
xlabel('Motifs')
ylabel('Mean Squared Error')

figure
ttl = ttl - baseline_motifs;
sem = std(ttl, 1) / sqrt(total_runs);
errorbar(4*kernel_widths, mean(ttl,1), sem)
xlabel('Delay to peak reward (ms)')
ylabel('Motifs to learn')