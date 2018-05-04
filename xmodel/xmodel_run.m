% wbh = waitbar(0, 'Running xmodel');
% figure;
% axh = axes;
% try
for motif = 1:total_motifs
    str = sprintf('Motif %g of %g', motif, total_motifs);
    motif
%     waitbar(motif/total_motifs, wbh, str)
    
    % MSN activity is determined by input from HVC. LMAN has no
    % effect.
    msn_input = weights_on_msn_from_hvc * hvc_output;
    msn_output = max(msn_input - msn_threshold, 0);

    % Each LMAN unit has a corresponding pallidal unit. The
    % pallidal unit sums the activity
    pallidal_input = weights_on_pallidus_from_msn * msn_output;
    pallidal_output = pallidal_input;

    dlm_input = weights_on_dlm_from_pallidus * pallidal_output;
    dlm_output(:,:,motif) = dlm_input;

    % LMAN activity is the sum of intrinsic noise
    lman_input = lman_noise(:,:,motif) + weights_on_lman_from_dlm * dlm_output(:,:,motif);
    lman_output = max(lman_input + lman_offset, 0);

    % RA activity is the sum of inputs from HVC and LMAN
    ra_input = weights_on_ra_from_hvc * hvc_output + weights_on_ra_from_lman * lman_output;
    ra_output(:, :, motif) = ra_input;

    instantaneous_error = mean((ra_output(:, :, motif) - template).^2, 1);
    
    % Conditional auditory feedback
    above_threshold1 = ra_output(1, caf_target_time1, motif) > caf_pitch_threshold1;
    below_threshold2 = ra_output(1, caf_target_time2, motif) < caf_pitch_threshold2;
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
                eligibility = conv(lman_output(u_lman,:) .* hvc_output(u_hvc,:), ekernel);
                dw(u_msn, u_hvc) = msn_learning_rate * dot(eligibility, rpe);
            end
        end
        weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;

        % Make sure these synaptic weights are not negative
        weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvc);
    end

%     xmodel_calculate_bias
%     plot(axh, 1:motif_steps, bias(:, motif), '-m', 1:motif_steps, template, ':k')
%     drawnow
end
% close(wbh)
% catch
%     close(wbh)
%     rethrow(lasterror)
% end