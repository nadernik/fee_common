% This is how I calculate the eligibility trace now.
eligibility_trace = zeros(msn_units, hvc_units, motif_steps+extra_steps);
ekernel_matrix = ones(hvc_units,1) * ekernel;
for motif = 1:total_motifs
    for t = 1:motif_steps
        L = weights_on_msn_from_lman * lman_output(:,t,motif); %lman input to each MSN
        for m = 1:msn_units % for each MSN
            % eligibility trace is hvc input times lman input convolved
            % with kernel
            H = weights_on_msn_from_hvc(m, :)' .* hvc_output(:,t); % hvc input at each hvc synapse on THIS msn
            eligibility_trace(m,:, t+t_ekernel) =  L(m) * H * ones(1, length(ekernel)) .* ekernel_matrix + ...
                squeeze(eligibility_trace(m,:, t+t_ekernel));
        end
    end
end
