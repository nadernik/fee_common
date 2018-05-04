for motif = 1:total_motifs
    eligibility_trace = zeros(msn_units * hvc_units, length(ekernel));
    for t = 1:motif_steps
        H = repmat(hvc_output(:,t) .* weights_on_msn_from_hvc(m, :)', msn_units, 1);
        % L is a scalar, the LMAN activity onto current MSN (1x1)
        temp = (weights_on_msn_from_lman * lman_noise(:, t, motif) * ones(1, hvc_units))';
        L = temp(:);

        oldtrace = [eligibility_trace(:,2:end), zeros(msn_units * hvc_units, 1)];
        newtrace = (L .* H) * ekernel; % matrix multiplication
        eligibility_trace = oldtrace + newtrace;
        % each row is a neuron, each column is a time point
        
        eligibility_matrix = reshape(eligibility_trace(:,1),msn_units, hvc_units);
    end
end