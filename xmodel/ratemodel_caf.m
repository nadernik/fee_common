% 100 motifs without learning -- get baseline singing and let V(s) converge
% 500 motifs to learn -- hopefully for the last 100 motifs of this, we are
% at a stable learned state

% Start with song learned -- HVC->RA synapses non zero
% No consolidation -- HVC->RA synapse learning rate is zero

close all
clear all
debugging = true;
%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.005; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.2; % seconds, timescale of fluctuations in lman
P.motifs = 500; % number of motifs in simulation
P.baselinemotifs = 100; % number of motifs before learning starts

% Size of the network
P.hvcunits = 50; % number of units in hvc
P.raunits = 1;
P.lmanunits = 1; % number of units in lman
P.xunits = P.lmanunits * P.hvcunits; % number of units in x

% Learning rates and other fudge factors
P.xrate = .008; % learning rate in HVC->X synapse
P.rarate = 0; % learning rate in HVC->RA synapse
P.rperate = .2; % learning rate of state value function V(s)
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

escapetrials = true(1, P.motifs);
%% Initialize

assert(size(P.template, 1) == P.raunits)
assert(size(P.template, 2) == P.hvcunits)

hvcsteps = P.thvc / P.dt; % number of time steps in each hvc burst
motifsteps = hvcsteps * P.hvcunits; % number of time steps per motif
maxsteps = motifsteps * P.motifs; % total number of time steps to simulate

% "State" is the HVC unit that is currently firing.
s = @(t) ceil(modnonzero(t, motifsteps)/hvcsteps);

% Neural activity
H = eye(P.hvcunits);
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
W_RH = P.template;

% Two LMAN units with opposite effects on the single RA neuron.
% W_RL = [1, -1];
W_RL = 1;

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

% Initialize empty matrices for activity in other neurons
etrace = zeros(P.xunits, P.hvcunits);
V = zeros(1, P.hvcunits);
error = zeros(1,maxsteps +P.rewarddelay);
rpe = zeros(maxsteps, 1);

if debugging
    Vall = zeros(P.motifs, P.hvcunits);
    dw = zeros(size(W_MH));
    dwall = zeros(maxsteps, P.xunits);
    wall = zeros(maxsteps, P.xunits);
    eall = zeros(maxsteps, P.xunits);
end
motiflabel = cell(1, P.motifs);
%% Main loop
for t = 1:maxsteps

    % X activity is determined by input from HVC
    M(:, t) =  max(W_MH * H(:, s(t)) - P.thresh, 0);
    % NOTE: LMAN has no immediate effect on HVC activity. Need to justify
    % this asymmmetry!

    PAL(:, t) = W_PM * M(:, t); % Pallidal neurons
    D(:, t) = W_DP * PAL(:, t); % DLM neurons
    
    % LMAN activity is the sum of intrinsic randomness and input from DLM
    L(:, t) = randomness(:, t);% + W_LD * D(:, t);
    L(:, t) = max(L(:, t), 0); % Firing rates must be positive

    % RA activity is the sum of inputs from HVC and LMAN
    R(:, t) = W_RH * H(:, s(t)) + W_RL * L(:, t);
    
    % Calculate reward prediction error
    e  = (R(:, t) - P.template(:, s(t))).^2; % error
    if s(t) == P.caftime
        tr = ceil(t / motifsteps);
        if R(:, t) < P.cafthresh
            e = P.caferror;
            motiflabel{tr} = 'hit';
        else
            motiflabel{tr} = 'escape';
        end
    else
%         e = 0;
    end
    
    error(t + P.rewarddelay) = e; % 
    reward = -mean(error(t), 1); % averaged across all neurons
    rpe(t) = reward - V(s(t));

    % Update expected state value
    V(s(t)) = V(s(t)) + P.rperate * rpe(t);


    if t > P.baselinemotifs*motifsteps% no learning for first 100 motifs
        % Update eligibility trace
        % Eligibility trace decays over time according to the discount rate and
        % receives an impulse when both the HVC and LMAN neuron . Eligibility
        % trace is specific to a single HVC->X synapse
        etrace = (((W_ML>0) * L(:, t)) * ones(1, P.hvcunits)) ...
            .*    ((W_MH~=0) .* (ones(P.xunits, 1) * H(:, s(t))')) ...
            + P.discountrate * etrace;

        % Update synaptic weights onto medium spiny neurons based on reward and
        % spiking history of LMAN and HVC neurons.
        dw = etrace .* rpe(t) .* P.xrate;
        W_MH = W_MH + dw; % direct pathway

        % Update HVC to RA synapses with a spike timing dependent plasticity
        % rule. If they both spike in this time step, the synapse is
        % strengthened.
        %W_RH  = W_RH + dw;

        % Make sure none of the updated synaptic weights change sign.
        W_MH = max(W_MH, winit); % don't let weights on to MSNs go to zero
        %W_RH = max(W_RH, 0);
    end
    
    % Bookkeeping
    if debugging
        Vall(ceil(t/motifsteps), s(t)) = V(s(t));
        eall(t, :) = diag(etrace);
        wall(t,:) = diag(W_MH);
        dwall(t,:) = diag(dw);
    end
    
end
%save('charlesworthdemo.mat')

%% autocorrelation of LMAN fluctuations
figure
maxlag = 200;
[c, lags] = xcorr(randomness(1,:), maxlag, 'coeff');
axes('FontSize', 16)
plot(lags, c)
xlabel('Lag (ms)')
ylabel('Autocorrelation, normalized')
ylim([-0.2 1.2])
title('LMAN autocorrelation')

%% learning (change in pitch) normalized

% calculate actual learning
pre  = gettrials(R,   1:20, motifsteps);
post = gettrials(R, -20:-1, motifsteps);
learning = mean(post, 2) - mean(pre, 2);
learning = learning ./ max(learning);

% calculate predicted learning based on reinforced lman fluctuations
mo = find(strcmpi('escape', motiflabel));
mo = mo(mo < P.baselinemotifs);
rewarded = gettrials(R, mo, motifsteps);
predicted = mean(rewarded, 2) - mean(pre, 2);
predicted = predicted ./ max(predicted);

figure
t = 1:motifsteps;
t = t - mean(t(s(t) == P.caftime));
axes('FontSize', 16)
plot(t, learning, 'k')
hold on
plot(t, predicted, 'r')
xlabel('Time from target (ms)')
ylabel('Learning, normalized')
title('Actual and predicted learning')

%% Pitch distributions before and after, showing CAF threshold

% Overlayed pitch traces with target time highlighted
figure
hold on
pre = gettrials(R, 1:P.baselinemotifs, motifsteps);
plot(pre, 'Color', [.8 .8 .8])
plot(mean(pre, 2), 'k')
ylo = min(min(pre));
yhi = max(max(pre));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
t = 1:motifsteps;
xtarg = find(s(t) == P.caftime);
X = [min(xtarg) max(xtarg) max(xtarg) min(xtarg)];
Y = [ylo        ylo        yhi        yhi];
fill(X, Y, [1 1 .7], 'FaceAlpha', 0.5)
xlim([1 motifsteps])
ylim([ylo yhi])
xlabel('time')
ylabel('"Pitch"')
title('Songs, baseline')

% histogram of pitches in target time
figure
pitchtarg = pre(xtarg, :);
hist(mean(pitchtarg), .2:0.05:1.6)
xlabel('"Pitch"')
ylabel('N')
title('Histogram of pitch at target time')
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
title('Song, before and after')

%% weights over time
figure
x = 1:50;
y = linspace(0,P.motifs,size(wall,1));
imagesc(x,y,wall)
figure
plot(wall(:, [11, 25, 34]))

%%


%% rpe-eligibility trace correlations at problem time
% figure
% Y = gettrials(rpe, 1:P.motifs, motifsteps);
% yrpe = Y(s(1:motifsteps) == 36, :);
% Y = gettrials(eall(:,35), 1:P.motifs, motifsteps);
% yetrace = Y(s(1:motifsteps) == 36, :);
% scatter(yrpe(:), yetrace(:))
% plot(yrpe(:))

%% RPE over time
figure;
Y = gettrials(rpe, 1:P.motifs, motifsteps);
imagesc(Y')
title('rpe')

%% Error over time
% figure
% Y = gettrials(error, 1:P.motifs, motifsteps);
% imagesc(Y')
% title('error')