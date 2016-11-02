% Alternating seed neuron differentiation, from subsong through
% protosyllable stage through splitting, to generate figure 5 a-f

% Emily Mackevicius 1/14/2015, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

% Calls HVCIter to step through one iteration of the model

%% Network parameters

% fixed parameters
seed = 115%9038;
p.seed = seed;          % seed random number generator
p.n = 100;              % n neurons
p.trainint = 10;        % Time interval between inputs
p.nsteps = 100;         % time-steps to simulate -- each time-step is 1 burst duration.
nstepsSubsong = 1000;   % time-steps to simulate for subsong stage
p.pin = .01;            % probability of external stimulation of at least one neuron at any time
k = 10;                 % number of training neurons
p.trainingInd = 1:k;    % index of training neurons
p.beta = .12;           % strength of feedforward inhibition % was .115
p.alpha = 30;           % strength of neural adaptation
p.eta = .025;           % learning rate parameter
p.epsilon = .2;         % relative strength of heterosynaptic LTD
p.tau = 4;              % time constant of adaptation
gammaStart= .01;        % strength of recurrent inhibition
gammaSplit =.18;        % increased strength of recurrent inhibition to induce splitting
wmaxStart = 1;          % single synapse hard bound
wmaxSplit = 2;          % single synapse hard bound to induce splitting (increased to encourage fewer stronger synapses)
mStart = 10;            % desired number of synapses per neuron (wmax = Wmax/m)
Wmax = mStart*wmaxStart;% soft bound for weights of each neuron
mSplit = Wmax/wmaxSplit;% keep Wmax constant, change m & wmax to induce fewer stronger synapses
HowClamped = 10;        % give training neurons higher threshold
HowOn = 10;             % higher inputs to training neurons

% how many iterations to run before plotting
nIterProto = 500;       % end of protosyllable stage
nIterPlotSplit1 = 492;  % number of splitting iterations before plotting intermediate splitting phase
nIterPlotSplit2 = 1500; % total number of splitting iterations

% parameters that change over development
protosyllableStage = [true(1,nIterProto) false(1,nIterPlotSplit2)]; 
splittingStage = [false(1,nIterProto) true(1,nIterPlotSplit2)];
gammas(protosyllableStage) = gammaStart;
gammas(splittingStage)     = gammaSplit * sigmf(1:nIterPlotSplit2,[1/200 500]);
wmaxs(protosyllableStage) = wmaxStart;
wmaxs(splittingStage)     = wmaxSplit;
ms(protosyllableStage) = mStart;
ms(splittingStage)     = mSplit;

% %Subsong Inputs
rng(seed)
isOnset = rand(1,nstepsSubsong)>.9; 
Input =-HowClamped*ones(k, nstepsSubsong); % clamp training neurons (effectively giving them higher threshold)
Input(:,isOnset) = HowOn; 
bdyn = double(rand(p.n,nstepsSubsong)>=(1-p.pin)); % Random activation
bdyn(1:k,:) = Input; 
subsongInput = bdyn; 

%Protosyllable inputs
PsylInput = -HowClamped*ones(k, p.nsteps); %clamp training neurons (effectively giving them higher threshold)
PsylInput(:,mod(1:p.nsteps,p.trainint)==1) = HowOn; % rhythmic activation of training neurons

%Alternating Inputs
AltInput =-HowClamped*ones(k, p.nsteps); % clamp training neurons (effectively giving them higher threshold)
AltInput(1:k/2,mod(1:p.nsteps,2*p.trainint)==1) = HowOn; % alternating rhythmic activation of training neurons
AltInput((k/2+1):k,mod(1:p.nsteps,2*p.trainint)==p.trainint+1) = HowOn; % alternating rhythmic activation of training neurons

% run simulation

% random initial weights
rng(seed);
w0 = 2*rand(p.n)*Wmax/p.n;
w = w0;

% % subsong stage
pSubsong = p; 
pSubsong.gamma = gammas(1); 
pSubsong.wmax = wmaxs(1); 
pSubsong.m = ms(1); 
pSubsong.eta = 0; 
pSubsong.epsilon = 0; 
pSubsong.nsteps = nstepsSubsong; 
pSubsong.w = w0; 
pSubsong.input = subsongInput;
% 
% % Run subsong network
% [wSubsong xdynSubsong] = HVCIter(pSubsong);
% w = wSubsong;

% learning stages
for t = 1:(nIterProto+nIterPlotSplit2)  
    p.w = w;
    % set parameters that change over development
    p.gamma = gammas(t); 
    p.wmax = wmaxs(t); 
    p.m = ms(t); 
    % Construct input
    bdyn = double(rand(p.n,p.nsteps)>=(1-p.pin)); % Random activation to all neurons
    whichSyl = rand>.5; 
    pflip = 0; 
    bdyn(1:k,:) = -HowClamped; 
    for sylind = 1:p.trainint:p.nsteps
        if protosyllableStage(t)
            bdyn(1:k,:) = PsylInput; 
        else
            whichSyl = mod(whichSyl + (rand<pflip),2); 
            bdyn(((whichSyl*k/2)+1):((whichSyl*k/2)+k/2), sylind) = HowOn; 
        end
    end
    p.input = bdyn;
    % run one iteration
    [w xdyn] = HVCIter(p);    
    dw(t) = norm(w(:)-p.w(:)); 
    % save certain iterations for plotting later
    switch t
        case nIterProto; 
            wProto = w; 
            pProto = p; 
            xdynProto = xdyn; 
        case nIterProto + nIterPlotSplit1; 
            wSplit1 = w; 
            pSplit1 = p; 
            xdynSplit1 = xdyn; 
        case nIterProto + nIterPlotSplit2;
            wSplit2 = w; 
            pSplit2 = p; 
            xdynSplit2 = xdyn; 
    end
end
%%
figure(2); shg
plot(dw); xlabel('# iterations'); ylabel('weight change (au)')
%%

p = pSplit2; 

% run one more iteration
% Construct input
p.nsteps = 200; 
bdyn = double(rand(p.n,p.nsteps)>=(1-p.pin)); % Random activation
whichSyl = rand>.5; 
%bdyn(1:k,:) = -HowClamped; 
bdyn(((whichSyl*k/2)+1):((whichSyl*k/2)+k/2), 1) = HowOn; % drive seed neurons just on first timestep
p.input = bdyn;
p.eta = 0; 

% run one iteration
[w xdyn] = HVCIter(p);    

wplot = w; 
xdynPlot = xdyn; xdynPlot(1:k,:) = xdynPlot(1:k,:)*.5;
ind = sortbyCorr(wplot); 

FS = 8; % font size

figure(1)
h = subplot('position', [.6 .2 .3 .7])
imagesc(wplot(ind,ind))
ylabel('Neuron #', 'fontsize', FS); xlabel('Neuron #', 'fontsize', FS)
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize', FS)

g = subplot('position', [.1 .2 .4 .7])
imagesc(xdynPlot(ind,:))
ylabel('Neuron #', 'fontsize', FS); xlabel('Time (au)', 'fontsize', FS)
colormap(flipud(hot))
title(['p_{flip} = ' num2str(pflip) ', seed ' num2str(seed)], 'fontsize', FS)
box off;
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize', FS)


linkaxes([h g], 'y')

set(gcf, 'papersize', [7 3]*.75, 'paperposition',[0 0 7 3]*.75)