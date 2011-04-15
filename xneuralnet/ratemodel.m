function ratemodel(varargin)


%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.01; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.05; % seconds, timescale of fluctuations in lman
P.motifs = 400; % number of motifs in simulation

% Size of the network
P.hvcunits = 6; % number of units in hvc
P.raunits = 1;
P.lmanunits = P.raunits*2; % number of units in lman
P.xunits = P.hvcunits * P.lmanunits; % number of units in x
% Number of units in X is forced to be hvcunits*lmanunits because of the
% wiring pattern in X. Each unit in X receives input from a single HVC unit
% and a single LMAN unit. There is one X unit for each pair of inputs.

% Learning rates and other fudge factors
P.xrate = .01; % learning rate
P.rarate = 0;%.002;
P.rperate = 0.01;
P.discountrate = 0.1;
P.noiseamp = 1; %amplitude of noise

% Heterosynaptic competition
P.syndec = 0.05; 
P.Wmax = 1; % 

% The template, aka the sequence we are trying to learn. 
P.template = ones(P.raunits,1) * [0 0 0 -0.5 0 0]; 

P = parseargs(P, varargin{:});

%% Initialize

assert(size(P.template, 1) == P.raunits)
assert(size(P.template, 2) == P.hvcunits)
assert(P.lmanunits == 2*P.raunits)
assert(P.xunits == P.hvcunits * P.lmanunits)

hvcsteps = P.thvc / P.dt; % number of time steps in each hvc burst
motifsteps = hvcsteps * P.hvcunits; % number of time steps per motif
maxsteps = motifsteps * P.motifs; % number of time steps in whole simulation

% "State" is the HVC unit that is currently firing.
s = @(t) ceil((mod(t, motifsteps)+1) / hvcsteps);

% Spike trains
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
X1 = zeros(P.xunits, maxsteps); % X spikes
X2 = zeros(P.xunits, maxsteps);
L = zeros(P.lmanunits, maxsteps + 1); % LMAN spikes
RA = zeros(P.raunits, maxsteps);
randomness = zeros(P.lmanunits, maxsteps); 
for u = 1:P.lmanunits
    randomness(u, :) = P.noiseamp * smoothnoise(maxsteps, P.tlman / P.dt);
end
randomness = max(randomness, 0);
L(:, 1) = randomness(:, 1);

% Synaptic weights
W_X1H = zeros(P.xunits, P.hvcunits); % weights on X from HVC
W_X1L = zeros(P.xunits, P.lmanunits); % weights on X from LMAN

W_RAH = zeros(P.raunits, P.hvcunits); % weights on RA from HVC
W_RAL = zeros(P.raunits, P.lmanunits); % weights on RA from LMAN (1-to-1 connection)
% Each RA neuron receives input from two LMAN neurons. One increases
% activity of the RA neuron and the other decreases it. See Fig 2B in Kao
% et al. 2005.
nL = 1;
for nRA = 1:P.raunits
    W_RAL(nRA, nL)     = 1;
    W_RAL(nRA, nL + 1) = -1;
    nL = nL + 2;
end

W_X2H = zeros(P.xunits, P.hvcunits); % weights on X from HVC
W_X2L = zeros(P.xunits, P.lmanunits); % weights on X from LMAN

W_LX1 = zeros(P.lmanunits, P.xunits); % weights on LMAN from X
W_LX2 = zeros(P.lmanunits, P.xunits); % weights on LMAN from X
nX = 1;
xcmask = zeros(P.xunits, P.hvcunits); % mask to enforce connectivity
for nH = 1:P.hvcunits
    for nL = 1:P.lmanunits
        W_LX1(nL, nX) = 1;
        W_LX2(nL, nX) = -1;
        xcmask(nX, nH) = 1;
        nX = nX + 1;
    end
end

eligibilitytrace = zeros(size(W_X1H));
V = zeros(maxsteps + 1, P.hvcunits);
%% Main loop
for t = 1:maxsteps
    % X activity is the sum of inputs from HVC and LMAN.
    X1(:, t) =  max(W_X1H * H(:, t) + W_X1L * L(:, t), 0);
    X2(:, t) =  max(W_X2H * H(:, t) + W_X2L * L(:, t), 0);

    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t + 1) = randomness(:, t) + W_LX1 * X1(:, t) + W_LX2 * X2(:, t);
    % Note that this LMAN input is used in NEXT time step
    
    % RA activity is the sum of inputs from HVC and LMAN
    RA(:, t) = W_RAH * H(:, t) + W_RAL * L(:, t);
    
    % Calculate reward prediction error
    delta  = rpe(t, RA, V);
    V = updatev(V, t, delta);
    
    % Update eligibility trace
    eligibilitytrace = updatetr(eligibilitytrace, L(:, t), H(:, t));
    
    % Update synaptic weights onto medium spiny neurons based on reward and
    % spiking history of LMAN and HVC neurons.
    dW = eligibilitytrace .* delta .* P.xrate; 
    W_X1H = W_X1H + dW; % direct pathway
    W_X2H = W_X2H - dW; % indirect pathway
    
    % Heterosynaptic competition: If all weights onto a given X neuron
    % exceed a limit (Wmax), then all weights onto that neuron are
    % decreased in strength by a constant (syndec)
    W_X1H = W_X1H - P.syndec * (sum(W_X1H, 2) > P.Wmax) * ones(1, P.hvcunits);
    W_X2H = W_X2H - P.syndec * (sum(W_X2H, 2) > P.Wmax) * ones(1, P.hvcunits);

    % HVC to RA synapses use a spike timing dependent plasticity rule. If
    % they both spike in this time step, the synapse is strengthened.
    dW = RA(:, t) * H(:, t)' .* P.rarate;
    W_RAH  = W_RAH + dW;
    
end

%% Plot results
figure
quickimage('HVC', H, 'X1', X1, 'X2', X2, 'LMAN', L, 'RA', RA)
figure
% plottrials(X1(3, :), -99:-1, motifsteps)
plottrials(RA(1,:), -20:-1, motifsteps)
figure
% plot(L(1, (2*hvcsteps):motifsteps:end))
plot(V(:,2))

keyboard

%% Update rules
    function delta = rpe(t, action, value)
        % reward prediction error
        error = action(:, t) - P.template(:, s(t));
        reward =  1 - mean(error.^2, 1);
        delta = reward - value(t, s(t));
    end
         
    function tr = updatetr(tr, ell, h)
        tr =  repmat(ell, P.hvcunits, 1) * h' .* xcmask + P.discountrate * tr;
        %%%FIXME
    end

    function V = updatev(V, t, delta)
        V(t + 1, s(t)) = V(t, s(t)) + P.rperate * delta;
        others = (1:size(V, 2)) ~= s(t);
        V(t + 1, others) = V(t, others);
    end
end