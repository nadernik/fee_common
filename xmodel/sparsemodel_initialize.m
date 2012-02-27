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
msn_output      = zeros(msn_units,  motif_steps, total_motifs);
pallidal_output = zeros(lman_units, motif_steps, total_motifs);
dlm_output      = zeros(lman_units, motif_steps, total_motifs);
ra_output       = zeros(ra_units,   motif_steps, total_motifs);

%% Synaptic weights

% Start with the motor pathway empty
weights_on_ra_from_hvc = zeros(ra_units, hvc_units);

% There are two units in LMAN. One increases RA activity and one decreases
% RA activity. FIXME add explanation for pitch up and pitch down channels.
weights_on_ra_from_lman = [1, -1] ./ sqrt(2);

% One-to-one connections to relay pallidal output to LMAN through DLM
weights_on_dlm_from_pallidus = -eye(lman_units); % inhibitory
weights_on_lman_from_dlm = eye(lman_units);

% Topographic LMAN-X-DLM loop
weights_on_msn_from_hvc = msn_initial_weight*rand(msn_units, hvc_units);
winit = weights_on_msn_from_hvc;
weights_on_msn_from_lman = zeros(msn_units, lman_units);
weights_on_pallidus_from_msn = zeros(lman_units, msn_units);
m = 0;
msns_per_lman = floor(msn_units / lman_units);
for ell = 1:lman_units
    m = (1:(msns_per_lman)) + msns_per_lman*(ell-1);
    weights_on_msn_from_lman(m, ell) = exp(log(16)*rand(length(m),1) + log(0.25)); % random between 0.5 and 2
    weights_on_pallidus_from_msn(ell, m) = -1; % inhibitory
end

% Lateral inhibition across MSNs
weights_on_msn_from_msn = -inhib_str*(ones(msn_units) + eye(msn_units));

%% Generate intrinsic noise in LMAN
lman_noise = zeros(lman_units, motif_steps, total_motifs);
for u = 1:lman_units
    z = generate_lman_noise(motif_steps, total_motifs);
    
    lman_noise(u, :, :) = z / std(z(:));
end



%% Eligibility trace
x = -4*std_etrace:4*std_etrace;
ekernel = 1 / sqrt(2 * pi * std_etrace .^ 2) * exp(-(x) .^ 2 ./ (2 * std_etrace .^ 2));
ekernel = ekernel./sum(ekernel);
ekernel_matrix = ones(hvc_units,1) * ekernel;

%% Reward kernel
x = -4*std_rkernel:4*std_rkernel;
rkernel = 1 / sqrt(2 * pi * std_rkernel .^ 2) * exp(-(x) .^ 2 ./ (2 * std_rkernel .^ 2));
rkernel = rkernel ./ sum(rkernel);

%%
assert(length(rkernel) == length(ekernel))
extra_steps = length(rkernel) - 1;
instantaneous_error = zeros(1, motif_steps+extra_steps);
expected_reward = zeros(motif_steps + extra_steps, total_motifs + 1);
reward = zeros(motif_steps + extra_steps, total_motifs);
is_escape = true(1, total_motifs);
is_random_hit = false(1, total_motifs);

% Initialize empty eligibility trace matrix. Each entry in this matrix is
% the eligibility of one HVC-X synapse. 
eligibility_trace = zeros(msn_units, hvc_units, motif_steps+extra_steps);