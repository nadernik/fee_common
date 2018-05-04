% Instead of storing the results of convolution at everytime step, just do
% the convolution we need at each moment. This approach looks backward in
% time at HVC and LMAN activity to determine the current eligibility. The
% other methods are more of a "looking forward" approach.

% Copy the eligibility trace kernel (a row vector) into a matrix to save
% time on multiplication later.
ekernel_matrix = ones(hvc_units, 1) * ekernel; 

% Initialize empty eligibility trace matrix. Each entry in this matrix is
% the eligibility of one HVC-X synapse.
eligibility_trace = zeros(msn_units, hvc_units);

for motif = 1:total_motifs
    for t = 1:motif_steps
        
        % Time vector for looking backwards in time. We look back the
        % number of steps we need to cover the length of the eligibility
        % trace. At the edge we just copy the value of the first point of
        % the motif.
        tt = max(t-(length(ekernel):-1:1), 1);
        
        % LMAN input onto each MSN for the timepoints in the past that we
        % care about.
        L_in = weights_on_msn_from_lman * lman_noise(:,tt,motif);
        
        for m = 1:msn_units
            L = ones(hvc_units, 1) * L_in(m,:); % past lman activity
            H = hvc_output(:,tt) .* (weights_on_msn_from_hvc(m,:)' * ones(1, length(ekernel))) ; % past hvc activity, as seen thru synapses
            
            % This is the convolution! Past LMAN and HVC activities
            % mutliplied by the kernel and summed. This gives the value of
            % the convolution at the CURRENT time step, which is all we
            % care about.
            eligibility_trace(m,:) = sum(L .* H .* ekernel_matrix, 2);
        end
    end
end