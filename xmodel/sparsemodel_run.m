if (DEBUG_FLAG)
    w_all = zeros(msn_units, hvc_units, total_motifs);
    dw_before_comp = zeros(msn_units, hvc_units, total_motifs);
end

for motif = 1:total_motifs
    error = zeros(1, motif_steps + extra_steps);
    steps_to_noise = 0;
    for t = 1:motif_steps + extra_steps

        if t <= motif_steps
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Calculate neural activity %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % MSN activity is determined by input from HVC. LMAN has no
            % effect.
            msn_input = weights_on_msn_from_hvc * hvc_output(:, t);
            msn_output(:, t, motif) = max(msn_input - msn_threshold, 0); %DEBUG

            
            % Each LMAN unit has a corresponding pallidal unit. The
            % pallidal unit sums the activity 
            pallidal_input = weights_on_pallidus_from_msn * msn_output(:, t, motif); %DEBUG
            pallidal_output(:, t, motif) = pallidal_input;

            dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, t, motif);
            dlm_output(:, t, motif) = dlm_input;

            % LMAN activity is the sum of intrinsic noise 
            lman_input(:, t) = lman_noise(:,t,motif) + weights_on_lman_from_dlm * dlm_output(:, t, motif);
            lman_output(:,t,motif) = max(lman_input(:, t) + lman_offset, 0);

            % RA activity is the sum of inputs from HVC and LMAN
            ra_input = weights_on_ra_from_hvc * hvc_output(:, t) + weights_on_ra_from_lman * lman_output(:, t, motif);
            ra_output(:, t, motif) = ra_input;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Conditional auditory feedback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Instantaneous error %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if steps_to_noise > 0
                instantaneous_error(t) = caf_error_value;
                steps_to_noise = steps_to_noise - 1;
            else
                instantaneous_error(t) = (ra_output(:, t, motif) - template(:, t)).^2;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
            

        % Convolution of instantaneous errors with kernel by "looking back"
        % in time, just like we did for eligibility trace.
        tr = t-(length(rkernel):-1:1);
        e = zeros(size(rkernel));
        ndx = tr > 0 & tr <= motif_steps;
        e(ndx) = instantaneous_error(tr(ndx));
        error = sum(e .* rkernel);
        reward(t, motif) = -error;
        rpe = reward(t, motif) - expected_reward(t, motif);

        %
        %% Update expected state value
        expected_reward(t, motif + 1) = expected_reward(t, motif) + reward_learning_rate * rpe;

        %
        %% Update synaptic weights only if we are in learning period
        if motif > baseline_motifs && motif < (total_motifs - ending_motifs)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Calculate eligibility trace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Time vector for looking backwards in time. We look back the
            % number of steps we need to cover the length of the
            % eligibility trace. At the edge we just copy the value of the
            % first point of the motif.
            te = t-(length(ekernel):-1:1);
            ndx = te > 0 & te <= motif_steps;

            % LMAN input onto each MSN for the timepoints in the past that
            % we care about, seen thru LMAN-X synapses.
            L_in = zeros(msn_units, length(te));
            L_in(:,ndx) = weights_on_msn_from_lman * lman_output(:,te(ndx),motif);

            H = zeros(hvc_units, length(te));
            for m = 1:msn_units

                L = ones(hvc_units, 1) * L_in(m,:); % past lman activity

                H(:,ndx) = hvc_output(:,te(ndx)) .* ...              % past hvc
                    (weights_on_msn_from_hvc(m,:)' * ... % activity, seen
                    ones(1, sum(ndx))) ;          % thru synapses

                % This is the convolution! Past LMAN and HVC activities
                % mutliplied by the kernel and summed. This gives the value
                % of the convolution at the CURRENT time step, which is all
                % we care about.
                eligibility_trace(m,:) = sum(L .* H .* ekernel_matrix, 2);
            end

            dw = eligibility_trace .* rpe .* msn_learning_rate;
            weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;
            
            % Make sure these synaptic weights are not negative
            weights_on_msn_from_hvc = max(winit, weights_on_msn_from_hvc);
        end
    end
    
    % At the end of each motif, do heterosynaptic competition in each 
    % medium spiny neuron
    
    % Count the number of time steps that each unit was "bursting" during
    % this motif
    time_spent_bursting = sum(msn_output(:,:,motif) > msn_burst_activity_threshold, 2);
    
    % If a unit has been bursting too much, decrease all of its synaptic
    % weights by a fixed amount
    overly_active_units = find(time_spent_bursting > msn_burst_time_threshold);
    
    dw = max(weights_on_msn_from_hvc - w_all(:,:,motif - 2), 0);
    dw_before_comp(:,:,motif) = dw;
    if ~isempty(overly_active_units)
        weights_on_msn_from_hvc(overly_active_units, :) = ...
        weights_on_msn_from_hvc(overly_active_units, :) - mean(dw(overly_active_units,:),2)*ones(1,hvc_units);
    end
    
    % Make sure these synaptic weights are not negative
    weights_on_msn_from_hvc = max(winit, weights_on_msn_from_hvc);
    w_all(:,:,motif) = weights_on_msn_from_hvc;
    
    % show progress
    xmodel_calculate_bias
%     image(bias' ./ globalmax(template) .* 64)
    imagesc(bias')
    title(int2str(motif))
    drawnow
end