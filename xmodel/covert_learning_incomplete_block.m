%% Covert learning: Incomplete block
% Charlesworth et al. 2012 demonstrated that even though a bird's pitch
% does not change during CAF if he has AP-5 in RA, covert learning is
% revealed after the AP-5 is removed. One explanation for this result is
% that AP-5 causes an incomplete block of LMAN inputs to RA so that
% variability in RA activity in song is still correlated with LMAN
% activity. Then, the AFP can use the variability in LMAN to learn.
%
% Here we simulate learning in a
% network with reduced drive from LMAN to RA and show that this network is
% still able to learn 

data_dir = 'c:\stetner\data\xmodel\covert';
strengths = linspace(0,1,5);

for lman_to_ra_drive = strengths
    fprintf('Running simulation with LMAN-RA connection at %g%% of its normal strength.\n', lman_to_ra_drive * 100)
    xmodel_parameters_caf
    caf_pitch_threshold2 = 0;
    xmodel_initialize
    
    % Set the strength of the LMAN to RA connection.
    weights_on_ra_from_lman = weights_on_ra_from_lman * lman_to_ra_drive;
    
    xmodel_run
    xmodel_calculate_bias
    
    % Get bias when LMAN to RA connection is restored to full strength
    original_weights_on_ra_from_lman = weights_on_ra_from_lman / lman_to_ra_drive;
    bias_restored = original_weights_on_ra_from_lman * weights_on_lman_from_dlm * dlm_output(:,:,end);
    
    file_name = sprintf('incomplete_block_%03.f', lman_to_ra_drive*100);
    save(fullfile(data_dir, file_name))
    save temp data_dir lman_to_ra_drive strengths
    clear all
    load temp
end

%%
data_dir = 'c:\stetner\data\xmodel\covert';
files = dir(fullfile(data_dir, 'incomplete_block_*'));
for ii = 1:length(files)
    d = load(fullfile(data_dir, files(ii).name));
    
    figure
    plot(squeeze(d.bias(1, d.caf_target_time2,:)), '.r')
    hold on
    plot(d.total_motifs + 1, squeeze(d.bias_restored(1, d.caf_target_time2)), '.k')
    xlabel('Trial Number')
    ylabel('Bias at target time')
    legend('LMAN-to-RA weakened', 'LMAN-to-RA full strength', 'Location', 'NorthWest')
    title(sprintf('LMAN-to-RA at %g%% of normal', d.lman_to_ra_drive * 100))
end
    