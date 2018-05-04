% HVC neurons spike in order
%
% LMAN neurons spike randomly on their own, and also receive input from X.
%
% X represents the entire basal ganglia loop from medium spiny neurons in
% Area X through neurons in DLM.
%
% Synaptic weights are initialized so that each X neuron recieves input
% from a single HVC neuron and a single LMAN neuron. Weights are scaled so
% that LMAN and HVC input is required to make the X neuron fire.
%
% Synaptic weights of HVC->X are modified by learning. Synaptic weights of 
% LMAN->X and X->LMAN are static.
%
% Time is divided into steps that are the width of one HVC burst.

%% Parameters

hvcunits = 5; % number of units in hvc
lmanunits = 2; % number of units in lman
% Number of X neurons will be the number of possible HVC-LMAN pairs.
ruh = 1; % rewarded unit in hvc
rul = 1; % rewarded unit in lman
motifs = 20; % number of motifs to run (each hvc neuron fires once per motif)
rate = 0.05; % learning rate parameter
rwidth = 2; % reward window
randomness = 1.5;

%% Initialization (don't touch this!)

tmax = hvcunits * motifs; % total timesteps to run
xunits = hvcunits * lmanunits; % number of units in X

% Spike trains
H = repmat(eye(hvcunits), 1, motifs); % HVC spikes
X = zeros(xunits, tmax); % X spikes
L = zeros(lmanunits, tmax); % LMAN spikes
R = zeros(1, tmax); % reward

% Synaptic weights
W_XH = zeros(xunits, hvcunits); % weights on X from HVC
W_XL = zeros(xunits, lmanunits); % weights on X from LMAN
W_LX = zeros(lmanunits, xunits); % weights on LMAN from X
nX = 1;
for nH = 1:hvcunits
    for nL = 1:lmanunits

        W_XH(nX, nH) = 0.6;
        W_XL(nX, nL) = 0.6;
        W_LX(nL, nX) = 2;
        nX = nX + 1;
    end
end

%% Main loop
% Thresholds for action potentials is 1
for t = rwidth+1:tmax
    % X activity is the sum of inputs from HVC and LMAN.
    X(:, t) =  W_XH * H(:, t) + W_XL * L(:, t) > 1;
    % See how LMAN spike from previous timestep is used to calculate the
    % activity in X now.

    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t + 1) = randomness*rand(lmanunits, 1) + W_LX * X(:, t) > 1;
    
    % Reward when the targeted LMAN-HVC pair spike together
    R(t) = L(rul, t) && H(ruh, t);
    
    % Learning only occurs at HVC-X synapse. Strength of this synapse is
    % increased when X and H neuron spike simultaneously, and reward has
    % been given recently. FIXME is this backwards?
    dW = X(:, t) * H(:,t)' .* any(R(t-rwidth:t)) .* rate; 
    W_XH = W_XH + dW;
end

%% Plot results

ax(1) = subplot(3,1,1);
stem(H(ruh, :))
ax(2) = subplot(3,1,2);
imagesc(X)
ax(3) = subplot(3,1,3);
stem(L(rul, :))
linkaxes(ax,'x');
