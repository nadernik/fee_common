%% ONE CHAIN
% Model of protosyllable formation and differentiation
% Hannah Payne with Emily Mackevicius and Michale Fee
%
% Updated 11/24/14

% To quit early - just click anywhere on graph

% INPUTS
k = 8;          % External input drives k neurons simultaneously
m = k;          % Each neuron can have m*wmax incoming(outgoing) synaptic weight before heterosynaptic LTD kicks in
n = 100;        % Number of neurons
trainint = 10;  % Interval between training input
beta = .1;      % Strength of feed-forward inhibition. .02 for trainint 10
eta = .01;      % Overall learning rate
epsilon = .01;  % Relative strength of heterosynaptic LTD
pin = .01;      % Probability of random activation of any one neuron
vidname = [];   % Save video name (leave empty [] if unneeded)
vidname2 = [];
psuccess = 1;   % P firing given above thresh activity - leave at 1
gamma = .1;     % Level of lateral inhibition at baseline

% OUTPUTS
% w: weight matrix
% p: structure of parameters

[w0, ~, ~, p] = simSplit('w',[],'wmax',1,'split',0,'recordvid',vidname,...
    'n',n,'m',m,'k',k,'beta',beta,'trainint',trainint,...
    'eta',eta,'pin',pin,'gamma',gamma,'epsilon',epsilon,...
    'niters',100,'psuccess',psuccess);

%% SPLIT
% 1. Allow fewer, stronger synapses (wmax = 2, m = m/2)
% 2. Split up training inputs into two groups (split = 1)
% 3. Increase lateral inhibition (gamma = .7-.9)
[w1, ~, ~, psplit]= simSplit('w',w0,'wmax',2,'split',1,'recordvid',vidname2,...
    'n',n,'m',m/2,'k',k,'beta',beta,'trainint',trainint,...
    'eta',eta*2,'pin',pin,'gamma',.9,'epsilon',epsilon,...
    'niters',1000,'psuccess',psuccess); %129

