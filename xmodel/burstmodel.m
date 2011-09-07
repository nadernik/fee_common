%% LMAN neurons are bursty!
% Each has probability of bursting and bias from Area X just adjusts that
% probability. Each burst has identical size and shape. Bursts CAN overlap.

close all
clear all
debugging = true;
%% Parameters

% Length of simulation
total_motifs = 300; % number of motifs in simulation
baseline_motifs = 100; % number of motifs before learning starts

% Size of the network
hvc_units = 50; % number of units in hvc
ra_units = 1;
lman_units = 2; % number of units in lman
msn_units = lman_units * hvc_units; % number of units in x

% Time
dt = 0.001; % seconds, time step
t_hvc = 0.005; % seconds, length of HVC burst
t_lman = 0.010; % seconds, length of LMAN burst
hvc_steps = t_hvc / dt;
motif_steps = hvc_steps * hvc_units; 
% Length of motif is the length of one HVC burst times the number of HVC
% neurons
total_steps = motif_steps * total_motifs;
lman_burst_width = 10;

% Learning rates
msn_learning_rate = .000001; % learning rate in HVC->X synapse
ra_learning_rate = 0; % learning rate in HVC->RA synapse
reward_learning_rate = .2; % learning rate of state value function V(s)

% Other
dlm_baseline_rate = 0.1;
msn_threshold = 0;

% Eligibility trace
x = 1:200;
kernel = x.^8 .* exp(-(x./50).^2);
kernel = kernel ./ max(kernel);
t_kernel = 0:length(kernel) - 1;

% The template, aka the sequence we are trying to learn.
template = zeros(1, motif_steps);
template(80:90) = 3;
template(150:160)= -3;

%% Initialize

% Neural activity
hvc_output      = zeros(hvc_units,  motif_steps);
lman_output     = zeros(lman_units, motif_steps + lman_burst_width, total_motifs);
msn_output      = zeros(msn_units,  motif_steps, total_motifs);
pallidal_output = zeros(lman_units, motif_steps, total_motifs);
dlm_output      = zeros(lman_units, motif_steps, total_motifs);
ra_output       = zeros(ra_units,   motif_steps, total_motifs);

% Weights
weights_on_msn_from_hvc = zeros(msn_units, hvc_units);
weights_on_msn_from_lman = zeros(msn_units, lman_units);
weights_on_pallidus_from_msn = zeros(lman_units, msn_units);
weights_on_dlm_from_pallidus = -eye(lman_units); % inhibitory
weights_on_lman_from_dlm =  eye(lman_units);
% hvc_centers = round((0.5:hvc_units-0.5)*hvc_steps);
% weights_on_ra_from_hvc = template(hvc_centers);
weights_on_ra_from_hvc = zeros(ra_units, hvc_units);

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


t_lman_burst = 0:lman_burst_width - 1;
lman_burst = cos(t_lman_burst / lman_burst_width * pi - pi / 2);

% Two LMAN units with opposite effects on the single RA neuron.
% W_RL = [1, -1];
weights_on_ra_from_lman = [1, -1];

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
winit = weights_on_msn_from_hvc;

% Initialize empty matrices for activity in other neurons

expected_reward = zeros(motif_steps + length(kernel), total_motifs + 1);
reward = zeros(motif_steps, total_motifs);
if debugging
    wall = zeros(msn_units, motif_steps, total_motifs);
end
is_escape = true(1, total_motifs);
eligibility_matrix = zeros(msn_units, hvc_units);
%% Main loop
for motif = 1:total_motifs
    eligibility_trace = zeros(msn_units, motif_steps + length(kernel));
    error = zeros(1, motif_steps + length(kernel));
    steps_to_noise = 0;
    for t = 1:motif_steps + length(kernel)

        if t <= motif_steps
            % X activity is determined by input from HVC
            msn_input = weights_on_msn_from_hvc * hvc_output(:, t);
            msn_output(:, t, motif) = max(msn_input - msn_threshold, 0);
            % NOTE: LMAN has no immediate effect on HVC activity. Need to justify
            % this asymmmetry!


            pallidal_input = weights_on_pallidus_from_msn * msn_output(:, t, motif);
            pallidal_output(:, t, motif) = pallidal_input;

            dlm_input = dlm_baseline_rate + weights_on_dlm_from_pallidus * pallidal_output(:, t, motif);
            dlm_output(:, t, motif) = dlm_input;

            % LMAN activity is the sum of intrinsic randomness and input from DLM
            lman_input = weights_on_lman_from_dlm * dlm_output(:, t, motif);
            % lman_input is like the rate parameter for a poisson process
            for u = 1:lman_units
                if lman_input(u) > 1
                    warning('LMAN input is off the charts!!')
                end
                if rand <= lman_input(u)
                    % burst!
                    lman_output(u, t + t_lman_burst, motif) = lman_output(u, t + t_lman_burst, motif) + lman_burst;
                end
            end

            % RA activity is the sum of inputs from HVC and LMAN
            ra_input = weights_on_ra_from_hvc * hvc_output(:, t) + weights_on_ra_from_lman * lman_output(:, t, motif);
            ra_output(:, t, motif) = ra_input;

            % Update eligibility trace
            %    - Uses same kernel as error
            %    - This code will NOT generalize to all-to-all HVC connections
            u_msn = 0;
            for u_lman = 1:lman_units
                for u_hvc = 1:hvc_units
                    u_msn = u_msn + 1;
                    eligibility_trace(u_msn, t + t_kernel) = ...
                        eligibility_trace(u_msn, t + t_kernel) + ...
                        lman_output(u_lman, t, motif) .* hvc_output(u_hvc, t) * kernel;
                end
            end
            
            % Instantaneous error
            if steps_to_noise > 0
                instantaneous_error = caf_error_value;
                steps_to_noise = steps_to_noise - 1;
            else
                instantaneous_error = (ra_output(:, t, motif) - template(:, t)).^2;
            end
            error(t + t_kernel) = error(t + t_kernel) + instantaneous_error * kernel;
        end


        reward(t, motif) = -error(t);
        rpe = reward(t, motif) - expected_reward(t, motif);

        %
        %% Update expected state value
        expected_reward(t, motif + 1) = expected_reward(t, motif) + reward_learning_rate * rpe;

        %
        %% Update synaptic weights only if we are past the baseline period
        if motif > baseline_motifs

            for u_lman = 1:lman_units
                u_msn = (u_lman - 1) * hvc_units + (1:hvc_units);
                eligibility_matrix(u_msn, :) = diag(eligibility_trace(u_msn, t));
            end
            dw = eligibility_matrix .* rpe .* msn_learning_rate;
            weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;
            % Make sure these synaptic weights are between 0 and 1 (hard
            % limits)
            weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvc);
            weights_on_msn_from_hvc = min(1, weights_on_msn_from_hvc);

            %         dw = ra_output * hvc_output %%%FIXME
            %         weights_on_ra_from_hvc  = weights_on_ra_from_hvc + dw;

        end

        % Bookkeeping
        if debugging
            for u_lman = 1:lman_units
                u_msn = (u_lman - 1) * hvc_units + (1:hvc_units);
                wall(u_msn, t, motif) = diag(weights_on_msn_from_hvc(u_msn, :));
            end
        end

    end
end

%% mean pitch traces beginning and ending (not normalized)
figure
axes('FontSize', 16)
n = 50; % number of trials to average
final = squeeze(mean(ra_output(1, :, end-n:end), 3));
start = squeeze(mean(ra_output(1, :,     1:n  ), 3));
plot(start, 'k')
hold on
plot(final, 'r')
xlabel('Time (ms)')
ylabel('"Pitch"')
title('Song, before and after')

%% weights over time
figure
axes('FontSize', 16)
x = 1:msn_units;
y = linspace(0, total_motifs,size(wall,1));
imagesc(x, y, reshape(wall, msn_units, [])')
xlabel('HVC-X Synapse')
ylabel('Motif')