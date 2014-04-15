%% Connections

lman_units = 2 * ra_units;
msn_units = lman_units * hvc_units;
total_motifs = baseline_motifs + learning_motifs + ending_motifs;


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
dlm_output      = zeros(lman_units, motif_steps, total_motifs);
ra_output       = zeros(ra_units,   motif_steps, total_motifs);

%% Synaptic weights

% Start with the motor pathway empty
weights_on_ra_from_hvc = zeros(ra_units, hvc_units);

% There are two units in LMAN for each unit in RA. This is a "push/pull"
% control system where one LMAN unit pushes the activity of the RA unit up
% and activity in the other LMAN unit pulls the activity of the RA unit
% down.
ell = 1;
weights_on_ra_from_lman = zeros(ra_units, lman_units);
for r = 1:ra_units
    weights_on_ra_from_lman(r, ell) = 1;
    weights_on_ra_from_lman(r, ell + 1) = -1;
    ell = ell + 2;
end

% One-to-one connections to relay pallidal output to LMAN through DLM
weights_on_dlm_from_pallidus = -eye(lman_units); % inhibitory
weights_on_lman_from_dlm = eye(lman_units);

% Topographic LMAN-X-DLM loop
weights_on_msn_from_hvc = zeros(msn_units, hvc_units);
weights_on_msn_from_lman = zeros(msn_units, lman_units);
weights_on_pallidus_from_msn = zeros(lman_units, msn_units);
m = 0;
for ell = 1:lman_units
    for h = 1:hvc_units
        m = m + 1;
        weights_on_msn_from_hvc(m, h) = 1e-3; % start small. these weights are learned
        weights_on_msn_from_lman(m, ell) = 1;
        weights_on_pallidus_from_msn(ell, m) = -1; % inhibitory
    end
end

%% Generate intrinsic noise in LMAN
lman_noise = zeros(lman_units, motif_steps, total_motifs);
for u = 1:lman_units
    lman_noise(u, :, :) = generate_lman_noise_mes010(motif_steps, total_motifs);
end

%% Eligibility trace
x = -4*std_etrace:4*std_etrace;
ekernel = 1 / sqrt(2 * pi * std_etrace .^ 2) * exp(-(x) .^ 2 ./ (2 * std_etrace .^ 2));
ekernel = ekernel./sum(ekernel);
t_ekernel = 0:length(ekernel) - 1;

%% Reward kernel
x = -4*std_rkernel:4*std_rkernel;
rkernel = 1 / sqrt(2 * pi * std_rkernel .^ 2) * exp(-(x) .^ 2 ./ (2 * std_rkernel .^ 2));
rkernel = rkernel ./ sum(rkernel);
t_rkernel = 0:length(rkernel) - 1;

%%
extra_steps = max(length(rkernel), length(ekernel)); %%%DEBUG
expected_reward = zeros(motif_steps + extra_steps - 1, total_motifs + 1);
reward = zeros(motif_steps + extra_steps - 1, total_motifs);
eligibility_matrix = zeros(msn_units, hvc_units);
is_escape = true(1, total_motifs);
is_random_hit = false(1, total_motifs);