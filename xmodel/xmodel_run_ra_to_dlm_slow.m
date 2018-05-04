% Separate noise sources -- one in RA, one in LMAN. Turn off the LMAN to RA
% connection to simulate putting AP-5 in RA. This is also useful because it
% gets rid of the recurrent loop RA-DLM-LMAN-RA. The aim of this model is
% to show that learning in Area X is still possible without direct LMAN
% influence on RA (Charlesworth et al. 2012)
Lbar = zeros(lman_units,1);
wbh = waitbar(0, 'Running xmodel');
try
for motif = 1:total_motifs
    str = sprintf('Motif %g of %g', motif, total_motifs);
    waitbar(motif/total_motifs, wbh, str)
    
    for t = 1:motif_steps
        % MSN activity is determined by input from HVC. LMAN has no
        % effect.
        msn_input = weights_on_msn_from_hvc * hvc_output(:,t);
        msn_output(:,t) = max(msn_input - msn_threshold, 0);
        
        pallidal_output(:,t) = weights_on_pallidus_from_msn * msn_output(:,t);
        
        % DLM
        if t == 1
            dlm_output(:,t,motif) = weights_on_dlm_from_pallidus * pallidal_output(:,t);
            dlm_nonoise(:,t) = weights_on_dlm_from_pallidus * pallidal_output(:,t);
        else
            dlm_output(:,t,motif) = weights_on_dlm_from_pallidus * pallidal_output(:,t) + ...
                weights_on_dlm_from_ra * ra_output(:,t-1,motif);
            dlm_nonoise(:,t) = weights_on_dlm_from_pallidus * pallidal_output(:,t) + ...
                weights_on_dlm_from_ra * ra_nonoise(:,t-1);
        end
        
        % LMAN
        if exist('lman_inactivated', 'var') && (lman_inactivated == true) && (motif <= baseline_motifs + learning_motifs)
            lman_input = 0;
        else
            lman_input = lman_offset + lman_noise(:,t,motif) + weights_on_lman_from_dlm * dlm_output(:,t,motif);
        end
        lman_output(:,t,motif) = max(0, lman_input); %DEBUG
        lman_nonoise(:,t) = lman_offset + weights_on_lman_from_dlm * dlm_nonoise(:,t);
        
        % RA
        if exist('lman_ra_cut', 'var') && (lman_ra_cut == true) && (motif <= baseline_motifs + learning_motifs)
            ra_input = weights_on_ra_from_hvc * hvc_output(:,t) + ...
                ra_noise(:,t,motif) + lman_offset;
        else
            ra_input = weights_on_ra_from_lman * lman_output(:,t,motif) + ...
                weights_on_ra_from_hvc * hvc_output(:,t) + ...
                ra_noise(:,t,motif) + lman_offset;
        end
        ra_output(:,t,motif) = max(0, ra_input); %DEBUG
        ra_nonoise(:,t) = weights_on_ra_from_lman * lman_nonoise(:,t) + ...
            weights_on_ra_from_hvc * hvc_output(:,t) + lman_offset;
        
        pitch(t,motif) = weights_on_song_from_ra * ra_output(:,t,motif);
        bias(t,motif) = weights_on_song_from_ra * ra_nonoise(:,t);
    end

    % Error is the squared difference between pitch and template
    instantaneous_error = (pitch(:, motif) - template').^2;

    % Conditional auditory feedback
    above_threshold1 = pitch(caf_target_time1, motif) > caf_pitch_threshold1;
    below_threshold2 = pitch(caf_target_time2, motif) < caf_pitch_threshold2;
    random_hit = rand < caf_random_hit_probability;
    if above_threshold1 || below_threshold2
        is_escape(motif) = false;
        instantaneous_error(caf_target_time2 + (1:caf_noise_duration)) = caf_error_value;
    elseif random_hit
        is_escape(motif) = false;
        is_random_hit(motif) = true;
        instantaneous_error(caf_target_time2 + (1:caf_noise_duration)) = caf_error_value;
    end

    error = conv(instantaneous_error, rkernel);
    reward(:, motif) = -error;
    rpe = reward(:, motif) - expected_reward(:, motif);

    % Update expected state value
    if motif < total_motifs
        expected_reward(:, motif + 1) = expected_reward(:, motif) + reward_learning_rate * rpe;
    end

    % Update synaptic weights only if we are past the baseline period
    if motif > baseline_motifs && motif < (total_motifs - ending_motifs)
        % Eligibility traces and learning
        dw = zeros(msn_units, hvc_units);
        u_msn = 0;
        for u_lman = 1:lman_units
            for u_hvc = 1:hvc_units
                u_msn = u_msn + 1;
                L = max(0,lman_output(u_lman,:,motif)-Lbar(u_lman)); %FIXME
                eligibility = conv(L .* hvc_output(u_hvc,:), ekernel);
                dw(u_msn, u_hvc) = msn_learning_rate * dot(eligibility, rpe);
            end
        end
        weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;

        % Make sure these synaptic weights are not negative
        weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvc);
    end
    
    Lbar = mean(lman_output(:,:,motif),2);
end
close(wbh)
catch
    close(wbh)
    rethrow(lasterror)
end