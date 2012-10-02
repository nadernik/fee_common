function ratemodel(varargin)

use_weights_from_file = '';

%% Parameters

% Time
P.dt = 0.001; % seconds, time step
P.thvc = 0.01; % seconds, length of hvc burst. sometimes I call this one time slice (slice is bigger than a step)
P.tlman = 0.05; % seconds, timescale of fluctuations in lman
P.motifs = 1500;%5000; % number of motifs in simulation
baseline_motifs = 100;

% Size of the network
P.hvcunits = 20; % number of units in hvc
P.raunits = 1;
P.lmanunits = P.raunits*2; % number of units in lman
P.xunits = 75;%P.hvcunits * P.lmanunits; % number of units in x
% Number of units in X is forced to be hvcunits*lmanunits because of the
% wiring pattern in X. Each unit in X receives input from a single HVC unit
% and a single LMAN unit. There is one X unit for each pair of inputs.

% Learning rates and other fudge factors
P.xrate = .001%.001; % learning rate in HVC->X synapse
P.rarate = 0; % learning rate in HVC->RA synapse
P.rperate = 0.05; % learning rate of state value function V(s)
P.discountrate = 0; % for reward prediction error. 0 means no history.
P.inhibition = 200; % MSN global inhibition strength
P.syndec = .006%0.001; % Strength of heterosynaptic competition. 0 turns off competition
P.Wmax = 0.03; % Threshold for heterosynaptic competition
P.thresh = 0.01; % spiking threshold for X neurons
P.lman_offset = 5;

kernel_length = 100;

% P = parseargs(P, varargin{:});

%% Initialize

hvcsteps = P.thvc / P.dt; % number of time steps in each hvc burst
motifsteps = hvcsteps * P.hvcunits; % number of time steps per motif

% The template, aka the sequence we are trying to learn. 
P.template = zeros(P.raunits, motifsteps);
h = 15;% 15th burst in motif
tburst = (h-1)*hvcsteps + (1:hvcsteps); 
P.template(:,tburst) = 10;


mu = kernel_length/2;
sig = kernel_length/4;
x = 1:kernel_length;
kernel = 1/sqrt(2*pi*sig.^2) * exp(-(x-mu).^2 / (2*sig^2));
ekernel_matrix = ones(P.hvcunits, 1) * kernel;
t_kernel = x;

% Make HVC neurons fire in a chain
H = zeros(P.hvcunits, motifsteps);
t = 1;
for u = 1:P.hvcunits
    for step = 1:hvcsteps
        H(u, t) = 1;
        t = t+1;
    end
end

% Make LMAN neurons fire randomly
L = zeros(P.lmanunits, motifsteps + 1, P.motifs);
randomness = zeros(P.lmanunits, motifsteps, P.motifs); 
for u = 1:P.lmanunits
    randomness(u,:,:) = generate_lman_noise(motifsteps, P.motifs);
end
L(:, 1, :) = randomness(:, 1, :);

% Initialize empty matrices for activity in other neurons
X1 = zeros(P.xunits, motifsteps, P.motifs);
RA = zeros(P.raunits, motifsteps, P.motifs);
etrace1 = zeros(P.xunits, P.hvcunits);
V = zeros(motifsteps + 1, 1);


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
for nX = 1:P.xunits
    nL = mod(nX, P.lmanunits) + 1;
    W_X1L(nX, nL) = 1;
end
W_LX1 = zeros(P.lmanunits, P.xunits);

% Weak all-to-all connectivity with random weights in HVC -> X
W_X1H = 0.01 * rand(P.xunits, P.hvcunits);

% X collaterals between X1 and X2 neurons that receive similar LMAN input
[junk, nL1] = find(W_X1L ~= 0);
W_X1X1 = -P.inhibition / P.xunits * P.lmanunits * ((ones(P.xunits, 1) * nL1') == (ones(P.xunits, 1) * nL1')');

% HVC starts out completely disconnected from RA
W_RAH = zeros(P.raunits, P.hvcunits);

if ~isempty(use_weights_from_file)
    disp(['Using weights from file ' use_weights_from_file])
    d = load(use_weights_from_file);
    V = d.V;
    W_X1H = d.W_X1H;
    baseline_motifs = 0;
    P.template = d.P.template;
end
    
initial_weights = W_X1H;
%% Main loop
for motif = 1:P.motifs

    % Change templates at the beginning of the 501st motif
    if motif == 601
        % move impulse template from 6th time step to 1st
        P.template_old = P.template;
        %P.template = zeros(P.raunits, motifsteps);
        nburst = 2;
        tburst = (1:hvcsteps) + nburst*hvcsteps; % last burst in motif
        P.template(:,tburst) = 10;
        disp('template changed!')
        weights_at_switch = W_X1H;
    end

    reward = zeros(1,motifsteps+kernel_length+1);
    eligibility_trace = zeros([size(W_X1H), motifsteps+kernel_length+1]);
    for t = 1:motifsteps

        % X activity is determined by input from HVC
%         X1(:, t, motif) =  max(W_X1H * H(:, t) - P.thresh, 0);
X1(:, t, motif) = 0.1 * (W_X1H * H(:, t) > P.thresh);

        % LMAN activity is the sum of intrinsic randomness and input from X.
        L(:, t + 1, motif) = randomness(:, t, motif) + W_LX1 * X1(:, t, motif);
        L(:, t + 1, motif) = max(L(:, t + 1, motif) + P.lman_offset, 0);
        % Note that this LMAN input is used in NEXT time step

        % RA activity is the sum of inputs from HVC and LMAN
        RA(:, t, motif) = W_RAH * H(:, t) + W_RAL * L(:, t, motif);

        % Calculate reward prediction error
        error  = RA(:, t, motif) - P.template(:, t);
        r = 1 - mean(error.^2, 1); % averaged across all neurons
        reward(t+t_kernel) = r * kernel + reward(t+t_kernel);
        rpe = reward(t) - V(t);

        % Update expected state value
        V(t) = V(t) + P.rperate * rpe;
        if motif > baseline_motifs
            % Update eligibility trace
            % Eligibility trace decays over time according to the discount rate and
            % receives an impulse when both the HVC and LMAN neuron . Eligibility
            % trace is specific to a single HVC->X synapse
            ee = (((W_X1L * L(:, t, motif)) * ones(1, P.hvcunits)) > 0) ...
                .*    (W_X1H .* (ones(P.xunits, 1) * H(:, t)'));
            for m = 1:P.xunits % for each MSN
                % eligibility trace is hvc input times lman input convolved
                % with kernel
                eligibility_trace(m,:, t+t_kernel) =  ee(m,:)'*ones(1,kernel_length) .* ekernel_matrix + ...
                    squeeze(eligibility_trace(m,:, t+t_kernel));
            end
        end

        % Global inhibition supresses learning in MSNs.
        I1 = max(0, 1 + W_X1X1 * X1(:, t, motif)) * ones(1, P.hvcunits);
        % NOTE: Inhibition only effects learning, not the actual output of MSNs

        % Update synaptic weights onto medium spiny neurons based on reward and
        % spiking history of LMAN and HVC neurons.
        W_X1H = W_X1H + etrace1 .* rpe .* I1 .* P.xrate; % direct pathway

        % Heterosynaptic competition: If all weights onto a given X neuron
        % exceed a limit (Wmax), then all weights onto that neuron are
        % decreased in strength by a constant (syndec)
        W_X1H = W_X1H - P.syndec * (sum(W_X1H, 2) > P.Wmax) * ones(1, P.hvcunits);

        % Update HVC to RA synapses with a spike timing dependent plasticity
        % rule. If they both spike in this time step, the synapse is
        % strengthened.
        dW = RA(:, t, motif) * H(:, t)' .* P.rarate;
        W_RAH  = W_RAH + dW;
        % NOTE: These synapses have no way to get weaker.

        % Make sure none of the updated synaptic weights change sign.
        W_X1H = max(W_X1H, 0.0001); % don't let weights on to MSNs go to zero
        W_RAH = max(W_RAH, 0);

        %%%DEBUG change template to see medium spiny neurons relearn

    end
end

%% Plot results

% Put each X neuron into a category based on strongest synaptic weight
% Proportion of neurons in each category
figure
for nX = 1:P.xunits
    nL = find(W_X1L(nX, :)); % LMAN unit that this X unit gets input from
    
    for h = 1:P.hvcunits
        tburst = (1:hvcsteps) + (h-1)*hvcsteps;
        mean_activity_per_hvc_burst(h, :) = squeeze(mean(X1(nX,tburst,:), 2));
    end

    area(mean_activity_per_hvc_burst')
    pause(0.1)
    if nL == 1
        % before switch
        [junk, h1] = max(mean(mean_activity_per_hvc_burst(:,500:600), 2));
        preferred_time_before(nX) = h1;
        [junk, h2] = max(mean(mean_activity_per_hvc_burst(:,end-100:end), 2));
        preferred_time_after(nX) = h2;
    else
        preferred_time_before(nX) = nan;
        preferred_time_after(nX) = nan;
    end
end
filename = sprintf('c:\\stetner\\data\\figures\\xmodel\\sparseness%s.mat', datestr(now, 'yyyymmddHHMMSS'));
save(filename)

figure
x = .5:1:P.hvcunits+.5;
subplot(2,1,1)
hist(preferred_time_before,x)
subplot(2,1,2)
hist(preferred_time_after,x)

filename = sprintf('c:\\stetner\\data\\xmodel\\ratemodel%.f.m', now);
save(filename)

end