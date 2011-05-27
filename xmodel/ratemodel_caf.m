% 100 motifs without learning -- get baseline singing and let V(s) converge
% 500 motifs to learn -- hopefully for the last 100 motifs of this, we are
% at a stable learned state

% Start with song learned -- HVC->RA synapses non zero
% No consolidation -- HVC->RA synapse learning rate is zero

close all
clear all
%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.005; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.08; % seconds, timescale of fluctuations in lman
P.motifs = 1000; % number of motifs in simulation

% Size of the network
P.hvcunits = 50; % number of units in hvc
P.raunits = 1;
P.lmanunits = 1; % number of units in lman
P.xunits = P.lmanunits * P.hvcunits; % number of units in x

% Learning rates and other fudge factors
P.xrate = .004; % learning rate in HVC->X synapse
P.rarate = 0; % learning rate in HVC->RA synapse
P.rperate = .1; % learning rate of state value function V(s)
P.discountrate = 0.98; % for reward prediction error. 0 means no history.

P.noiseamp = 0.25;
P.thresh = 0;
P.radecay = 2e-3 * P.rarate;

P.rewarddelay = 50; % 50 ms 

% conditional auditory feedback
P.caftime = 25;
P.cafthresh = 1;
P.caferror = 3;

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
s = @(t) ceil(modnonzero(t, motifsteps)/hvcsteps);

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
W_RH = P.template;

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
L(:, 1) = max(randomness(:, 1), 0);

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
% W_PM(:,:) = 0; %%%DEBUG

% Initialize empty matrices for activity in other neurons
etrace = zeros(P.xunits, P.hvcunits);
V = zeros(1, P.hvcunits);
Vall = zeros(P.motifs, P.hvcunits);
dwall = zeros(maxsteps, P.xunits);
wall = zeros(maxsteps, P.xunits);
error = zeros(1,maxsteps +P.rewarddelay);
rpe = zeros(maxsteps, 1);
eall = zeros(maxsteps, P.xunits);
%% Main loop
for t = 1:maxsteps

    % Reset elgigibility trace at the beginning of each motif
%     if mod(t, motifsteps) == 0
%         etrace = zeros(P.xunits, P.hvcunits);
%     end


    % X activity is determined by input from HVC
    M(:, t) =  max(W_MH * H(:, t) - P.thresh, 0);
    % NOTE: LMAN has no immediate effect on HVC activity. Need to justify
    % this asymmmetry!

    PAL(:, t) = W_PM * M(:, t);
    D(:, t) = W_DP * PAL(:, t);
    
    % LMAN activity is the sum of intrinsic randomness and input from X.
    L(:, t) = randomness(:, t) + W_LD * D(:, t);
    L(:, t) = max(L(:, t), 0);
    % NOTE: that this LMAN input is used in NEXT time step

    % RA activity is the sum of inputs from HVC and LMAN
    R(:, t) = W_RH * H(:, t) + W_RL * L(:, t);

%     if mod(t, hvcsteps) == 0
%         continue
%     end
    
    % Calculate reward prediction error
    e  = (R(:, t) - P.template(:, s(t))).^2;
    if s(t) == P.caftime && R(:, t) < P.cafthresh
        e = P.caferror;
    end
    error(t + P.rewarddelay) = e; %%%DEBUG
    reward = -mean(error(t), 1); % averaged across all neurons
    rpe(t) = reward - V(s(t));

    % Update expected state value
    V(s(t)) = V(s(t)) + P.rperate * rpe(t);
    Vall(ceil(t/motifsteps), s(t)) = V(s(t));

    if t > 100*motifsteps% no learning for first 100 motifs
        % Update eligibility trace
        % Eligibility trace decays over time according to the discount rate and
        % receives an impulse when both the HVC and LMAN neuron . Eligibility
        % trace is specific to a single HVC->X synapse
        etrace = (((W_ML>0) * L(:, t)) * ones(1, P.hvcunits)) ...
            .*    ((W_MH~=0) .* (ones(P.xunits, 1) * H(:, t)')) ...
            + P.discountrate * etrace;
        eall(t, :) = diag(etrace);

        % Update synaptic weights onto medium spiny neurons based on reward and
        % spiking history of LMAN and HVC neurons.
        dw = etrace .* rpe(t) .* P.xrate;

        %%%DEBUG
%         dw(s(t), s(t)) = 0;
        
        W_MH = W_MH + dw; % direct pathway
        dwall(t,:) = diag(dw);

        % Update HVC to RA synapses with a spike timing dependent plasticity
        % rule. If they both spike in this time step, the synapse is
        % strengthened.
        %dw = (W_RL * L(:,t)) * H(:, t)' .* P.rarate - P.radecay;
        %temp(t) = dw(1);
        %W_RH  = W_RH + dw;

        % Make sure none of the updated synaptic weights change sign.
        W_MH = max(W_MH, winit); % don't let weights on to MSNs go to zero
        %W_RH = max(W_RH, 0);
        wall(t,:) = diag(W_MH);
        
    end
end
%save('charlesworthdemo.mat')

%% autocorrelation of LMAN fluctuations
figure
maxlag = 200;
[c, lags] = xcorr(randomness, maxlag, 'coeff');
axes('FontSize', 16)
plot(lags, c)
xlabel('Lag (ms)')
ylabel('Autocorrelation, normalized')
ylim([-0.2 1.2])

%% learning (change in pitch) normalized
figure
t = 1:motifsteps;
t = t - mean(t(s(t) == P.caftime));
pre = mean(gettrials(R, 1:50, motifsteps), 2);
post = mean(gettrials(R, -50:-1, motifsteps), 2);
learning = post - pre;
axes('FontSize', 16)
plot(t, learning / max(learning))
xlabel('Time from target (ms)')
ylabel('Learning, normalized')
xlim([-160 160])
ylim([-0.2 1.2])

%% mean pitch traces beginning and ending (not normalized)
figure
n = 20; % number of trials to average
Y = gettrials(R, -n:-1, motifsteps);
final = mean(Y, 2); 
Y = gettrials(R, 1:n, motifsteps);
start = mean(Y, 2);
plot(start, 'k')
hold on
plot(final, 'r')

%% weights over time
figure
x = 1:50;
y = linspace(0,P.motifs,size(wall,1));
imagesc(x,y,wall)
figure
plot(wall(:, [11, 25, 34]))

%% rpe-eligibility trace correlations at problem time
figure
Y = gettrials(rpe, 1:P.motifs, motifsteps);
yrpe = Y(s(1:motifsteps) == 36, :);
Y = gettrials(eall(:,35), 1:P.motifs, motifsteps);
yetrace = Y(s(1:motifsteps) == 36, :);
scatter(yrpe(:), yetrace(:))
plot(yrpe(:))

%%
figure;
Y = gettrials(rpe, 1:P.motifs, motifsteps);
imagesc(Y')
title('rpe')

%%
figure
Y = gettrials(error, 1:P.motifs, motifsteps);
imagesc(Y')
title('error')

%% average of rewarded lman fluctuations


%%
% Y = gettrials(rpe, 1:P.motifs, motifsteps);
% t = 1:motifsteps;
% target = mean(Y(s(t) == 34, :), 2);
% plot(target)
% figure
% plot(error)
% figure
% Y = gettrials(R, 1:50, motifsteps);
% plot(nanmean(Y, 2), 'k')
% hold on
% Y = gettrials(R, -50:-1, motifsteps);
% plot(nanmean(Y, 2), 'r')