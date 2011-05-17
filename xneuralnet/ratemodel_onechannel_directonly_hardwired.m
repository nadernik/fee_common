% Rate model of Area X
% One pallidal neuron
% One DLM (thalamic) neuron
% One LMAN neuron
% 10 HVC neurons each emit one 10 ms burst
% Hard wired connectivity onto MSNs
% Direct pathway only

close all
clear all
%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.006; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.05; % seconds, timescale of fluctuations in lman
P.motifs = 500; % number of motifs in simulation

% Size of the network
P.hvcunits = 50; % number of units in hvc
P.raunits = 1;
P.lmanunits = 1; % number of units in lman
P.xunits = P.lmanunits * P.hvcunits; % number of units in x

% Learning rates and other fudge factors
P.xrate = .01; % learning rate in HVC->X synapse
P.rarate = 0; % learning rate in HVC->RA synapse
P.rperate = 0.05; % learning rate of state value function V(s)
P.discountrate = 0; % for reward prediction error. 0 means no history.

P.noiseamp = 1;
P.thresh = 0;

% The template, aka the sequence we are trying to learn.
% P.template = .5*ones(1, P.hvcunits);
t = linspace(0, 1, P.hvcunits);
P.template = -8e2 * t .* (t - 0.25).^2 .* (t - 0.7) .* (t - 0.8) .* (t - 1) + 0.1;

%% Initialize

assert(size(P.template, 1) == P.raunits)
assert(size(P.template, 2) == P.hvcunits)

hvcsteps = P.thvc / P.dt; % number of time steps in each hvc burst
motifsteps = hvcsteps * P.hvcunits; % number of time steps per motif
maxsteps = motifsteps * P.motifs; % total number of time steps to simulate

% "State" is the HVC unit that is currently firing.
s = @(t) max(1, ceil((mod(t-1, motifsteps)) / hvcsteps));

% Neural activity
H = zeros(P.hvcunits,  maxsteps);
L = zeros(P.lmanunits, maxsteps + 1);
M = zeros(P.xunits,    maxsteps);
PAL = zeros(P.lmanunits, maxsteps);
D = zeros(P.lmanunits, maxsteps);
R = zeros(P.raunits,   maxsteps);

% Weights
W_MH = zeros(P.xunits, P.hvcunits);
W_ML = zeros(P.xunits, P.lmanunits);
W_PM = zeros(P.lmanunits, P.xunits);
W_DP = -eye(P.lmanunits); % inhibitory
W_LD =  eye(P.lmanunits);
W_RL = ones(P.raunits, P.lmanunits);
W_RH = zeros(P.raunits, P.hvcunits);

% Make HVC neurons fire in a chain with each neuron bursting once per motif
onemotif = zeros(P.hvcunits, motifsteps);
for u = 1:P.hvcunits
    onemotif(u, (u-1)*hvcsteps + (1:hvcsteps)) = 1;
end
H = repmat(onemotif, 1, P.motifs);

% Make LMAN neurons fire randomly
L = zeros(P.lmanunits, maxsteps + 1);
randomness = zeros(P.lmanunits, maxsteps);
for u = 1:P.lmanunits
    randomness(u, :) = P.noiseamp * smoothnoise(maxsteps, P.tlman / P.dt);
end
% randomness = max(randomness, 0);
L(:, 1) = randomness(:, 1);

% fill in weights for LMAN-X-DLM loop
m = 0;
for h = 1:P.hvcunits
    for ell = 1:P.lmanunits
        m = m + 1;
        W_MH(m, h) = 1e-3; % start small. these weights are learned 
        W_ML(m, ell) = 1;
        W_PM(ell, m) = -1; % inhibitory
    end
end
winit = W_MH;

% Initialize empty matrices for activity in other neurons
etrace = zeros(P.xunits, P.hvcunits);
V = zeros(maxsteps + 1, P.hvcunits);
rpe = zeros(1,maxsteps);
error = zeros(1,maxsteps);
temp = zeros(1,maxsteps);

%% Main loop
for t = 1:maxsteps

    % X activity is determined by input from HVC
    M(:, t) =  max(W_MH * H(:, t) - P.thresh, 0);
    % NOTE: LMAN has no immediate effect on HVC activity. Need to justify
    % this asymmmetry!

    PAL(:, t) = W_PM * M(:, t);
    D(:, t) = W_DP * PAL(:, t);
    
    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t + 1) = randomness(:, t) + W_LD * D(:, t);
    L(:, t + 1) = max(L(:, t + 1), 0);
    % NOTE: that this LMAN input is used in NEXT time step

    % RA activity is the sum of inputs from HVC and LMAN
    R(:, t) = W_RH * H(:, t) + W_RL * L(:, t);

    % Calculate reward prediction error
    error(t)  = abs(R(:, t) - P.template(:, s(t)));
    reward = 1 - mean(error(t), 1); % averaged across all neurons
    rpe(t) = reward - V(s(t));

    % Update expected state value
    V(s(t)) = V(s(t)) + P.rperate * rpe(t);

    if t > 6000 % no learning for first 6000 time steps so V can converge
        % Update eligibility trace
        % Eligibility trace decays over time according to the discount rate and
        % receives an impulse when both the HVC and LMAN neuron . Eligibility
        % trace is specific to a single HVC->X synapse
        etrace = (((W_ML>0) * L(:, t)) * ones(1, P.hvcunits)) ...
            .*    ((W_MH>0) .* (ones(P.xunits, 1) * H(:, t)')) ...
            + P.discountrate * etrace;

        % Update synaptic weights onto medium spiny neurons based on reward and
        % spiking history of LMAN and HVC neurons.
        dw = etrace .* rpe(t) .* P.xrate;
        temp(t) = dw(1);
        W_MH = W_MH + dw; % direct pathway

        % Update HVC to RA synapses with a spike timing dependent plasticity
        % rule. If they both spike in this time step, the synapse is
        % strengthened.
        W_RH  = W_RH + R(:, t) * H(:, t)' .* P.rarate;
        % NOTE: These synapses have no way to get weaker.

        % Make sure none of the updated synaptic weights change sign.
        W_MH = max(W_MH, winit); % don't let weights on to MSNs go to zero
        W_RH = max(W_RH, 0);
    end
end