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

for extra_channels = 0;%[0 1 3 6 12]
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
    filename = ['c:\stetner\data\figures\xmodel\curse_of_dimensionality_' int2str(extra_channels)];
    save(filename)
    save temp extra_channels
    clear all
    load temp
end

%%
imagesc(squeeze(ra_output)')

% plot last 20 trials
last_trials = squeeze(ra_output(1, :, end-20:end));
plot(last_trials)
plot(mean(last_trials'))

% bias
bias = squeeze(dlm_output(1,:,:) - dlm_output(2,:,:));
imagesc(bias')