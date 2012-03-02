if (DEBUG_FLAG)
    w_all    = zeros(msn_units, hvc_units, total_motifs);
    ltp_all  = zeros(msn_units, hvc_units, total_motifs);
    ltd_all  = zeros(msn_units, hvc_units, total_motifs);
    comp_all = zeros(msn_units, hvc_units, total_motifs);
end

for motif = 1:total_motifs
    motif
   
    % Weights from LMAN -> MSN are randomly assigned on each motif. Weights
    % are randomly distributed between 1/lman_rand and lman_rand with equal
    % weight above and below 1. The topography between LMAN and MSNs is
    % preserved.
    weights_on_msn_from_lman = exp(log(lman_rand^2)*rand(msn_units,lman_units) + log(1/lman_rand)) .* (weights_on_msn_from_lman>0);
    
    % MSN activity is determined by input from HVC. LMAN has no
    % effect.
    msn_input = weights_on_msn_from_hvc * hvc_output;

    % MSN output is threshold linear
    msn_output(:, :, 1) = max(msn_input - msn_threshold, 0);

    % MSNs project to pallidal units. There is one pallidal unit per
    % channel and it pools the activity from all MSNs in that channel. Real
    % pallidal neurons have high baseline firing rates. In the model,
    % pallidal units can have positive or negative activities which are
    % interpreted as fluctuations around this baseline.
    pallidal_input = weights_on_pallidus_from_msn * msn_output(:, :, 1);
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

    %% At the end of each motif, calculate error and do learning

    % Error is the square of the difference between the vocal output and the
    % template
    error = (ra_output(:, :, motif) - template).^2;

    % If pitch is ABOVE the threshold at time 1 or BELOW the threshold at
    % time 2, the model receives a large error. CAF can be turned off by
    % setting the thresholds to NaN.
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
        for m = 1:msn_units
            eligibility_trace(m,:,:) = conv2(ones(hvc_units, 1) * L(m,:) .* H, ekernel);
        end
        
        
        % Count the number of time steps that each unit was "bursting" during
        % this motif
        competing_msns = false(msn_units, 1);
        for m = 1:msn_units
            [t1, t2] = detectThresholdCrossings(msn_output(m,:,1), msn_burst_activity_threshold);
            length_of_bursts = t2-t1;
            number_of_bursts = length(t1);
            % If this unit has more than one burst, or if any of its bursts are
            % too long, then it is too active. We should decrease its synaptic
            % weights.
            if number_of_bursts > 1 || any(length_of_bursts > msn_burst_time_threshold)
                competing_msns(m) = true;
            end
        end
        competition = zeros(size(weights_on_msn_from_hvc));
        competition(competing_msns, :) = -competition_strength;
    
        learning = sum(eligibility_trace .* rpe2 .* msn_learning_rate, 3);
        inhibition  = weights_on_msn_from_msn * msn_output(:,:,1) * hvc_output';
        stability = exp(stability_factor .* weights_on_msn_from_hvc);

        weights_on_msn_from_hvc = weights_on_msn_from_hvc + learning + (competition + inhibition)./stability;
        
        if DEBUG_FLAG
            learn_all(:,:,motif)  = learning;
            inhib_all(:,:,motif)  = inhibition  ./ stability;
            comp_all(:,:,motif)   = competition ./ stability;
        end
        
        % Make sure these synaptic weights are not negative
        weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvc);
        
    end

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