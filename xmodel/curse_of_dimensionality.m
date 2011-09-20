%% 
% Larry Abbott says that models like this suffer from the curse of
% dimensionality. The problem becomes much harder as the degrees of freedom
% increase. We think this is not a huge problem because the bird only uses
% seven muscles to control singing. 

close all
clear all

%%
% Here we model learning to conrol one muscle while the other six muscles
% have independent influences on the song. The influence of the six other
% muscles is modeled as six independent LMAN signals

for extra_channels = 12
    extra_channels
    xmodel_parameters_extra_noise
    xmodel_initialize
    extra_lman = zeros(extra_channels, motif_steps, total_motifs);
    for u = 1:extra_channels
        extra_lman(u, :, :) = generate_lman_noise(motif_steps, total_motifs);
    end
    extra_errors = extra_lman .^ 2;
    total_extra_error = squeeze(sum(extra_errors, 1));
    keyboard
    xmodel_run_extra_errors
    filename = ['c:\stetner\data\figures\xmodel\curse_of_dimensionality_' int2str(extra_channels)];
    save(filename)
    save temp extra_channels
    clear all
    load temp
end

%%
clear all
figure
hold all
datapath = 'c:\stetner\data\figures\xmodel\'; % ends in filesep
files = dir([datapath 'curse_of_dimensionality_*.mat']);
extra_dimensions_list = [0 1 3 6 12];
for n = 1:length(extra_dimensions_list)
    filename = ['c:\stetner\data\figures\xmodel\curse_of_dimensionality_' int2str(extra_dimensions_list(n))];
    d = load(filename);
    dimensions(n) = d.extra_channels + 1;
    legend_labels{n} = int2str(dimensions(n));
    extra_error_mean(n) = mean(d.total_extra_error(:));
    extra_error_var(n) = var(d.total_extra_error(:));
    error = squeeze(d.ra_output) - d.template' * ones(1, d.total_motifs);
    mean_squared_error(:, n) = mean(error.^2, 1);
    plot(smooth(mean_squared_error(:,n), 20))
    clear d
end
legend(legend_labels)
xlabel('Trials')
ylabel('Mean Squared Error')

figure
scatter(dimensions, extra_error_mean)
xlabel('Dimensions')
ylabel('Average extra error')

figure
scatter(dimensions, extra_error_var)
xlabel('Dimensions')
ylabel('Variance of extra error')


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