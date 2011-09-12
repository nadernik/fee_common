%% Neural activity

% Make one motif of the HVC chain
hvc_output = zeros(hvc_units,  motif_steps);
t_burst = 1:9;
sinburst = sin((t_burst-1)/8*pi).^2;
for u = 1:hvc_units
    hvc_output(u, t_burst) = sinburst;
    t_burst = modnonzero(t_burst + hvc_burst_shift, motif_steps);
end

% Initialize empty matrices for other units
lman_input      = zeros(lman_units, motif_steps);
lman_output     = zeros(lman_units, motif_steps, total_motifs);
direct_msn_output      = zeros(msn_units,  motif_steps, total_motifs);
indirect_msn_output      = zeros(msn_units,  motif_steps, total_motifs);
pallidal_output = zeros(lman_units, motif_steps);
dlm_output      = zeros(lman_units, motif_steps, total_motifs);
ra_output       = zeros(ra_units,   motif_steps, total_motifs);

%% Synaptic weights

% Start with the motor pathway empty
weights_on_ra_from_hvc = zeros(ra_units, hvc_units);

% There are two units in LMAN. One increases RA activity and one decreases
% RA activity. FIXME add explanation for pitch up and pitch down channels.
weights_on_ra_from_lman = [1, -1];

% One-to-one connections to relay pallidal output to LMAN through DLM
weights_on_dlm_from_pallidus = -eye(lman_units); % inhibitory
weights_on_lman_from_dlm = eye(lman_units);

% Topographic LMAN-X-DLM loop
weights_on_direct_msn_from_hvc = zeros(hvc_units * lman_units,1);
weights_on_indirect_msn_from_hvc = zeros(hvc_units * lman_units,1);
weights_on_direct_msn_from_lman = zeros(msn_units, lman_units);
weights_on_indirect_msn_from_lman = zeros(msn_units, lman_units);
weights_on_pallidus_from_direct_msn = zeros(lman_units, msn_units);
weights_on_pallidus_from_indirect_msn = zeros(lman_units, msn_units);
m = 0;
for ell = 1:lman_units
    for h = 1:hvc_units
        m = m + 1;
        weights_on_direct_msn_from_hvc(m) = 1e-3; % start small. these weights are learned
        weights_on_indirect_msn_from_hvc(m) = 1e-3; % start small. these weights are learned
        
        weights_on_direct_msn_from_lman(m, ell) = 1;
        weights_on_indirect_msn_from_lman(m, ell) = 1;
        
        weights_on_pallidus_from_direct_msn(ell, m) = -1; % inhibitory
        weights_on_pallidus_from_indirect_msn(ell, m) = 1; % excitatory
    end
end

%% Generate intrinsic noise in LMAN
lman_noise = zeros(lman_units, motif_steps, total_motifs);
for u = 1:lman_units
    lman_noise(u, :, :) = generate_lman_noise(motif_steps, total_motifs);
end

%% Eligibility trace
x = -4*std_etrace:4*std_etrace;
ekernel = 1 / sqrt(2 * pi * std_etrace .^ 2) * exp(-(x) .^ 2 ./ (2 * std_etrace .^ 2));
ekernel = ekernel./max(ekernel);
t_ekernel = 0:length(ekernel) - 1;

%% Reward kernel
x = -4*std_rkernel:4*std_rkernel;
rkernel = 1 / sqrt(2 * pi * std_rkernel .^ 2) * exp(-(x) .^ 2 ./ (2 * std_rkernel .^ 2));
rkernel = rkernel ./ max(rkernel);
t_rkernel = 0:length(rkernel) - 1;

%%
extra_steps = max(length(rkernel), length(ekernel)); %%%DEBUG
expected_reward = zeros(motif_steps + extra_steps, total_motifs + 1);
reward = zeros(motif_steps, total_motifs);
eligibility_matrix = zeros(msn_units, hvc_units);
is_escape = true(1, total_motifs);
is_random_hit = false(1, total_motifs);