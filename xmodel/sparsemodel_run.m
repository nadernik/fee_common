if (DEBUG_FLAG)
    w_all = zeros(msn_units, hvc_units, total_motifs);
    dw_before_comp = zeros(msn_units, hvc_units, total_motifs);
end

for motif = 1:total_motifs
    motif
    % Simulate network activity for one motif. Assume synaptic weights stay
    % constant during the motif

    % MSN activity is determined by input from HVC. LMAN has no
    % effect.
    msn_input = weights_on_msn_from_hvc * hvc_output;

    % MSN output is threshold linear
    msn_output(:, :, motif) = max(msn_input - msn_threshold, 0);

    % MSNs project to pallidal units. There is one pallidal unit per
    % channel and it pools the activity from all MSNs in that channel. Real
    % pallidal neurons have high baseline firing rates. In the model,
    % pallidal units can have positive or negative activities which are
    % interpreted as fluctuations around this baseline.
    pallidal_input = weights_on_pallidus_from_msn * msn_output(:, :, motif);
    pallidal_output(:, :, motif) = pallidal_input;

    % Pallidal units project to DLM. This is just a relay station. Like the
    % pallidal units, DLM units can have activity that is positive or
    % negative representing fluctuations around a high baseline firing
    % rate.
    dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, :, motif);
    dlm_output(:, :, motif) = dlm_input;

    % LMAN activity is the sum of intrinsic noise and input from DLM. LMAN
    % units have positive firing rates. They have a low baseline firing
    % rate of lman_offset.
    lman_input = lman_noise(:,:,motif) + weights_on_lman_from_dlm * dlm_output(:, :, motif);
    lman_output(:,:,motif) = max(lman_input + lman_offset, 0);

    % RA activity is the sum of inputs from HVC and LMAN
    ra_input = weights_on_ra_from_hvc * hvc_output + weights_on_ra_from_lman * lman_output(:, :, motif);
    ra_output(:, :, motif) = ra_input;

    % At the end of each motif, calculate error and do learning

    % Error is the square of the difference between the vocal output and the
    % template
    error = (ra_output(:, :, motif) - template).^2;

    % If . CAF can be turned off by setting the thresholds to NaN
    above_threshold1 = ra_output(1, caf_target_time1, motif) > caf_pitch_threshold1;
    below_threshold2 = ra_output(1, caf_target_time2, motif) < caf_pitch_threshold2;
    random_hit = rand < caf_random_hit_probability;
    if above_threshold1 || below_threshold2
        is_escape(motif) = false;
        error(t2+(1:caf_noise_duration)) = caf_error_level;
    elseif random_hit
        is_escape(motif) = false;
        is_random_hit(motif) = true;
        error(t2+(1:caf_noise_duration)) = caf_error_level;
    end

    % Reward is the opposite of error and is convolved with the reward kernel
    reward(:,motif) = conv(-error, rkernel);

    % Reward prediction error is difference between actual and expected reward
    rpe = reward(:,motif) -  expected_reward(:,motif);
    rpe2 = repmat(permute(rpe,[3,2,1]), [msn_units, hvc_units, 1]);

    % Update expected reward
    if motif < total_motifs
        expected_reward(:,motif+1) = expected_reward(:,motif) + reward_learning_rate * rpe;
    end

    % If we are in the learning period, update synaptic weights
    if motif > baseline_motifs && motif < (total_motifs - ending_motifs)

        % Eligibility trace
        H = hvc_output;
        L = weights_on_msn_from_lman * lman_output(:,:,motif);
        I = weights_on_msn_from_msn * msn_output(:,:,motif);
        I = max(I, -L); % make sure inhibition is not strong enough to make the quantity (L-I) negative

        for m = 1:msn_units
            eligibility_trace(m,:,:) = conv2(ones(hvc_units, 1) * (L(m,:)+I(m,:)) .* H, ekernel);
        end


        dw = sum(eligibility_trace .* rpe2 .* msn_learning_rate, 3);
        weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;

        % Make sure these synaptic weights are not negative
        weights_on_msn_from_hvc = max(winit, weights_on_msn_from_hvc);
        
    end

    % At the end of each motif, do heterosynaptic competition in each
    % medium spiny neuron

    % Count the number of time steps that each unit was "bursting" during
    % this motif
    time_spent_bursting = sum(msn_output(:,:,motif) > msn_burst_activity_threshold, 2);

    % If a unit has been bursting too much, decrease all of its synaptic
    % weights by a fixed amount
    overly_active_units = find(time_spent_bursting > msn_burst_time_threshold);
    if motif > 2
        dw = weights_on_msn_from_hvc - w_all(:,:,motif - 2);
        dw_before_comp(:,:,motif) = dw;
    end
    if ~isempty(overly_active_units)
        for ii = 1:length(overly_active_units)
            m = overly_active_units(ii);
            f = exp(-competition_scale .* weights_on_msn_from_hvc(m,:));
            weights_on_msn_from_hvc(m, :) = weights_on_msn_from_hvc(m, :) - f .* competition_strength;
        end
    end

    % Make sure these synaptic weights are not negative
    weights_on_msn_from_hvc = max(winit, weights_on_msn_from_hvc);
    w_all(:,:,motif) = weights_on_msn_from_hvc;

    % show progress
    xmodel_calculate_bias
    subplot(2,1,1)
    imagesc(weights_on_msn_from_hvc)
    title(int2str(motif))
    subplot(2,1,2)
    plot(template)
    hold all
    plot(bias(:,motif))
    hold off
    drawnow
end