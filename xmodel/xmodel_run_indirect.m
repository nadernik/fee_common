for motif = 1:total_motifs
    eligibility_trace = zeros(msn_units, motif_steps + extra_steps);
    error = zeros(1, motif_steps + extra_steps);
    steps_to_noise = 0;
    for t = 1:motif_steps + extra_steps

        if t <= motif_steps
            % MSN activity is determined by input from HVC. LMAN has no
            % effect.
            h = repmat(hvc_output(:, t), lman_units, 1);
            direct_msn_input =   weights_on_direct_msn_from_hvc   .* h;
            indirect_msn_input = weights_on_indirect_msn_from_hvc .* h;
            direct_msn_output(:, t, motif)   = max(direct_msn_input   - msn_threshold, 0);
            indirect_msn_output(:, t, motif) = max(indirect_msn_input - msn_threshold, 0);

            
            % Each LMAN unit has a corresponding pallidal unit. The
            % pallidal unit sums the activity 
            pallidal_input = ...
                weights_on_pallidus_from_direct_msn   * direct_msn_output(:, t, motif) + ...
                weights_on_pallidus_from_indirect_msn * indirect_msn_output(:, t, motif);
            pallidal_output(:, t, motif) = pallidal_input;

            dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, t, motif);
            dlm_output(:, t, motif) = dlm_input;

            % LMAN activity is the sum of intrinsic noise 
            lman_input(:, t) = lman_noise(:,t,motif) + weights_on_lman_from_dlm * dlm_output(:, t, motif);
            lman_output(:,t,motif) = max(lman_input(:, t) + lman_offset, 0);

            % RA activity is the sum of inputs from HVC and LMAN
            ra_input = weights_on_ra_from_hvc * hvc_output(:, t) + weights_on_ra_from_lman * lman_output(:, t, motif);
            ra_output(:, t, motif) = ra_input;

            u_msn = 0;
            for u_lman = 1:lman_units
                for u_hvc = 1:hvc_units
                    u_msn = u_msn + 1;
                    eligibility_trace(u_msn, t + t_ekernel) = ...
                        eligibility_trace(u_msn, t + t_ekernel) + ...
                        lman_output(u_lman, t, motif) .* hvc_output(u_hvc, t) * ekernel;
                end
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
            dw_direct   =  eligibility_trace(:, t) .* rpe .* msn_learning_rate;
            dw_indirect = -eligibility_trace(:, t) .* rpe .* msn_learning_rate;
            weights_on_direct_msn_from_hvc = weights_on_direct_msn_from_hvc + dw_direct;
            weights_on_indirect_msn_from_hvc = weights_on_indirect_msn_from_hvc + dw_indirect;
            
            % Make sure these synaptic weights are not negative
            weights_on_direct_msn_from_hvc = max(0, weights_on_direct_msn_from_hvc);
            weights_on_indirect_msn_from_hvc = max(0, weights_on_indirect_msn_from_hvc);
        end
    end
end