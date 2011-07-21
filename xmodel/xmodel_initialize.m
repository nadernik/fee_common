%% Neural activity
hvc_output      = zeros(hvc_units,  motif_steps);
lman_input      = zeros(lman_units, motif_steps);
lman_output     = zeros(lman_units, motif_steps, total_motifs);
msn_output      = zeros(msn_units,  motif_steps, total_motifs);
pallidal_output = zeros(lman_units, motif_steps);
dlm_output      = zeros(lman_units, motif_steps, total_motifs);
ra_output       = zeros(ra_units,   motif_steps, total_motifs);

%% Synaptic weights

% Start with the motor pathway (HVC -> RA) matching the template
hvc_centers = round((0.5:hvc_units-0.5)*hvc_steps);
weights_on_ra_from_hvc = template(hvc_centers);

% There are two units in LMAN. One increases RA activity and one decreases
% RA activity. FIXME add explanation for pitch up and pitch down channels.
weights_on_ra_from_lman = [1, -1];

weights_on_msn_from_hvc = zeros(msn_units, hvc_units);
weights_on_msn_from_lman = zeros(msn_units, lman_units);
weights_on_pallidus_from_msn = zeros(lman_units, msn_units);
weights_on_dlm_from_pallidus = -eye(lman_units); % inhibitory
weights_on_lman_from_dlm = eye(lman_units);

% fill in weights for LMAN-X-DLM loop
m = 0;
for ell = 1:lman_units
    for h = 1:hvc_units
        m = m + 1;
        weights_on_msn_from_hvc(m, h) = 1e-3; % start small. these weights are learned
        weights_on_msn_from_lman(m, ell) = 1;
        weights_on_pallidus_from_msn(ell, m) = -1; % inhibitory
    end
end


%% Make one motif of HVC activity

x = linspace(0, pi, hvc_steps * 2);
cosburst = cos(x).^2;
cosburst = cosburst([hvc_steps+1:hvc_steps*2, 1:hvc_steps]);
sinburst = sin(x).^2;
for u = 1:hvc_units
    offset = (u - 1) * hvc_steps;
    t = modnonzero((1:2*hvc_steps) + offset, motif_steps);
    if mod(u, 2) == 1 % odd bursts are cosine
        hvc_output(u, t) = cosburst;
    else
        hvc_output(u, t) = sinburst;
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