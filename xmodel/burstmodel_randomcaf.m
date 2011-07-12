%% LMAN neurons are bursty!
% Each has probability of bursting and bias from Area X just adjusts that
% probability. Each burst has identical size and shape. Bursts CAN overlap.

close all
clear all
debugging = false;
%% Parameters

% Length of simulation
total_motifs = 800; % number of motifs in simulation
baseline_motifs = 300; % number of motifs before learning starts

% Size of the network
hvc_units = 50; % number of units in hvc
ra_units = 1;
lman_units = 2; % number of units in lman
msn_units = lman_units * hvc_units; % number of units in x

% Time
dt = 0.001; % seconds, time step
t_hvc = 0.005; % seconds, length of HVC burst
hvc_steps = t_hvc / dt;
motif_steps = hvc_steps * hvc_units; 
% Length of motif is the length of one HVC burst times the number of HVC
% neurons
total_steps = motif_steps * total_motifs;
lman_burst_width = 30;

% Learning rates
msn_learning_rate = 2e-8; % learning rate in HVC->X synapse
ra_learning_rate = 0; % learning rate in HVC->RA synapse
reward_learning_rate = .2; % learning rate of state value function V(s)

% Other
dlm_baseline_rate = 0.05;
msn_threshold = 0;

% Eligibility trace
x = 1:200;
mu = 100;
sig = 25;
ekernel = 1 / sqrt(2 * pi * sig .^ 2) * exp(-(x - mu) .^ 2 ./ (2 * sig .^ 2));
ekernel = ekernel./max(ekernel);
t_ekernel = 0:length(ekernel) - 1;

x = 1:200;
mu = 80;
sig = 25;
rkernel = 1 / sqrt(2 * pi * sig .^ 2) * exp(-(x - mu) .^ 2 ./ (2 * sig .^ 2));
rkernel = rkernel ./ max(rkernel);
t_rkernel = 0:length(rkernel) - 1;

if debugging
    figure
    axes('FontSize', 16)
    plot(t_ekernel, ekernel, 'b', t_rkernel, rkernel, 'g')
    title('Kernels: reward in green, eligibility in blue')
end


% The template, aka the sequence we are trying to learn.
template = zeros(1, motif_steps);

% conditional auditory feedback
caf_target_time1 = 100; % time steps
caf_target_time2 = 125;
caf_pitch_threshold1 = 0; % hits if above this
caf_pitch_threshold2 = 0; % hits if below this
caf_error_value = 40;
caf_noise_duration = 20; % time steps

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
hvc_centers = round((0.5:hvc_units-0.5)*hvc_steps);
weights_on_ra_from_hvc = template(hvc_centers);

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

% LMAN burst
t_lman_burst = 0:lman_burst_width - 1;
lman_burst = cos(t_lman_burst / lman_burst_width * pi - pi / 2);

% Two LMAN units with opposite effects on the single RA neuron.
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

extra_steps = min(length(rkernel), length(ekernel));
expected_reward = zeros(motif_steps + extra_steps, total_motifs + 1);
reward = zeros(motif_steps, total_motifs);
eligibility_matrix = zeros(msn_units, hvc_units);
is_escape = true(1, total_motifs);
if debugging
    wall = zeros(msn_units, motif_steps, total_motifs);
end


%% Main loop
for motif = 1:total_motifs
    eligibility_trace = zeros(msn_units, motif_steps + extra_steps);
    error = zeros(1, motif_steps + extra_steps);
    steps_to_noise = 0;
    for t = 1 + lman_burst_width / 2:motif_steps + extra_steps

        if t <= motif_steps
            % X activity is determined by input from HVC
            msn_input = weights_on_msn_from_hvc * hvc_output(:, t);
            msn_output(:, t, motif) = max(msn_input - msn_threshold, 0);
            % NOTE: LMAN has no immediate effect on HVC activity. Need to justify
            % this asymmmetry!


            pallidal_input = weights_on_pallidus_from_msn * msn_output(:, t, motif);
            pallidal_output(:, t, motif) = pallidal_input;

            % DLM neurons receive input from pallidus that is added to a
            % baseline firing rate that can be set in the Paramters
            % section.
            dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, t, motif);
            dlm_output(:, t, motif) = dlm_input + dlm_baseline_rate;

            % LMAN neurons 
            lman_input = weights_on_lman_from_dlm * dlm_output(:, t, motif);
            for u = 1:lman_units
                if lman_input(u) > 1 && debugging
                    disp('LMAN input is off the charts!!')
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
                    eligibility_trace(u_msn, t + t_ekernel) = ...
                        eligibility_trace(u_msn, t + t_ekernel) + ...
                        lman_output(u_lman, t, motif) .* hvc_output(u_hvc, t - lman_burst_width / 2) * ekernel;
                end
            end
            
            % Conditional auditory feedback
            above_threshold1 = ra_output(1, caf_target_time1, motif) > caf_pitch_threshold1;
            below_threshold2 = ra_output(1, caf_target_time2, motif) < caf_pitch_threshold2;
            if t == caf_target_time2 && (above_threshold1 || below_threshold2)
                 is_escape(motif) = false;
                 steps_to_noise = caf_noise_duration;
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
        if motif > baseline_motifs

            for u_lman = 1:lman_units
                u_msn = (u_lman - 1) * hvc_units + (1:hvc_units);
                eligibility_matrix(u_msn, :) = diag(eligibility_trace(u_msn, t));
            end
            dw = eligibility_matrix .* rpe .* msn_learning_rate;
            weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;
            
            % Make sure these synaptic weights are between 0 and 1 (hard
            % limits)
            weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvng node entry for MFT entry 
  INFO  | Node entry for MFT entry was successfully constructed 
  INFO  | Start of getting file parametres(size, time, date) 
  INFO  | End of getting file parametres(size, time, date) 
  INFO  | !!!---Entering the parsing loop---!!! 
  INFO  | !!!---End the parsing loop---!!! 
  INFO  | --> read MFT record 366900 
  INFO  | Mft read mode is FAST 
  INFO  | Try to apply Sector Fixups 
  INFO  | End of apply Sector Fixups 
  INFO  | ------MFT RECORD DUMP------ 
  INFO  | MFT record name --- 3_40372.1453009259_7_13_3_29_14.wav 
  INFO  | MFT record parent dir --- 366789 
  INFO  | MFT record file size --- 115244 
  INFO  | MFT record first cluster --- 3118504 
  INFO  | MFT record is directory --- 0 
  INFO  | ------END OF MFT RECORD DUMP------ 
  INFO  | file name: 3_40372.1453009259_7_13_3_29_14.wav 
  INFO  | Constructing node entry for MFT entry 
  INFO  | Node entry for MFT entry was successfully constructed 
  INFO  | Start of getting file parametres(size, time, date) 
  INFO  | End of getting file parametres(size, time, date) 
  INFO  | !!!---Entering the parsing loop---!!! 
  INFO  | !!!---End the parsing loop---!!! 
  INFO  | --> read MFT record 366901 
  INFO  | Mft read mode is FAST 
  INFO  | Try to apply Sector Fixups 
  INFO  | End of apply Sector Fixups 
  INFO  | ------MFT RECORD DUMP------ 
  INFO  | MFT record name --- 3_40372.1458564815_7_13_3_30_2.wav 
  INFO  | MFT record parent dir --- 366789 
  INFO  | MFT record file size --- 94764 
  INFO  | MFT record first cluster --- 17232080 
  INFO  | MFT record is directory --- 0 
  INFO  | ------END OF MFT RECORD DUMP------ 
  INFO  | file name: 3_40372.1458564815_7_13_3_30_2.wav 
  INFO  | Constructing node entry for MFT entry 
  INFO  | Node entry for MFT entry was successfully constructed 
  INFO  | Start of getting file parametres(size, time, date) 
  INFO  | End of getting file parametres(size, time, date) 
  INFO  | !!!---Entering the parsing loop---!!! 
  INFO  | !!!---End the parsing loop---!!! 
  INFO  | --> read MFT record 366902 
  INFO  | Mft read mode is FAST 
  INFO  | Try to apply Sector Fixups 
  INFO  | End of apply Sector Fixups 
  INFO  | ------MFT RECORD DUMP------ 
  INFO  | MFT record name --- 3_40372.1467361111_7_13_3_31_18.wav 
  INFO  | MFT record parent dir --- 366789 
  INFO  | MFT record file size --- 189484 
  INFO  | MFT record first cluster --- 3118533 
  INFO  | MFT record is directory --- 0 
  INFO  | ------END OF MFT RECORD DUMP------ 
  INFO  | file name: 3_40372.1467361111_7_13_3_31_18.wav 
  INFO  | Constructing node entry for MFT entry 
  INFO  | Node entry for MFT entry was successfully constructed 
  INFO  | Start of getting file parametres(size, time, date) 
  INFO  | End of getting file parametr