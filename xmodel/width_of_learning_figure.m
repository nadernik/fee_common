for dc = 
%% Parameters

% Length of simulation
baseline_motifs = 200; % number of motifs before learning starts
learning_motifs = 500; % number of motifs where learning happens!
ending_motifs = 200; % number of motifs without learning at end of sim
total_motifs = baseline_motifs + learning_motifs + ending_motifs;

% Size of the network
hvc_units = 50; % number of units in hvc - change this to control length of song

% There is one RA unit representing the output of the system. It might be
% better to think of it as "pitch"
ra_units = 1;
% There are two LMAN units. One increases pitch and one decreases pitch.
lman_units = 2; 
% There is also one pallidal and one DLM unit for each LMAN unit
msn_units = lman_units * hvc_units; % Medium Spiny Neurons

% Time
dt = 0.001; % seconds, time step
t_hvc = 0.005; % seconds, length of HVC burst
hvc_steps = t_hvc / dt;
motif_steps = hvc_steps * hvc_units; 
% Length of motif is the length of one HVC burst times the number of HVC
% neurons
total_steps = motif_steps * total_motifs;

% Learning rates
msn_learning_rate = 1e-8; % learning rate in HVC->X synapse
ra_learning_rate = 0; % learning rate in HVC->RA synapse
reward_learning_rate = .2; % learning rate of state value function V(s)

% Other
msn_threshold = 0;

% Synaptic eligibility trace and reward signal are both Gaussians with 4
% standard deviations before and after the mean. That puts a 4 standard
% deviation delay to peak of response

% Eligibility trace
sig = 50;
x = -4*sig:4*sig;
ekernel = 1 / sqrt(2 * pi * sig .^ 2) * exp(-(x) .^ 2 ./ (2 * sig .^ 2));
ekernel = ekernel./max(ekernel);
t_ekernel = 0:length(ekernel) - 1;

% Reward
sig = 50;
x = -4*sig:4*sig;
rkernel = 1 / sqrt(2 * pi * sig .^ 2) * exp(-(x) .^ 2 ./ (2 * sig .^ 2));
rkernel = rkernel ./ max(rkernel);
t_rkernel = 0:length(rkernel) - 1;

% The template, aka the sequence we are trying to learn.
template = zeros(1, motif_steps);

% conditional auditory feedback
caf_target_time1 = 5; % time steps
caf_target_time2 = 100;
caf_pitch_threshold1 = nan; % hits if above this
caf_pitch_threshold2 = 2; % hits if below this
caf_random_hit_probability = 0;
caf_error_value = 800;
caf_noise_duration = 20; % time steps

%% Initialize

% Neural activity
hvc_output      = zeros(hvc_units,  motif_steps);
lman_input      = zeros(lman_units, motif_steps);
lman_output     = zeros(lman_units, motif_steps, total_motifs);
msn_output      = zeros(msn_units,  motif_steps, total_motifs);
pallidal_output = zeros(lman_units, motif_steps, total_motifs);
dlm_output      = zeros(lman_units, motif_steps, total_motifs);
ra_output       = zeros(ra_units,   motif_steps, total_motifs);

% Synaptic weights
weights_on_msn_from_hvc = zeros(msn_units, hvc_units);
weights_on_msn_from_lman = zeros(msn_units, lman_units);
weights_on_pallidus_from_msn = zeros(lman_units, msn_units);
weights_on_dlm_from_pallidus = -eye(lman_units); % inhibitory
weights_on_lman_from_dlm = eye(lman_units);
hvc_centers = round((0.5:hvc_units-0.5)*hvc_steps);
weights_on_ra_from_hvc = template(hvc_centers);
% Two LMAN units with opposite effects on the single RA neuron.
weights_on_ra_from_lman = [1, -1];

% Make one motif of HVC activity
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

% Generate intrinsic noise in LMAN
lman_noise = zeros(lman_units, motif_steps, total_motifs);
for u = 1:lman_units
    lman_noise(u, :, :) = generate_lman_noise(motif_steps, total_motifs);
end

extra_steps = max(length(rkernel), length(ekernel)); %%%DEBUG
expected_reward = zeros(motif_steps + extra_steps, total_motifs + 1);
reward = zeros(motif_steps, total_motifs);
eligibility_matrix = zeros(msn_units, hvc_units);
is_escape = true(1, total_motifs);
is_random_hit = false(1, total_motifs);

%% Main loop
for motif = 1:total_motifs
    eligibility_trace = zeros(msn_units, motif_steps + extra_steps);
    error = zeros(1, motif_steps + extra_steps);
    steps_to_noise = 0;
    for t = 1:motif_steps + extra_steps

        if t <= motif_steps
            % MSN activity is determined by input from HVC. LMAN has no
            % effect.
            msn_input = weights_on_msn_from_hvc * hvc_output(:, t);
            msn_output(:, t, motif) = max(msn_input - msn_threshold, 0);

            
            % Each LMAN unit has a corresponding pallidal unit. The
            % pallidal unit sums the activity 
            pallidal_input = weights_on_pallidus_from_msn * msn_output(:, t, motif);
            pallidal_output(:, t, motif) = pallidal_input;

            dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, t, motif);
            dlm_output(:, t, motif) = dlm_input;

            % LMAN activity is the sum of intrinsic noise 
            lman_input(:, t) = lman_noise(:,t,motif) + weights_on_lman_from_dlm * dlm_output(:, t, motif);
            lman_output(:,t,motif) = lman_input(:, t);

            % RA activity is the sum of inputs from HVC and LMAN
            ra_input = weights_on_ra_from_hvc * hvc_output(:, t) + weights_on_ra_from_lman * lman_output(:, t, motif);
            ra_output(:, t, motif) = ra_input + dc_offset(motif);

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

            for u_lman = 1:lman_units
                u_msn = (u_lman - 1) * hvc_units + (1:hvc_units);
                eligibility_matrix(u_msn, :) = diag(eligibility_trace(u_msn, t));
            end
            dw = eligibility_matrix .* rpe .* msn_learning_rate;
            weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;
            
            % Make sure these synaptic weights are not negative
            weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvc);
        end
    end
end
