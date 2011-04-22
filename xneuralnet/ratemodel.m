function ratemodel(varargin)


%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.01; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.05; % seconds, timescale of fluctuations in lman
P.motifs = 1000; % number of motifs in simulation

% Size of the network
P.hvcunits = 6; % number of units in hvc
P.raunits = 1;
P.lmanunits = P.raunits*2; % number of units in lman
P.xunits = P.hvcunits * P.lmanunits; % number of units in x
% Number of units in X is forced to be hvcunits*lmanunits because of the
% wiring pattern in X. Each unit in X receives input from a single HVC unit
% and a single LMAN unit. There is one X unit for each pair of inputs.

% Learning rates and other fudge factors
P.xrate = .05; % learning rate
P.rarate = 0;%.002;
P.rperate = 0.05;
P.discountrate = 0;
P.inhib = 0.5; % inhibition strength
P.noiseamp = 1; %amplitude of noise

% Heterosynaptic competition
P.syndec = 0.005; 
P.Wmax = 0.2; % 

% The template, aka the sequence we are trying to learn. 
P.template = ones(P.raunits,1) * [0.5, -0.5, 0.5, -0.5, 0.5, -0.5]; 
% P. template = [0 0 0 -0.5 0 0];

P = parseargs(P, varargin{:});

%% Initialize

assert(size(P.template, 1) == P.raunits)
assert(size(P.template, 2) == P.hvcunits)
assert(P.lmanunits == 2*P.raunits)
assert(P.xunits == P.hvcunits * P.lmanunits)

hvcsteps = P.thvc / P.dt; % number of time steps in each hvc burst
motifsteps = hvcsteps * P.hvcunits; % number of time steps per motif
maxsteps = motifsteps * P.motifs; % total number of time steps to simulate

% "State" is the HVC unit that is currently firing.
s = @(t) ceil((mod(t, motifsteps)+1) / hvcsteps);

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
W_LX1 = zeros(P.lmanunits, P.xunits); % weights on LMAN from X
W_LX2 = zeros(P.lmanunits, P.xunits); % weights on LMAN from X
W_X1L = zeros(P.xunits, P.lmanunits); % weights on X from LMAN
W_X2L = zeros(P.xunits, P.lmanunits); % weights on X from LMAN

%%%DEBUG
%W_X1H = zeros(P.xunits, P.hvcunits);
%W_X2H = zeros(P.xunits, P.hvcunits);

nX = 1;
for nH = 1:P.hvcunits
    for nL = 1:P.lmanunits
        W_LX1(nL, nX) = 0; %DEBUG 1;
        W_LX2(nL, nX) = 0; %DEBUG -1;
        W_X1L(nX, nL) = 0.00001;
        W_X2L(nX, nL) = 0.00001;
        
        %%%debug
        %W_X1H(nX, nH) = 0.01;
        %W_X2H(nX, nH) = 0.01;
        %%%/debug
        
        nX = nX + 1;
    end
end

% Weak all-to-all connectivity with random weights in HVC -> X
W_X1H = 0.01 * rand(P.xunits, P.hvcunits);
W_X2H = 0.01 * rand(P.xunits, P.hvcunits);


% HVC starts out completely disconnected from RA
W_RAH = zeros(P.raunits, P.hvcunits);

rpe = zeros(1,maxsteps);
reward= zeros(1,maxsteps);

%% Main loop
for t = 1:maxsteps
    % X activity is the sum of inputs from HVC and LMAN.
    %X1(:, t) =  max(W_X1H * H(:, t) + W_X1L * L(:, t), 0);
    %X2(:, t) =  max(W_X2H * H(:, t) + W_X2L * L(:, t), 0);
    
    % X activity is determined by input from HVC
    X1(:, t) =  max(W_X1H * H(:, t), 0);
    X2(:, t) =  max(W_X2H * H(:, t), 0);

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
        etrace1 = ((W_X1L * L(:, t)) * ones(1, P.hvcunits)) > 0 ...
            .*    ((W_X1H .* repmat(H(:, t)', P.xunits, 1))) > 0 ...
            + P.discountrate * etrace1;
        %     if any(L(:,t) ~= 0)
        %         keyboard
        %     end
        etrace2 = ((W_X2L * L(:, t)) * ones(1, P.hvcunits)) > 0 ...
            .*    ((W_X2H .* repmat(H(:, t)', P.xunits, 1))) > 0 ...
            + P.discountrate * etrace2;
    end
    
    % Update synaptic weights onto medium spiny neurons based on reward and
    % spiking history of LMAN and HVC neurons.
    W_X1H = W_X1H + etrace1 * rpe(t) * P.xrate; % direct pathway
    W_X2H = W_X2H - etrace2 * rpe(t) * P.xrate; % indirect pathway
    
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
    % FIXME: These synapses have no way to get weaker.
    
    % Make sure none of the updated synaptic weights change sign.
    W_X1H = max(W_X1H, 0.0001); % don't let weights on to MSNs go to zero
    W_X2H = max(W_X2H, 0.0001);
    W_RAH = max(W_RAH, 0);
end

%% Plot results
figure
quickimage('HVC', H, 'X1', X1, 'X2', X2, 'LMAN', L, 'RA', RA)
title('Network activity')

figure
plottrials(RA(1,:), -20:-1, motifsteps)
title('Last 20 trials of RA unit #1 activity')

figure
plot(reward)
title('Reward')

keyboard
end