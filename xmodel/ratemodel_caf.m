% 100 motifs without learning -- get baseline singing and let V(s) converge
% 500 motifs to learn -- hopefully for the last 100 motifs of this, we are
% at a stable learned state

% Start with song learned -- HVC->RA synapses non zero
% No consolidation -- HVC->RA synapse learning rate is zero

close all
clear all
debugging = true;
%% Parameters

total_motifs = 500; % number of motifs in simulation
baseline_motifs = 100; % number of motifs before learning starts

% Size of the network
hvc_units = 50; % number of units in hvc
ra_units = 1;
lman_units = 1; % number of units in lman
msn_units = lman_units * hvc_units; % number of units in x

% Time
dt = 0.001; % seconds, time step
t_hvc = 0.005; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
t_lman = 0.2; % seconds, timescale of fluctuations in lman

hvc_steps = t_hvc / dt;
motif_steps = hvc_steps * hvc_units;
total_steps = motif_steps * total_motifs;



% Learning rates and other fudge factors
msn_learning_rate = .01; % learning rate in HVC->X synapse
ra_learning_rate = 0; % learning rate in HVC->RA synapse
reward_learning_rate = .2; % learning rate of state value function V(s)
eligibility_discount_rate = 0.98;

randomness_amplitude = 0.25;
msn_threshold = 0;
ra_synapse_decay = 0;

x = 1:100;
kernel = x.^8 .* exp(-(x./20).^2);
kernel = kernel ./ max(kernel);
t_kernel = 0:length(kernel) - 1;

% conditional auditory feedback
caf_target_time = 125; % time steps
caf_pitch_threshold = 1;
caf_error_value = 3;
caf_noise_duration = 5; % time steps

% The template, aka the sequence we are trying to learn.
t = linspace(0, 1, motif_steps);
template = -8e2 * t .* (t - 0.25).^2 .* (t - 0.7) .* (t - 0.8) .* (t - 1) + 0.1;

%% Initialize

% "State" is the HVC unit that is currently firing.
s = @(t) modnonzero(t, motif_steps);

% Neural activity
hvc_output = zeros(hvc_units, motif_steps);
lman_output = zeros(lman_units, total_steps);
msn_output = zeros(msn_units,    total_steps);
pallidal_output = zeros(lman_units, total_steps);
dlm_output = zeros(lman_units, total_steps);
ra_output = zeros(ra_units,   total_steps);

% Weights
weights_on_msn_from_hvc = zeros(msn_units, hvc_units);
weights_on_msn_from_lman = zeros(msn_units, lman_units);
weights_on_pallidus_from_msn = zeros(lman_units, msn_units);
weights_on_dlm_from_pallidus = -eye(lman_units); % inhibitory
weights_on_lman_from_dlm =  eye(lman_units);
hvc_centers = round((0.5:hvc_units-0.5)*hvc_steps); 
weights_on_ra_from_hvc = template(hvc_centers);

x = linspace(0, pi, hvc_steps * 2);
burst = sin(x).^2;
for u = 1:hvc_units
    offset = (u - 1) * hvc_steps;
    t = modnonzero((1:2*hvc_steps) + offset, motif_steps);
    hvc_output(u, t) = burst;
end


% Two LMAN units with opposite effects on the single RA neuron.
% W_RL = [1, -1];
weights_on_ra_from_lman = 1;

% Make LMAN neurons fire randomly
randomness = zeros(lman_units, total_steps);
for u = 1:lman_units
    randomness(u, :) = randomness_amplitude * smoothnoise(total_steps, t_lman / dt);
end
% randomness = max(randomness, 0);
lman_output(:, 1) = max(randomness(:, 1), 0);

% fill in weights for LMAN-X-DLM loop
m = 0;
for h = 1:hvc_units
    for ell = 1:lman_units
        m = m + 1;
        weights_on_msn_from_hvc(m, h) = 1e-3; % start small. these weights are learned 
        weights_on_msn_from_lman(m, ell) = 1;
        weights_on_pallidus_from_msn(ell, m) = -1; % inhibitory
    end
end
winit = weights_on_msn_from_hvc;

% Initialize empty matrices for activity in other neurons
eligibility_trace = zeros(msn_units, total_steps + length(kernel));
expected_reward = zeros(1, motif_steps);
error = zeros(1,total_steps + length(kernel));

if debugging
    Vall = zeros(total_motifs, motif_steps);
    dw = zeros(size(weights_on_msn_from_hvc));
    dwall = zeros(total_steps, msn_units);
    wall = zeros(total_steps, msn_units);
end
is_escape = false(1, total_motifs);
steps_to_noise = 0;
%% Main loop
for t = 1:total_steps
    current_motif = ceil(t / motif_steps);
    
    % X activity is determined by input from HVC
    msn_input = weights_on_msn_from_hvc * hvc_output(:, s(t));
    msn_output(:, t) = max(msn_input - msn_threshold, 0);
    % NOTE: LMAN has no immediate effect on HVC activity. Need to justify
    % this asymmmetry!

    pallidal_input = weights_on_pallidus_from_msn * msn_output(:, t);
    pallidal_output(:, t) = pallidal_input;
    
    dlm_input = weights_on_dlm_from_pallidus * pallidal_output(:, t);
    dlm_output = dlm_input;

    % LMAN activity is the sum of intrinsic randomness and input from DLM
    lman_input = randomness(:, t);% + weights_on_lman_from_dlm * D(:, t);
    lman_output(:, t) = max(lman_input, 0); % Firing rates must be positive

    % RA activity is the sum of inputs from HVC and LMAN
    ra_input = weights_on_ra_from_hvc * hvc_output(:, s(t)) + weights_on_ra_from_lman * lman_output(:, t); 
    ra_output(:, t) = ra_input;
    
    %% Auditory Feedback
    
    % Conditional auditory feedback
    if s(t) == caf_target_time
        if ra_output(1, t) < caf_pitch_threshold
            % hit
            steps_to_noise = caf_noise_duration;
            is_escape(current_motif) = false;
        else
            % escape
            is_escape(current_motif) = true;
        end
    end
    
    % Instantaneous error
    if steps_to_noise > 0
        instantaneous_error = caf_error_value;
        steps_to_noise = steps_to_noise - 1;
    else
        instantaneous_error = (ra_output(:, t) - template(:, s(t))).^2;
    end
    error(t + t_kernel) = error(t + t_kernel) + instantaneous_error * kernel;


    reward = -error(t);
    rpe = reward - expected_reward(s(t));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Learning
    
    %
    %% Update expected state value
    expected_reward(s(t)) = expected_reward(s(t)) + reward_learning_rate * rpe;

    %
    %% Update synaptic weights only if we are past the baseline period
    if current_motif > baseline_motifs
        % Update eligibility trace
        %    - Uses same kernel as error
        %    - This code will NOT generalize to multiple LMAN neurons
        %    - This code will NOT generalize to all-to-all HVC connections
        eligibility_trace(:, t + t_kernel) = ...
            eligibility_trace(:, t + t_kernel) + ...
            lman_output(1, t) .* hvc_output(:, s(t)) * kernel;

        eligibility_matrix = diag(eligibility_trace(:, t));
        dw = eligibility_matrix .* rpe .* msn_learning_rate;
        weights_on_msn_from_hvc = weights_on_msn_from_hvc + dw;
        % Make sure these synaptic weights are nonnegative.
        weights_on_msn_from_hvc = max(0, weights_on_msn_from_hvc);

%         dw = ra_output * hvc_output %%%FIXME
%         weights_on_ra_from_hvc  = weights_on_ra_from_hvc + dw;

    end
    
    % Bookkeeping
    if debugging
        Vall(ceil(t/motif_steps), s(t)) = expected_reward(s(t));
        wall(t,:) = diag(weights_on_msn_from_hvc);
        dwall(t,:) = diag(dw);
    end
    
end

%% autocorrelation of LMAN fluctuations
figure
maxlag = 200;
[c, lags] = xcorr(randomness(1,:), maxlag, 'coeff');
axes('FontSize', 16)
plot(lags, c)
xlabel('Lag (ms)')
ylabel('Autocorrelation, normalized')
ylim([-0.2 1.2])
title('LMAN autocorrelation')

%% learning (change in pitch) normalized

% calculate actual learning
pre  = gettrials(ra_output,   1:20, motif_steps);
post = gettrials(ra_output, -20:-1, motif_steps);
learning = mean(post, 2) - mean(pre, 2);
learning = learning ./ max(learning);

% calculate predicted learning based on reinforced lman fluctuations
mo = find(is_escape);
mo = mo(mo < baseline_motifs);
rewarded = gettrials(ra_output, mo, motif_steps);
predicted = mean(rewarded, 2) - mean(pre, 2);
predicted = predicted ./ max(predicted);

figure
t = 1:motif_steps;
t = t - mean(t(s(t) == caf_target_time));
axes('FontSize', 16)
plot(t, learning, 'k')
hold on
plot(t, predicted, 'r')
xlabel('Time from target (ms)')
ylabel('Learning, normalized')
title('Actual and predicted learning')

%% Pitch distributions before and after, showing CAF threshold

% Overlayed pitch traces with target time highlighted
figure
axes('FontSize', 16)
hold on
pre = gettrials(ra_output, 1:baseline_motifs, motif_steps);
plot(pre, 'Color', [.8 .8 .8])
plot(mean(pre, 2), 'k')
ylo = min(min(pre));
yhi = max(max(pre));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
t = 1:motif_steps;
xtarg = find(s(t) == caf_target_time);
X = [min(xtarg) max(xtarg) max(xtarg) min(xtarg)];
Y = [ylo        ylo        yhi        yhi];
fill(X, Y, [1 1 .7], 'FaceAlpha', 0.5)
xlim([1 motif_steps])
ylim([ylo yhi])
xlabel('Time (ms)')
ylabel('"Pitch"')
title('Songs, baseline')

% histogram of pitches in target time
figure
axes('FontSize', 16)
pitchtarg = pre(xtarg, :);
hist(pitchtarg, .2:0.05:1.6)
xlabel('"Pitch"')
ylabel('N')
title('Histogram of pitch at target time')
%% mean pitch traces beginning and ending (not normalized)
% figure
% axes('FontSize', 16)
% n = 20; % number of trials to average
% Y = gettrials(R, -n:-1, motif_steps);
% final = mean(Y, 2); 
% Y = gettrials(R, 1:n, motif_steps);
% start = mean(Y, 2);
% plot(start, 'k')
% hold on
% plot(final, 'r')
% xlabel('Time (ms)')
% ylabel('"Pitch"')
% title('Song, before and after')

%% weights over time
figure
axes('FontSize', 16)
x = 1:50;
y = linspace(0, total_motifs,size(wall,1));
imagesc(x, y, wall)
xlabel('HVC-X Synapse')
ylabel('Motif')

% figure
% plot(wall(:, [11, 25, 34]))

%%


%% rpe-eligibility trace correlations at problem time
% figure
% Y = gettrials(rpe, 1:P.motifs, motif_steps);
% yrpe = Y(s(1:motif_steps) == 36, :);
% Y = gettrials(eall(:,35), 1:P.motifs, motif_steps);
% yetrace = Y(s(1:motif_steps) == 36, :);
% scatter(yrpe(:), yetrace(:))
% plot(yrpe(:))

%% RPE over time
% figure
% axes('FontSize', 16)
% Y = gettrials(rpe, 1:P.motifs, motif_steps);
% imagesc(Y')
% title('rpe')
% xlabel('Time (ms)')
% ylabel('Motif')

%% Error over time
% figure
% Y = gettrials(error, 1:P.motifs, motif_steps);
% imagesc(Y')
% title('error')