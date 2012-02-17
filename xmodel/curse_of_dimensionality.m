%% 
% Larry Abbott says that models like this suffer from the curse of
% dimensionality. The problem becomes much harder as the degrees of freedom
% increase. We think this is not a huge problem because the bird only uses
% seven muscles to control singing. 

close all
clear all

nsmooth = 20;
threshold = 3;
datapath = 'c:\stetner\data\figures\xmodel\'; % ends in filesep
%%
% Here we model learning to conrol one muscle while the other six muscles
% have independent influences on the song. The influence of the six other
% muscles is modeled as six independent LMAN signals

for nrun = 1:10
for extra_channels = 2.^(1:5) - 1
    extra_channels
    xmodel_parameters_extra_noise
    xmodel_initialize
    extra_lman = zeros(extra_channels, motif_steps, total_motifs);
    for u = 1:extra_channels
        extra_lman(u, :, :) = generate_lman_noise(motif_steps, total_motifs);
    end
    extra_errors = extra_lman .^ 2;
    total_extra_error = squeeze(sum(extra_errors, 1));
    xmodel_run_extra_errors
    filename = sprintf('%scurse_of_dimensionality_%g_%g.mat', datapath, extra_channels, nrun); 
    save(filename)
    save temp extra_channels nrun
    clear all
    load temp
end
end

%%
files = dir([datapath 'curse_of_dimensionality_*.mat']);
for ii = 1:length(files)
    files(ii).name % display the name of the file we are analyzing
    load([datapath files(ii).name]);
    xmodel_calculate_bias
    
    files(ii).extra_error_mean = mean(total_extra_error(:));
    files(ii).extra_error_var = var(total_extra_error(:));
    
    error = bias - template' * ones(1, total_motifs);
    mse = mean(error.^2, 1);
    temp = smooth(mse(baseline_motifs+1:end), nsmooth);
    files(ii).smoothed_error = temp(nsmooth/2:end-nsmooth/2);
    c = polyfit((nsmooth:learning_motifs)-nsmooth, log(files(ii).smoothed_error)', 1);
    files(ii).time_to_learn = c(1);
    
    [ndim, nrun] = dealcell(regexp(files(ii).name, 'curse_of_dimensionality_(\d+)_(\d+)', 'tokens', 'once'));
    files(ii).ndim = str2num(ndim);
    files(ii).nrun = str2num(nrun);
end
%%
figure
X = repmat((1:length(files(ii).smoothed_error))'+nsmooth/2,1,length(files));
plotbyfactor(X,[files.smoothed_error],[files.ndim]+1, true)
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
x = [files.ndim]+1;
y = [files.time_to_learn];
scatter(x, y, 'filled')
yL = ylim;
ylim([0, yL(2)])
xlabel('Number of dimensions')
ylabel('Trials to learn')

figure
sembyfactor([files.time_to_learn], [files.ndim]+1)
[p, S] = polyfit(x, y, 1);
xx = linspace(1,35);
f = polyval(p, xx);
hold on
plot(xx, f)
yL = ylim;
ylim([0, yL(2)])
xlabel('Number of dimensions')
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