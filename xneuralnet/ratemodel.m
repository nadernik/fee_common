function ratemodel(varargin)

%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.01; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.05; % seconds, timescale of fluctuations in lman
P.motifs = 1500; % number of motifs in simulation

% Size of the network
P.hvcunits = 6; % number of units in hvc
P.raunits = 1;
P.lmanunits = P.raunits*2; % number of units in lman
P.xunits = 20; % number of units in x

% Learning rates and other fudge factors
P.xrate = .05; % learning rate in HVC->X synapse
P.rarate = 0; % learning rate in HVC->RA synapse
P.rperate = 0.05; % learning rate of state value function V(s)
P.irate = 0.01; % learning rate in X->X inhibitory collaterals

P.discountrate = 0; % for reward prediction error. 0 means no history.
P.tau_a = 0.8;

P.inhibition = 200; % MSN global inhibition strength
P.noiseamp = 1; % amplitude of background LMAN activity
P.setpoint = 0.1; % target average activity. X neurons will adjust E/I balance until this is acheived
P.thresh = 0.1; % spiking threshold for X neurons

% The template, aka the sequence we are trying to learn.
P.template = [1 1 0 0 0 0];

% P = parseargs(P, varargin{:});

%% Initialize

assert(size(P.template, 1) == P.raunits)
assert(size(P.template, 2) == P.hvcunits)
assert(P.lmanunits == 2*P.raunits)

hvcsteps = P.thvc / P.dt; % number of time steps in each hvc burst
motifsteps = hvcsteps * P.hvcunits; % number of time steps per motif
maxsteps = motifsteps * P.motifs; % total number of time steps to simulate

% "State" is the HVC unit that is currently firing.
s = @(t) max(1, ceil((mod(t-1, motifsteps)) / hvcsteps));

% Make HVC neurons fire in a "chain" with each neuron spiking twice per motif
H = zeros(P.hvcunits, maxsteps);
t = 1;
% Each neuron spikes twice per motif and at each point in motif there are
% two neurons spiking. However, each time step has a unique pair.
hh = [1 2 3 4 5 6
      4 6 1 5 2 3];
for m = 1:P.motifs
    for u = 1:P.hvcunits
        for step = 1:hvcsteps
            H(hh(:, u), t) = 1;
            t = t+1;
        end
    end
end

% Make LMAN neurons fire randomly
L = zeros(P.lmanunits, maxsteps + 1);
randomness = zeros(P.lmanunits, maxsteps);
for u = 1:P.lmanunits
    randomness(u, :) = P.noiseamp * smoothnoise(maxsteps, P.tlman / P.dt);
end
randomness = max(randomness, 0);
L(:, 1) = randomness(:, 1);

% LMAN to RA synapse: Each RA neuron receives input from two LMAN neurons.
% One increases activity of the RA neuron and the other decreases it. See
% Fig 2B in Kao et al. 2005.
W_RAL = zeros(P.raunits, P.lmanunits);
nL = 1;
for nRA = 1:P.raunits
    W_RAL(nRA, nL)     = 1;
    W_RAL(nRA, nL + 1) = -1;
    nL = nL + 2;
end

% LMAN-X-LMAN loop: Each X neuron receives input from one LMAN neuron and
% projects back to that same LMAN neuron. Approximates topographic loop.
W_X1L = zeros(P.xunits, P.lmanunits);
W_X2L = zeros(P.xunits, P.lmanunits);
for nX = 1:P.xunits
    nL = mod(nX, P.lmanunits) + 1;
    W_X1L(nX, nL) = 1;
    W_X2L(nX, nL) = 1;
end
W_LX1 =  W_X1L';
W_LX2 = -W_X2L';

% Weak all-to-all connectivity with random weights in HVC -> X
W_X1H = 0.01 * rand(P.xunits, P.hvcunits);
W_X2H = 0.01 * rand(P.xunits, P.hvcunits);

% X collaterals between X1 and X2 neurons that receive similar LMAN input
[junk, nL1] = find(W_X1L ~= 0);
[junk, nL2] = find(W_X2L ~= 0);
W_X1X1 = -P.inhibition / P.xunits * P.lmanunits * ((ones(P.xunits, 1) * nL1') == (ones(P.xunits, 1) * nL1')');
W_X2X2 = -P.inhibition / P.xunits * P.lmanunits * (ones(P.xunits, 1) * nL2') == (ones(P.xunits, 1) * nL2')';
W_X2X1 = -P.inhibition / P.xunits * P.lmanunits * (ones(P.xunits, 1) * nL2') == (ones(P.xunits, 1) * nL1')';
W_X1X2 = W_X2X1';

% HVC starts out completely disconnected from RA
W_RAH = zeros(P.raunits, P.hvcunits);

% Initialize empty matrices for activity in other neurons
X1 = zeros(P.xunits,  maxsteps);
X2 = zeros(P.xunits,  maxsteps);
RA = zeros(P.raunits, maxsteps);
etrace1 = zeros(P.xunits, P.hvcunits);
etrace2 = zeros(P.xunits, P.hvcunits);
atrace1 = P.setpoint * ones(P.xunits, 1);
atrace2 = P.setpoint * ones(P.xunits, 1);
V = zeros(maxsteps + 1, P.hvcunits);
rpe = zeros(1,maxsteps);
reward= zeros(1,maxsteps);
temp = zeros(1, maxsteps);

%%%DEBUG -- turn off X to LMAN connection
W_LX1 = zeros(size(W_LX1));
W_LX2 = zeros(size(W_LX2));
%%%/DEBUG

%% Main loop
for t = 1:maxsteps

    % X activity is determined by input from HVC
    xin1 = W_X1H * H(:, t);
    xin2 = W_X2H * H(:, t);
    X1(:, t) =  max(xin1 - P.thresh, 0);
    X2(:, t) =  max(xin2 - P.thresh, 0);
    % NOTE: LMAN has no immediate effect on HVC activity. Need to justify
    % this asymmmetry!

    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t + 1) = randomness(:, t) + W_LX1 * X1(:, t) + W_LX2 * X2(:, t);
    L(:, t + 1) = max(L(:, t + 1), 0);
    % NOTE: that this LMAN input is used in NEXT time step

    % RA activity is the sum of inputs from HVC and LMAN
    RA(:, t) = W_RAH * H(:, t) + W_RAL * L(:, t);

    % Calculate reward prediction error
    error  = RA(:, t) - P.template(:, s(t));
    reward(t) = 1 - mean(error.^2, 1); % averaged across all neurons
    rpe(t) = reward(t) - V(s(t));

    % Update expected state value
    V(s(t)) = V(s(t)) + P.rperate * rpe(t);

    if t > 6000 % no learning for first 6000 time steps so V can converge
        % Update eligibility trace
        % Eligibility trace decays over time according to the discount rate and
        % receives an impulse when both the HVC and LMAN neuron . Eligibility
        % trace is specific to a single HVC->X synapse
        etrace1 = (((W_X1L * L(:, t)) * ones(1, P.hvcunits)) > 0) ...
            .*    (W_X1H .* (ones(P.xunits, 1) * H(:, t)')) ...
            + P.discountrate * etrace1;
        etrace2 = (((W_X2L * L(:, t)) * ones(1, P.hvcunits)) > 0) ...
            .*    (W_X2H .* (ones(P.xunits, 1) * H(:, t)')) ...
            + P.discountrate * etrace2;

        % Activity trace is a exponentially weighted running average of
        % activity in X neurons. Used for E/I balance.
        atrace1 = xin1 + P.tau_a * atrace1;
        atrace2 = xin2 + P.tau_a * atrace2;


        % Global inhibition supresses learning in MSNs.
        I1 = max(0, 1 + W_X1X1 * X1(:, t) + W_X1X2 * X2(:, t)) * ones(1, P.hvcunits);
        I2 = max(0, 1 + W_X2X2 * X2(:, t) + W_X2X1 * X1(:, t)) * ones(1, P.hvcunits);
        % NOTE: Inhibition only effects learning, not the actual output of MSNs

        % Update synaptic weights onto medium spiny neurons based on reward and
        % spiking history of LMAN and HVC neurons.
        W_X1H = W_X1H + etrace1 .* rpe(t) .* I1 .* P.xrate; % direct pathway
        W_X2H = W_X2H - etrace2 .* rpe(t) .* I2 .* P.xrate; % indirect pathway

        % Update inhibitory weights to maintain E/I balance.
        temp(t) = atrace1(2);
        W_X1X1 = min(0, (P.setpoint - atrace1) * ones(1, P.xunits) * P.irate + W_X1X1);
        W_X1X2 = min(0, (P.setpoint - atrace1) * ones(1, P.xunits) * P.irate + W_X1X2);
        W_X2X1 = min(0, (P.setpoint - atrace2) * ones(1, P.xunits) * P.irate + W_X2X1);
        W_X2X2 = min(0, (P.setpoint - atrace2) * ones(1, P.xunits) * P.irate + W_X2X2);

        % Update HVC to RA synapses with a spike timing dependent plasticity
        % rule. If they both spike in this time step, the synapse is
        % strengthened.
        dW = RA(:, t) * H(:, t)' .* P.rarate;
        W_RAH  = W_RAH + dW;
        % NOTE: These synapses have no way to get weaker.

        % Make sure none of the updated synaptic weights change sign.
        W_X1H = max(W_X1H, 0.0001); % don't let weights on to MSNs go to zero
        W_X2H = max(W_X2H, 0.0001);
        W_RAH = max(W_RAH, 0);
    end
end

%% Plot results
figure
quickimage('HVC', H, 'X1', X1, 'X2', X2, 'LMAN', L, 'RA', RA)
title('Network activity')

figure
quickimage( 'X1', X1(:, end-motifsteps:end), 'X2', X2(:, end-motifsteps:end))
%'HVC', H(:, end-motifsteps:end),
title('Last motif of activity')

figure
plot(temp)
xlabel('t')
ylabel('activity trace')

% Take last motif only
% Put each X neuron into a category based on strongest synaptic weight
% Histogram of number of neurons in each category
% figure
% for nX = 1:P.xunits
%     nL = find(W_X1L(nX, :));
%     %fprintf(1, '%g of %g synapses onto LMAN unit %g\n', nX, P.xunits, nL)
%
%     temp = mean(reshape(X1(nX, :), hvcsteps, []));% average over all time steps in each HVC burst
%     Y = reshape(temp, P.hvcunits,  P.motifs)';
%     area(Y)
%     pause
%     if nL == 1
%         [hi, nh] = max(Y(end, :));
%         if hi/sum(Y(end, :)) > 0.8; % assign to category if more than 80% activity in this bin
%             category(nX) = nh;
%         else
%             category(nX) = 0; % unassigned
%         end
%     else
%         category(nX) = nan; % exclude because wrong lman neuron
%     end
% end
%
% figure
% hist(category, 0:P.hvcunits)
% title('X neurons per hvc burst (0=unassigned)')
% xlabel('HVC burst')
% ylabel('Number of X neurons')

keyboard
end