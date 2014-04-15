% Separate noise sources -- one in RA, one in LMAN. Turn off the LMAN to RA
% connection to simulate putting AP-5 in RA. This is also useful because it
% gets rid of the recurrent loop RA-DLM-LMAN-RA. The aim of this model is
% to show that learning in Area X is still possible without direct LMAN
% influence on RA (Charlesworth et al. 2012)

wbh = waitbar(0, 'Running xmodel');
try
for motif = 1:total_motifs
    str = sprintf('Motif %g of %g', motif, total_motifs);
    waitbar(motif/total_motifs, wbh, str)

    % MSN activity is determined by input from HVC. LMAN has no
    % effect.
    msn_input = weights_on_msn_from_hvc * hvc_output;
    msn_output = max(msn_input - msn_threshold, 0);

    % Each LMAN unit has a corresponding pallidal unit. The
    % pallidal unit sums the activity
    pallidal_input = weights_on_pallidus_from_msn * msn_output;
    pallidal_output(:, :, motif) = pallidal_input;

    % RA activity is the sum of inputs from HVC and intrinsic
    % noise. LMAN-RA pathway is turned off.
    ra_input = weights_on_ra_from_hvc * hvc_output + ra_noise(:, :, motif);
    ra_output = max(ra_input + lman_offset, 0);

    % DLM gets input from RA and Pallidal units. DLM activity can be
    % positive or negative representing fluctuations around a high baseline
    % rate.
    dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, :, motif) ...
        + weights_on_dlm_from_ra * ra_output;
    dlm_output = dlm_input;

    % LMAN activity is the sum of intrinsic noise and input from DLM. LMAN
    % firing rates cannot be negative but have a baseline rate.
    lman_input = lman_noise(:,:,motif) + weights_on_lman_from_dlm * dlm_output;
    lman_output(:,:,motif) = max(lman_input, 0);

    % The vocal output of the model is determined by RA activity
    pitch(:, motif) = weights_on_song_from_ra * ra_output;

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
                eligibility = conv(lman_output(u_lman,:,motif) .* hvc_output(u_hvc,:), ekernel);
                dw(u_msn, u_hvc) = msn_learning_rate * dot(eligibility, rpe);
            end
        end
        weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;

        % Make sure these synaptic weights are not negative
        weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvc);
    end
    bias(:,:,motif) = [1, -1] * weights_on_lman_from_dlm * dlm_output(:,:,m);
end
close(wbh)
catch
    close(wbh)
    rethrow(lasterror)
end