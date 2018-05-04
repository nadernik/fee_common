function figure_curse_of_dimensionality(do_simulations)
%% 
% Larry Abbott says that models like this suffer from the curse of
% dimensionality. The problem becomes much harder as the degrees of freedom
% increase. We think this is not a huge problem because the bird only uses
% seven muscles to control singing. 

threshold = 3;
total_runs = 10;
extra_channels_list = 2.^(1:5) - 1;
filename = @(r, ch) sprintf('c:\\stetner\\data\\figures\\xmodel\\curse_of_dimensionality_%02.f_%02.f.mat', ch, r);

%%
% Here we model learning to conrol one muscle while the other six muscles
% have independent influences on the song. The influence of the six other
% muscles is modeled as six independent LMAN signals

if exist('do_simulations', 'var') && (do_simulations == 1)
    disp('Doing Simulations')
    for nrun = 1:total_runs
        for ich = 1:length(extra_channels_list)
            extra_channels = extra_channels_list(ich);

            % Run simulation
            xmodel_parameters_extra_noise
            xmodel_initialize
            extra_lman = zeros(extra_channels, motif_steps, total_motifs);
            for u = 1:extra_channels
                extra_lman(u, :, :) = generate_lman_noise_mes010(motif_steps, total_motifs);
            end
            extra_errors = extra_lman .^ 2;
            total_extra_error = squeeze(sum(extra_errors, 1));
            xmodel_run_extra_errors
            xmodel_calculate_bias

            % Save results
            save(filename(nrun, extra_channels))
            save temp.mat nrun ich extra_channels_list total_runs threshold filename
            clear all
            load temp
        end
    end
end

%% 
disp('Collecting all datas')
ii = 0;
% loadvars = {'extra_error_mean', 'extra_error_var', 'smoothed_error', 'time_to_learn', 'ndim', 'nrun'};
loadvars = {'total_extra_error', 'bias', 'template', 'total_motifs', 'baseline_motifs'};
for nrun = 1:total_runs
    for ich = 1:length(extra_channels_list)
        extra_channels = extra_channels_list(ich);
        ii = ii+1;
        
        fn = sprintf('c:\\stetner\\data\\figures\\xmodel\\curse_of_dimensionality_%02.f_%02.f.mat', extra_channels, nrun)
        
        load(fn, loadvars{:})
                
        % Analysis
        files(ii).extra_error_mean = mean(total_extra_error(:));
        files(ii).extra_error_var = var(total_extra_error(:));
        
        e = bias - template' * ones(1, total_motifs);
        mse_motif = baseline_motifs+1:total_motifs; % omit baseline motifs
        mse = mean(e(:,mse_motif).^2, 1); % mean over motifs
        files(ii).mse = mse';
        files(ii).time_to_learn = find(mse < threshold, 1, 'first');
        files(ii).ndim = extra_channels + 1;
        
        files(ii).extra_channels = extra_channels;
%         files(ii) = load(filename(nrun, extra_channels), loadvars{:});

    end
end
save('c:\stetner\data\figures\xmodel\curse_of_dimensionality_aggregated.mat', 'files')
%% 
figure
X = repmat((1:length(files(ii).mse))',1,length(files));
plotbyfactor(X, [files.mse],[files.ndim], true)
hold on
plot(xlim,[threshold threshold],'--k')
xlabel('Trials')
ylabel('Mean Squared Error')
title('Average over ten runs')

% figure
% scatter(dimensions, extra_error_mean)
% xlabel('Dimensions')
% ylabel('Average extra error')
% 
% figure
% scatter(dimensions, extra_error_var)
% xlabel('Dimensions')
% ylabel('Variance of extra error')


figure
x = [files.ndim];
y = [files.time_to_learn];
scatter(x, y, 'filled')
yL = ylim;
ylim([0, yL(2)])
xlabel('Number of dimensions')
ylabel('Trials to learn')

figure
x = sqrt([files.ndim]);
sembyfactor([files.time_to_learn], x)
[p, S] = polyfit(x, y, 1);
xx = linspace(1,6);
f = polyval(p, xx);
hold on
plot(xx, f)
yL = ylim;
ylim([0, yL(2)])
xlabel('sqrt(Number of dimensions)')
ylabel('Trials to learn')

%%
% plot last 20 trials
figure
last_trials = squeeze(ra_output(1, :, end-20:end));
plot(last_trials)
plot(mean(last_trials'))

% bias
figure
bias = squeeze(dlm_output(1,:,:) - dlm_output(2,:,:));
imagesc(bias')