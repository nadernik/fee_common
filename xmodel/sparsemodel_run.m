if (DEBUG_FLAG)
    wtemp = zeros(msn_units, hvc_units, motif_steps + extra_steps, total_motifs); %%%DEBUG
end

for motif = 1:total_motifs
    motif
    eligibility_trace = zeros([size(weights_on_msn_from_hvc), motif_steps + extra_steps]);
    error = zeros(1, motif_steps + extra_steps);
    steps_to_noise = 0;
    for t = 1:motif_steps + extra_steps

        if t <= motif_steps
            % MSN activity is determined by input from HVC. LMAN has no
            % effect.
            msn_input = weights_on_msn_from_hvc * hvc_output(:, t);
            msn_output(:, t, motif) = max(msn_input - msn_threshold, 0);

            
            % Each LMAN unit has a corresponding pallidal unit. The
            % pallidal unit sums the activity 
            pallidal_input = weights_on_pallidus_from_msn * msn_output(:, t, motif);
            pallidal_output(:, t, motif) = pallidal_input;

            dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, t, motif);
            dlm_output(:, t, motif) = dlm_input;

            % LMAN activity is the sum of intrinsic noise 
            lman_input(:, t) = lman_noise(:,t,motif) + weights_on_lman_from_dlm * dlm_output(:, t, motif);
            lman_output(:,t,motif) = max(lman_input(:, t) + lman_offset, 0);

            % RA activity is the sum of inputs from HVC and LMAN
            ra_input = weights_on_ra_from_hvc * hvc_output(:, t) + weights_on_ra_from_lman * lman_output(:, t, motif);
            ra_output(:, t, motif) = ra_input;

            L = weights_on_msn_from_lman * lman_output(:,t,motif); %lman input to each MSN
            for m = 1:msn_units % for each MSN
                % eligibility trace is hvc input times lman input convolved
                % with kernel
                H = weights_on_msn_from_hvc(m, :)' .* hvc_output(:,t); % hvc input at each hvc synapse on THIS msn
                eligibility_trace(m,:, t+t_ekernel) =  L(m) * H * ones(1, length(ekernel)) .* ekernel_matrix + ...
                    squeeze(eligibility_trace(m,:, t+t_ekernel));
            end
            
            % Conditional auditory feedback
            if t == caf_target_time2 
                above_threshold1 = ra_output(1, caf_target_time1, motif) > caf_pitch_threshold1;
                below_threshold2 = ra_output(1, caf_target_time2, motif) < caf_pitch_threshold2;
                random_hit = rand < caf_random_hit_probability;
                if above_threshold1 || below_threshold2
                    is_escape(motif) = false;
                    steps_to_noise = caf_noise_duration;
                elseif random_hit
                    is_escape(motif) = false;
                    is_random_hit(motif) = true;
                    steps_to_noise = caf_noise_duration;
                end
            end
            
            % Instantaneous error
            if steps_to_noise > 0
                instantaneous_error = caf_error_value;
                steps_to_noise = steps_to_noise - 1;
            else
                instantaneous_error = (ra_output(:, t, motif) - template(:, t)).^2;
            end
            error(t + t_rkernel) = error(t + t_rkernel) + instantaneous_error * rkernel;
        end


        reward(t, motif) = -error(t);
        rpe = reward(t, motif) - expected_reward(t, motif);

        %
        %% Update expected state value
        expected_reward(t, motif + 1) = expected_reward(t, motif) + reward_learning_rate * rpe;

        %
        %% Update synaptic weights only if we are past the baseline period
        if motif > baseline_motifs && motif < (total_motifs - ending_motifs)


            dw = eligibility_trace(:,:,t) .* rpe .* msn_learning_rate;
            weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;
            % decrement weights if over limit
            over_limit = sum(weights_on_msn_from_hvc,2) > max_total_synaptic_weight;
            dw = over_limit*ones(1, hvc_units)*competition;
            weights_on_msn_from_hvc = weights_on_msn_from_hvc - dw;
            % Make sure these synaptic weights are not negative
            weights_on_msn_from_hvc = max(0.1, weights_on_msn_from_hvc);
            weights_on_msn_from_hvc = min(max_single_synaptic_weight, weights_on_msn_from_hvc);
        end
        if DEBUG_FLAG
            wtemp(:,:,t,motif) = weights_on_msn_from_hvc; %%%DEBUG
        end
    end
end