ekernel_matrix = ones(hvc_units, 1) * ekernel;
for motif = 1:total_motifs
    eligibility_trace = zeros(msn_units, hvc_units, length(ekernel));
    for t = 1:motif_steps
        for m = 1:msn_units
            % H is a vector of HVC activity onto current MSN as seen through synapses
            % (hvc_units x 1)
            H = hvc_output(:,t) .* weights_on_msn_from_hvc(m, :)';
            % L is a scalar, the LMAN activity onto current MSN (1x1)
            L = weights_on_msn_from_lman(m,:) * lman_noise(:, t, motif);

            % ekernel_matrix is hvc_units x length(ekernel)
            oldtrace = cat(3, eligibility_trace(m,:,2:end), zeros(1,hvc_units,1));
            newtrace = shiftdim(L .* H * ones(1, length(ekernel)) .* ekernel_matrix, -1);
            eligibility_trace(m,:,:) = oldtrace + newtrace;
            %eligibility_trace is msn_units x hvc_units x time
        end
    end
end