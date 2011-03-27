%% Parameters

dt = 0.001; % seconds, time step
thvc = 0.01; % seconds, length of hvc burst
tlman = 0.05; % seconds, timescale of fluctuations in lman
motifs = 20; % number of motifs in simulation

hvcunits = 6; % number of units in hvc
lmanunits = 2; % number of units in lman
xunits = hvcunits * lmanunits;
% Number of units in X is forced to be hvcunits*lmanunits because of the
% wiring pattern in X. Each unit in X receives input from a single HVC unit
% and a single LMAN unit. There is one X unit for each pair of inputs.

rate = 0.05; % learning rate
noiseamp = 0.1; %amplitude of noise

template = [1 0 0 0 0 1; 0 1 0 0 1 0];
assert(size(template, 1) == lmanunits)
assert(size(template, 2) == hvcunits)


%% Initialize

hvcsteps = thvc / dt;
motifsteps = hvcsteps * hvcunits;
maxsteps = motifsteps * motifs;
tmax = motifs * hvcunits;

% Reward when LMAN output matches template. Cannot be negative (hard cut
% off)
E = @(L, step) template(:, floor(mod(step/hvcsteps, hvcunits) + 1)) - L(:, step);
% R = @(L, step) max(0, sum(1 - E(L, step).^2, 1));
R = @(L, step) 1 - E(L, step).^2;

% Spike trains
H = zeros(hvcunits, maxsteps);
t = 1;
for m = 1:motifs
    for u = 1:hvcunits
        for step = 1:(thvc/dt)
            H(u, t) = 1;
            t = t+1;
        end
    end
end
X = zeros(xunits, maxsteps); % X spikes
L = zeros(lmanunits, maxsteps); % LMAN spikes
randomness = zeros(lmanunits, maxsteps); 
for u = 1:lmanunits
    randomness(u, :) = noiseamp*smoothnoise(maxsteps, tlman/dt);
end

% Synaptic weights
W_XH = zeros(xunits, hvcunits); % weights on X from HVC
W_XL = zeros(xunits, lmanunits); % weights on X from LMAN
W_LX = zeros(lmanunits, xunits); % weights on LMAN from X
nX = 1;
for nH = 1:hvcunits
    for nL = 1:lmanunits
%         W_XH(nX, nH) = 0.1;
%         W_XL(nX, nL) = 0.1;
        W_LX(nL, nX) = 1;
        nX = nX + 1;
    end
end


%% Main loop
L(:, 1) = randomness(:, 1);
for t = 1:maxsteps
    % X activity is the sum of inputs from HVC and LMAN.
    X(:, t) =  W_XH * H(:, t) + W_XL * L(:, t);

    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t + 1) = randomness(:, t) + W_LX * X(:, t);
    % Note that this LMAN input is used in NEXT time step
    
    % Learning only occurs at HVC-X synapse. Strength of this synapse is
    % increased when L and H neuron spike simultaneously, and reward has
    % been given recently. FIXME is this backwards?
    eligible = (L(:, t)*ones(1,hvcunits)) .* (ones(lmanunits,1)*H(:,t)');
    dW =  eligible(:) * H(:, t)' .* repmat(R(L, t), hvcunits, hvcunits) .* rate; 
    W_XH = W_XH + dW;
end

%% Plot results

ax(1) = subplot(3,1,1);
imagesc(H)
ax(2) = subplot(3,1,2);
imagesc(X)
ax(3) = subplot(3,1,3);
imagesc(L)
linkaxes(ax,'x');

% quickimage('HVC', H, 'LMAN', L, 'X', X)