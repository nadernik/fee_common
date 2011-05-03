function ratemodel(varargin)

%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.01; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.05; % seconds, timescale of fluctuations in lman
P.motifs = 500;%5000; % number of motifs in simulation

% Size of the network
P.hvcunits = 6; % number of units in hvc
P.raunits = 1;
P.lmanunits = P.raunits*2; % number of units in lman
P.xunits = 100;%P.hvcunits * P.lmanunits; % number of units in x
% Number of units in X is forced to be hvcunits*lmanunits because of the
% wiring pattern in X. Each unit in X receives input from a single HVC unit
% and a single LMAN unit. There is one X unit for each pair of inputs.

% Learning rates and other fudge factors
P.xrate = .05; % learning rate in HVC->X synapse
P.rarate = 0; % learning rate in HVC->RA synapse
P.rperate = 0.05; % learning rate of state value function V(s)
P.discountrate = 0; % for reward prediction error. 0 means no history.
P.inhibition = 200; % MSN global inhibition strength
P.noiseamp = 1; % amplitude of background LMAN activity
P.syndec = 0.001; % Strength of heterosynaptic competition. 0 turns off competition
P.Wmax = 0.06; % Threshold for heterosynaptic competition
P.thresh = 0.01; % spiking threshold for X neurons

% Initial conditions

% The template, aka the sequence we are trying to learn. 
% P.template = ones(P.raunits,1) * [0.5, -0.5, 0.5, -0.5, 0.5, -0.5]; 
P.template = [1 1 1 1 1 1];
% P.template = [0 0 0 0 0 1];

% P = parseargs(P, varargin{:});

%% Initialize

assert(size(P.template, 1) == P.raunits)
assert(size(P.template, 2) == P.hvcunits)
assert(P.lmanunits == 2*P.raunits)
% assert(P.xunits == P.hvcunits * P.lmanunits)

hvcsteps = P.thvc / P.dt; % number of time steps in each hvc burst
motifsteps = hvcsteps * P.hvcunits; % number of time steps per motif
maxsteps = motifsteps * P.motifs; % total number of time steps to simulate

% "State" is the HVC unit that is currently firing.
s = @(t) max(1, ceil((mod(t-1, motifsteps)) / hvcsteps));

% Make HVC neurons fire in a chain
H = zeros(P.hvcunits, maxsteps);
t = 1;
for m = 1:P.motifs
    for u = 1:P.hvcunits
        for step = 1:hvcsteps
            H(u, t) = 1;
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

% Initialize empty matrices for activity in other neurons
X1 = zeros(P.xunits,  maxsteps);
X2 = zeros(P.xunits,  maxsteps);
RA = zeros(P.raunits, maxsteps);
etrace1 = zeros(P.xunits, P.hvcunits);
etrace2 = zeros(P.xunits, P.hvcunits);
V = zeros(maxsteps + 1, P.hvcunits);


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
%%%DEBUG -- turn off X to LMAN connection
W_LX1 = zeros(size(W_LX1));
W_LX2 = zeros(size(W_LX2));
%%%/DEBUG

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

rpe = zeros(1,maxsteps);
popactivity = zeros(1,maxsteps);
reward= zeros(1,maxsteps);

%% Main loop
for t = 1:maxsteps
    % X activity is the sum of inputs from HVC and LMAN.
    %X1(:, t) =  max(W_X1H * H(:, t) + W_X1L * L(:, t), 0);
    %X2(:, t) =  max(W_X2H * H(:, t) + W_X2L * L(:, t), 0);
    
    % X activity is determined by input from HVC
    X1(:, t) =  max(W_X1H * H(:, t) - P.thresh, 0);
    X2(:, t) =  max(W_X2H * H(:, t) - P.thresh, 0);

    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t + 1) = randomness(:, t) + W_LX1 * X1(:, t) + W_LX2 * X2(:, t);
    L(:, t + 1) = max(L(:, t + 1), 0);
    % Note that this LMAN input is used in NEXT time step
    
    % RA activity is the sum of inputs from HVC and LMAN
    RA(:, t) = W_RAH * H(:, t) + W_RAL * L(:, t);
    
    % Calculate reward prediction error
    error  = RA(:, t) - P.template(:, s(t)); 
    reward(t) = 1 - mean(error.^2, 1); % averaged across all neurons
    rpe(t) = reward(t) - V(s(t));
    
    % Update expected state value
    V(s(t)) = V(s(t)) + P.rperate * rpe(t);
    if t > 6000
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
    end
    
    % Global inhibition supresses learning in MSNs. 
    I1 = max(0, 1 + W_X1X1 * X1(:, t) + W_X1X2 * X2(:, t)) * ones(1, P.hvcunits);
    I2 = max(0, 1 + W_X2X2 * X2(:, t) + W_X2X1 * X1(:, t)) * ones(1, P.hvcunits);
    % NOTE: Inhibition only effects learning, not the actual output of MSNs
    
    % Update synaptic weights onto medium spiny neurons based on reward and
    % spiking history of LMAN and HVC neurons.
    W_X1H = W_X1H + etrace1 .* rpe(t) .* I1 .* P.xrate; % direct pathway
    W_X2H = W_X2H - etrace2 .* rpe(t) .* I2 .* P.xrate; % indirect pathway
    
    % Heterosynaptic competition: If all weights onto a given X neuron
    % exceed a limit (Wmax), then all weights onto that neuron are
    % decreased in strength by a constant (syndec)
    W_X1H = W_X1H - P.syndec * (sum(W_X1H, 2) > P.Wmax) * ones(1, P.hvcunits);
    W_X2H = W_X2H - P.syndec * (sum(W_X2H, 2) > P.Wmax) * ones(1, P.hvcunits);

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
    
    %%%DEBUG change template to see medium spiny neurons relearn
    if t / motifsteps == 501 % after 500th motif
        P.template = [1 0 0 0 0 0];
        disp('template changed!')
    end
        
end

%% Plot results
% figure
% quickimage('HVC', H, 'X1', X1, 'X2', X2, 'LMAN', L, 'RA', RA)
% title('Network activity')

% Take last motif only

% Put each X neuron into a category based on strongest synaptic weight
% Proportion of neurons in each category


figure
% quickimage('HVC', H(:, end-motifsteps:end), 'X1', X1(:, end-motifsteps:end), 'X2', X2(:, end-motifsteps:end))
% title('Last motif of activity')
for nX = 1:P.xunits
    nL = find(W_X1L(nX, :));
    %fprintf(1, '%g of %g synapses onto LMAN unit %g\n', nX, P.xunits, nL)
    
    temp = mean(reshape(X1(nX, :), hvcsteps, []));% average over all time steps in each HVC burst
    Y = reshape(temp, P.hvcunits,  P.motifs)';
%     area(Y)
%     pause
    if nL == 1
        [hi, nh] = max(Y(end, :));
        if hi/sum(Y(end, :)) > 0.8; % assign to category if more than 80% activity in this bin
            category(nX) = nh;
        else
            category(nX) = 0; % unassigned
        end
    else
        category(nX) = nan; % exclude because wrong lman neuron
    end
end

figure
hist(category, 0:P.hvcunits)
title('X neurons per hvc burst (0=unassigned)')
xlabel('HVC burst')
ylabel('Number of X neurons')

% figure
% plot(popactivity)
% title('Michale''s I')

keyboard
end