% HVC neurons spike in order
% LMAN neurons spike randomly, offset by bias from Area X/DLM
% VTA gives reward when i-th hvc unit and j-th lman unit fire
% simultaneously

%% Parameters
hvcunits = 3; % number of units in hvc
lmanunits = 1; % number of units in lman
xunits = 1; % number of units in Area X
ruh = 1; % rewarded unit in hvc
rul = 1; % rewarded unit in lman
motifs = 100; % number of motifs to run (each hvc neuron fires once per motif)
rate = 0.07; % learning rate parameter
% threshold = 0.6; % threshold for LMAN firing
% b = 1; % strength of bias
threshX = 1;
threshL = 0.8;
rwidth = 2; % reward 

%% Initialization (don't touch this!)
H = repmat(eye(hvcunits), 1, motifs); % HVC spikes
tmax = hvcunits * motifs; 
X = zeros(xunits, tmax); % area x spikes
L = zeros(lmanunits, tmax); % lman spikes
R = zeros(1, tmax); % reward
% W_HX = 0.2 * threshX * rand(xunits, hvcunits, tmax + 1); % weights from HVC onto X
W_HX = 0.2 * threshX * ones(xunits, hvcunits); % weights from HVC onto X
W_LX = 0.9 * threshX;% * (rand(xunits, lmanunits)>0.8); % weights from LMAN onto X, assume static
W_XL = 1 * threshL * ones(lmanunits, xunits); % weights from X onto LMAN, assume static

%% Main loop
for t = rwidth+1:tmax
    X(:, t) =  W_HX * H(:, t) + ...
               W_LX * L(:, t - 1) > threshX; % note using lman activity from previous timestep
    X(:, t) = X(:, t) & ~X(:, t-1); % refreactory period
    L(:, t) = W_XL * X(:, t) + rand(lmanunits, 1) > threshL;
    R(t) = L(rul, t) && H(ruh, t);
    dW = X(:, t) * H(:,t)' .* any(R(t-rwidth:t)) .* rate; % 'and' operation is in X spike generation
    W_HX = W_HX + dW;
end

%% Plot results

ax(1) = subplot(3,1,1);
stem(H(ruh, :))
ax(2) = subplot(3,1,2);
imagesc(X)
ax(3) = subplot(3,1,3);
stem(L(rul, :))
linkaxes(ax,'x');
