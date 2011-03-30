%% Parameters

dt = 0.001; % seconds, time step
thvc = 0.01; % seconds, length of hvc burst
tlman = 0.05; % seconds, timescale of fluctuations in lman
motifs = 500; % number of motifs in simulation
navg = 10; % number of trials to average for Lbar

hvcunits = 6; % number of units in hvc
lmanunits = 1; % number of units in lman
xunits = hvcunits * lmanunits; % number of units in x
% Number of units in X is forced to be hvcunits*lmanunits because of the
% wiring pattern in X. Each unit in X receives input from a single HVC unit
% and a single LMAN unit. There is one X unit for each pair of inputs.

rate = .01; % learning rate
noiseamp = 1; %amplitude of noise

template = ones(lmanunits,1) * [2 0 0 0 0 0]; 
assert(size(template, 1) == lmanunits)
assert(size(template, 2) == hvcunits)


%% Initialize

hvcsteps = thvc / dt;
motifsteps = hvcsteps * hvcunits;
maxsteps = motifsteps * motifs;
tmax = motifs * hvcunits;

% Reward when LMAN output matches template. Cannot be negative (hard cut
% off)
step2slice = @(step) floor(mod((step-1)/hvcsteps, hvcunits) + 1);
E = @(L, step) template(:, step2slice(step)) - L(:, step);
% R = @(L, step) max(0, 1 - E(L, step).^2, 1);
R = @(L, step) max(0, 1 - mean(abs(E(L, step)), 1));
Lbar = @(L, step) mean(L(:, max(step-motifsteps*(1:navg),1)), 2);
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
X1 = zeros(xunits, maxsteps); % X spikes
X2 = zeros(xunits, maxsteps);
L = zeros(lmanunits, maxsteps); % LMAN spikes
randomness = zeros(lmanunits, maxsteps); 
for u = 1:lmanunits
    randomness(u, :) = noiseamp*smoothnoise(maxsteps, tlman/dt);
end

% Synaptic weights
W_X1H = zeros(xunits, hvcunits); % weights on X from HVC
W_X1L = zeros(xunits, lmanunits); % weights on X from LMAN
W_LX1 = zeros(lmanunits, xunits); % weights on LMAN from X

W_X2H = zeros(xunits, hvcunits); % weights on X from HVC
W_X2L = zeros(xunits, lmanunits); % weights on X from LMAN
W_LX2 = zeros(lmanunits, xunits); % weights on LMAN from X

nX = 1;
for nH = 1:hvcunits
    for nL = 1:lmanunits
%         W_XH(nX, nH) = 0.1;
%         W_XL(nX, nL) = 0.1;
        W_LX1(nL, nX) = 1;
        W_LX2(nL, nX) = -1;
        nX = nX + 1;
    end
end


%% Main loop
L(:, 1) = randomness(:, 1);
for t = 1:maxsteps
    % X activity is the sum of inputs from HVC and LMAN.
    X1(:, t) =  max(W_X1H * H(:, t) + W_X1L * L(:, t), 0);
    X2(:, t) =  max(W_X2H * H(:, t) + W_X2L * L(:, t), 0);

    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t + 1) = randomness(:, t) + W_LX1 * X1(:, t) + W_LX2 * X2(:, t);
    % Note that this LMAN input is used in NEXT time step
    
    % Learning only occurs at HVC-X synapse. Strength of this synapse is
    % increased when L and H neuron spike simultaneously, and reward has
    % been given recently. FIXME is this backwards?
    eligible = ((L(:, t)-Lbar(L, t))*ones(1,hvcunits)) .* (ones(lmanunits,1)*H(:,t)');
    dW1 = eligible(:) * H(:, t)' .* R(L, t) .* rate;
    dW2 = eligible(:) * H(:, t)' .* (1 - R(L, t)) .* rate;
    W_X1H = W_X1H + dW1;
    W_X2H = W_X2H + dW2;
end

%% Plot results
figure
ax(1) = subplot(3,1,1);
imagesc(H)
ax(2) = subplot(3,1,2);
imagesc([X1; X2])
ax(3) = subplot(3,1,3);
% imagesc(L)
plot(L')
hold all
% plot(R(L,1:maxsteps), 'r')
linkaxes(ax,'x');

figure
plottrials(L(1,:), -20:-1, motifsteps)

% quickimage('HVC', H, 'LMAN', L, 'X', X)