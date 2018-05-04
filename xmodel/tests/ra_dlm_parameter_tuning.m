function ra_dlm_parameter_tuning(do_simulations)
% Tune the parameters in RA-DLM simulations to match observed data
% There are two parameters that are unique to RA-DLM simulations:
%   ra_noise_amplitude is the variance of RA noise. The variance of LMAN
%                      noise is 1 - ra_noise_amplitude
%   weights_on_dlm_from_ra is the strength of the RA input to DLM. Must be
%                          less than 1 to prevent runaway excitation.
% In this function, I iterate through all the combinations of these values.
%
% Desire to make song standard deviation with LMAN-RA inactivated equal to 
% about 70% of the standard deviation with LMAN-RA intact. Also want to 
% make LMAN standard deviation as close as possible in both conditions.

amplitudes = linspace(0,1,11);
strengths = linspace(0,0.9,10);
fname_on = @(n1, n2) ['c:\stetner\data\xmodel\covert\ra_dlm_tuning_', ...
    int2str(n1), '_', int2str(n2), '_on'];
fname_off = @(n1, n2) ['c:\stetner\data\xmodel\covert\ra_dlm_tuning_', ...
    int2str(n1), '_', int2str(n2), '_off'];
vars_to_save = {'vars_to_save', 'amplitudes', 'strengths', 'iamp', ...
    'istr', 'fname_on', 'fname_off'};
%%
if exist('do_simulations', 'var') && do_simulations == 1
    for istr = 1:length(strengths)
        for iamp = 1:length(amplitudes)
            fprintf('Working on strength %g of %g and amplitude %g of %g\n', ...
                istr, length(strengths), iamp, length(amplitudes))
            
            % run with lman-ra on
            xmodel_parameters_baseline_only
            ra_noise_amplitude = amplitudes(iamp);
            ra_dlm_strength = strengths(istr);
            xmodel_initialize_ra_to_dlm
            xmodel_run_ra_to_dlm_slow
            save(fname_on(istr, iamp))
            save('temp.mat', vars_to_save{:})
            clear all
            load('temp.mat')
            
            % run with lman-ra off
            xmodel_parameters_baseline_only
            ra_noise_amplitude = amplitudes(iamp);
            ra_dlm_strength = strengths(istr);
            xmodel_initialize_ra_to_dlm
            weights_on_ra_from_lman = zeros(lman_units);
            xmodel_run_ra_to_dlm_slow
            save(fname_off(istr, iamp))
            save('temp.mat', vars_to_save{:})
            clear all
            load('temp.mat')
        end
    end
end
%%
for istr = 1:length(strengths)
    for iamp = 1:length(amplitudes)
        d_on = load(fname_on(istr, iamp), 'pitch', 'lman_output');
        d_off = load(fname_off(istr, iamp), 'pitch', 'lman_output');
        % ratio of song standard deviation
        rssong(istr, iamp) = std(d_off.pitch(:)) / std(d_on.pitch(:));
        % ratio of lman variance
        rslman(istr, iamp) = std(d_off.lman_output(:)) / std(d_on.lman_output(:));
        % correlation between lman variance and song
        lscorr_on(istr, iamp) = mean(diag(corr(... 
            squeeze(d_on.lman_output(1,100:end,:)), d_on.pitch(100:end,:))));
        lscorr_off(istr, iamp) = mean(diag(corr(... 
            squeeze(d_off.lman_output(1,100:end,:)), d_off.pitch(100:end,:))));
        % average correlation between matched trials of lman output and
        % song.
%         figure(1)
%         clf
%         % Choose ten random trials to plot
%         trials = randsample(size(d_on.pitch, 2), 10);
%         % Plot lman output and song for these trials
%         subplot(2,2,1)
%         plot(squeeze(d_on.lman_output(1,:,trials)))
%         title('LMAN output, LMAN-RA on')
%         subplot(2,2,2)
%         plot(squeeze(d_off.lman_output(1,:,trials)))
%         title('LMAN output, LMAN-RA off')
%         subplot(2,2,3)
%         plot(d_on.pitch(:,trials))
%         title('Vocal output, LMAN-RA on')
%         subplot(2,2,4)
%         plot(d_off.pitch(:,trials))
%         title('Vocal output, LMAN-RA off')
        
        fprintf('RA-DLM strength %g and RA variance %g\n', strengths(istr), amplitudes(iamp))
        
        %DEBUG pause
    end
end

figure
imagesc(amplitudes, strengths, rssong)
xlabel('RA Noise Variance')
ylabel('RA to DLM Strength')
title('Song standard deviation (LMAN-RA intact/inactivated)')

figure
imagesc(amplitudes, strengths, rslman)
xlabel('RA Noise Variance')
ylabel('RA to DLM Strength')
title('LMAN standard deviation (LMAN-RA intact/inactivated)')

figure
imagesc(amplitudes, strengths, lscorr_off ./ lscorr_on)
xlabel('RA Noise Variance')
ylabel('RA to DLM Strength')
title('Correlation between lman output and song (inactivated/intact)')

keyboard