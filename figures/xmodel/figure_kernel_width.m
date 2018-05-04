%% What is the effect of changing the width of the reward/eligibility
%% kernels?

kernel_widths = 2.^(0:6);
total_runs = 6;
datapath = 'c:\stetner\data\figures\xmodel\mes010\';
fit_trials = 1:500;

%%
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
figure
c = get(gca, 'ColorOrder');
hold on
for ikw = 1:length(kernel_widths)
    for irun = 1:6
        filename = sprintf('%skernel_width_%03.f_run_%02.f', datapath, kernel_widths(ikw), irun)
        load(filename)
        xmodel_calculate_bias
        error = squeeze(bias) - template' * ones(1, total_motifs);
        error = error(:,baseline_motifs+1:end); % chop off baseline motifs
        mse(:,irun,ikw) = mean(error.^2, 1);
        
        plot(mse(:,irun,ikw), 'Color', c(ikw,:))
        
        % Fit exponential to the mean squared error during fit_trials to
        % get the learning rate time constant
        X = [fit_trials; ones(size(fit_trials))];
        y = mse(fit_trials,irun,ikw);
        [b,bint,r,rint,stats] = regress(log(y) ,X');
        yfit = exp(b' * X);
        ttl(irun,ikw) = b(1);
    end
end
keyboard
xlabel('Trials')
ylabel('Mean Squared Error')
set(gca, 'YScale', 'log')

figure
ttl = ttl - baseline_motifs;
sem = std(ttl, 1) / sqrt(total_runs);
errorbar(kernel_widths, mean(ttl,1), sem)
xlabel('Reward kernel S.D. (ms)')
ylabel('Learning time constant (trials)')
