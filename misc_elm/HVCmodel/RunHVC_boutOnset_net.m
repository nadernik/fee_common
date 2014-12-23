% Emily Mackevicius 12/10/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

% plotting setup
clf;
clear all;
Margin = 1/5; 
nplots = 4;
plotw = .23; 
netw = plotw-.01;
rasterw = plotw-Margin/2;
rasterh = 3/4; 
netoffset = Margin/3;
neth = 1/4-Margin/4-.01; 
PlottingParams.msize = 5;
PlottingParams.linewidth = .01; 
PlottingParams.Syl1Color = [1 0 0]; 
PlottingParams.Syl2Color = [0 1 0]; % please choose orthogonal colors.. if you don't I'll try and normalize colors and it'll look muddy
PlottingParams.ProtoSylColor = [1 0 1]; 
PlottingParams.Syl1Color = PlottingParams.Syl1Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.Syl2Color = PlottingParams.Syl2Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.numFontSize = 5; 
PlottingParams.labelFontSize = 8; 
PlottingParams.wplotmin = 0; 
PlottingParams.wplotmax = 2; % this should be wmaxSplit
PlottingParams.totalPanels = 4; 
PlottingParams.thisPanel = 1; 
PlottingParams.sortby = 'weightMatrix'; 

% Alternating seed neuron differentiation
figure(1); clf
set(gcf, 'color', ones(1,3));

seed = 1009; %978, 1009, 1012, 1021,1022, 1023
p.seed = seed; 
p.wmax = 1;             % single synapse hard bound
p.m = 5;                % desired number of synapses per neuron (wmax = Wmax/m)
p.n = 100;              % n neurons
p.trainint = 10;        % Time interval between inputs
p.nsteps = 500;         % time-steps to simulate -- each time-step is 1 burst duration.
p.pn = .01;             % probability of external stimulation of at least one neuron at any time
p.trainingInd = 1:10;   % index of training neurons
p.beta = .13;           % strength of feedforward inhibition
p.alpha = 30;           % strength of neural adaptation
p.eta = .05;            % learning rate parameter
p.epsilon = .15;        % relative strength of heterosynaptic LTD
p.tau = 4;              % time constant of adaptation
p.gamma= .01;           % strength of recurrent inhibition
wmaxSplit = 2;          % single synapse hard bound to induce splitting (increased to encourage fewer stronger synapses)
gammaSplit =.26;        % increased strength of recurrent inhibition to induce splitting

Niter = [5    95   30   500]; % number of iterations for each plot (first 2 are protosyll, last 2 are splitting)
gammas = sigmf(1:Niter(end),[1/100 200])*gammaSplit; % gradually increase gamma to gammaSplit
p.gammas = gammas;
p.wmaxSplit = wmaxSplit; 
p.gammaSplit = gammaSplit; 
p.Niter = Niter; 

folder = 'C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SavedParams';
timestamp = datestr(now, 'mmm-dd-yyyy-HH-MM-SS');
SavedHere = fullfile(folder, ['Params', timestamp])
save(SavedHere,'p');

PlotIters = 0; % set to 1, and increase Niter(3), if you want to plot each step as it goes

figure(1); clf

Wmax = p.wmax*p.m;

% random initial weights
rng(seed);
w0 = 2*rand(p.n)*Wmax/p.n; 
%
% training inputs
k = length(p.trainingInd);
trainint = p.trainint;
nsteps = p.nsteps;
n = p.n;
pn = p.pn;
% training inputs
CyclesPerBout = 5; 
bOnOffset = 3; 
HowClamped = 10; 
HowOn = 10; 
HowOnPsyl = 10; 
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
Input = -HowClamped*ones(k, nsteps); % clamp training neurons
bOnOffsetVar = [1 randperm(20)];
indPsyl = [];
indBstart = [];
indOff = [];
prevPsylEnd = 1; 
for i = 1:(nsteps/CyclesPerBout/trainint)
    istart = (i-1)*CyclesPerBout*trainint+1+bOnOffsetVar(i)+bOnOffset; 
    indPsyl = [indPsyl istart istart+trainint istart+2*trainint];
    prevPsylEnd = istart+3*trainint;
    indBstart = [indBstart istart-bOnOffset]; 
    indOff = [prevPsylEnd prevPsylEnd:(istart+bOnOffset-1)];
end
indPsyl = indPsyl(indPsyl<=nsteps);
indBstart = indBstart(indBstart<=nsteps);
Input(trainingNeurons{2}.nIDs,indPsyl) = HowOnPsyl; % alternating rhythmic activation of training neurons
Input(trainingNeurons{1}.nIDs,indBstart) = HowOn; % alternating rhythmic activation of training neurons
Input(:,indOff) = -HowClamped; % clamp all neurons between bouts
trainingNeurons{1}.candLat = (-bOnOffset+1):trainint;
trainingNeurons{2}.candLat =  1:trainint; 


w = w0; 
PlottingParams.thisPanel = 1;
niter = Niter(1);     % number of iterations to run
for j = 1:niter
    % Construct input
    Input = -HowClamped*ones(k, nsteps); % clamp training neurons
    bOnOffsetVar = [1 randperm(20)];
    indPsyl = [];
    indBstart = [];
    indOff = [];
    prevPsylEnd = 1; 
    for i = 1:(nsteps/CyclesPerBout/trainint)
        istart = (i-1)*CyclesPerBout*trainint+1+bOnOffsetVar(i)+bOnOffset; 
        indPsyl = [indPsyl istart istart+trainint istart+2*trainint];
        indBstart = [indBstart istart-bOnOffset]; 
        indOff = [indOff prevPsylEnd:(istart-bOnOffset-1)];
        prevPsylEnd = istart+3*trainint;
    end
    indPsyl = indPsyl(indPsyl<=nsteps);
    indBstart = indBstart(indBstart<=nsteps);
    trainingNeurons{1}.tind = indBstart+bOnOffset;
    trainingNeurons{2}.tind = setdiff(indPsyl, indBstart+bOnOffset); 
    Input(trainingNeurons{2}.nIDs,indPsyl) = HowOnPsyl; % alternating rhythmic activation of training neurons
    Input(trainingNeurons{1}.nIDs,indBstart) = HowOn; % alternating rhythmic activation of training neurons
    Input(:,indOff) = -HowClamped; % clamp all neurons between bouts
    
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(:,indOff) = -HowClamped; % clamp all neurons between bouts
    bdyn(1:k,:) = Input; 
    p.w = w; 
    p.input = bdyn;
    % One 'bout' of learning
    [w xdyn] = HVCBout(p);
end
PlottingParams.thisPanel = 1;
PlottingParams.Hor = 0; 
plotHVCnet_boutOnset(w, xdyn, trainingNeurons, PlottingParams)
PlottingParams.Hor = 1;


%%
% finish forming protosyllable
PlottingParams.thisPanel = 2;
niter = Niter(2);     % number of iterations to run
for j = 1:niter
    % Construct input
    Input = -HowClamped*ones(k, nsteps); % clamp training neurons
    bOnOffsetVar = [1 randperm(20)];
    indPsyl = [];
    indBstart = [];
    indOff = [];
    prevPsylEnd = 1; 
    for i = 1:(nsteps/CyclesPerBout/trainint)
        istart = (i-1)*CyclesPerBout*trainint+1+bOnOffsetVar(i)+bOnOffset; 
        indPsyl = [indPsyl istart istart+trainint istart+2*trainint];
        indBstart = [indBstart istart-bOnOffset]; 
        indOff = [indOff prevPsylEnd:(istart-bOnOffset-1)];
        prevPsylEnd = istart+3*trainint;
    end
    indPsyl = indPsyl(indPsyl<=nsteps);
    indBstart = indBstart(indBstart<=nsteps);
    trainingNeurons{1}.tind = indBstart+bOnOffset;
    trainingNeurons{2}.tind = setdiff(indPsyl, indBstart+bOnOffset); 
    Input(trainingNeurons{2}.nIDs,indPsyl) = HowOnPsyl; % alternating rhythmic activation of training neurons
    Input(trainingNeurons{1}.nIDs,indBstart) = HowOn; % alternating rhythmic activation of training neurons
    Input(:,indOff) = -HowClamped; % clamp all neurons between bouts
    
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(:,indOff) = -HowClamped; % clamp all neurons between bouts
    bdyn(1:k,:) = Input; 
    p.w = w; 
    p.input = bdyn;
    % One 'bout' of learning
    [w xdyn] = HVCBout(p);
end
PlottingParams.thisPanel = 2;
plotHVCnet_boutOnset(w, xdyn, trainingNeurons, PlottingParams)

wpsyl = w; 


%%
% splitting 

shg
HowOnPsyl = 1; 
w = wpsyl; 
p.wmax = wmaxSplit;  
p.m = Wmax/p.wmax;
PlottingParams.thisPanel = 3;
niter = Niter(3); 
for j = 1:niter
    % Construct input
    Input = -HowClamped*ones(k, nsteps); % clamp training neurons
    bOnOffsetVar = [1 randperm(20)];
    indPsyl = [];
    indBstart = [];
    indOff = [];
    prevPsylEnd = 1; 
    for i = 1:(nsteps/CyclesPerBout/trainint)
        istart = (i-1)*CyclesPerBout*trainint+1+bOnOffsetVar(i)+bOnOffset; 
        indPsyl = [indPsyl istart istart+trainint istart+2*trainint];
        indBstart = [indBstart istart-bOnOffset]; 
        indOff = [indOff prevPsylEnd:(istart-bOnOffset-1)];
        prevPsylEnd = istart+3*trainint;
    end
    indPsyl = indPsyl(indPsyl<=nsteps);
    indBstart = indBstart(indBstart<=nsteps);
    trainingNeurons{1}.tind = indBstart+bOnOffset;
    trainingNeurons{2}.tind = setdiff(indPsyl, indBstart+bOnOffset); 
    Input(trainingNeurons{2}.nIDs,indPsyl) = HowOnPsyl; % alternating rhythmic activation of training neurons
    Input(trainingNeurons{1}.nIDs,indBstart) = HowOn; % alternating rhythmic activation of training neurons
    Input(:,indOff) = -HowClamped; % clamp all neurons between bouts
    
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(:,indOff) = -HowClamped; % clamp all neurons between bouts
    bdyn(1:k,:) = Input; 
    p.w = w; 
    p.input = bdyn;
    p.gamma = gammas(i); 
    [w xdyn] = HVCBout(p);
    if  PlotIters & (mod(j,50)==0); % if you want to plot each step as it goes
        j
        subplot(1,4,3)
        plotHVCnet_boutOnset(w, xdyn, trainingNeurons, PlottingParams)
        pause(.5)
    end
end
PlottingParams.thisPanel = 3;
plotHVCnet_boutOnset(w, xdyn, trainingNeurons, PlottingParams)
%%
PlottingParams.thisPanel = 4;
% Later splitting 
niter = Niter(4); 
for j = (Niter(3)+1):Niter(4)
    % Construct input
    Input = -HowClamped*ones(k, nsteps); % clamp training neurons
    bOnOffsetVar = [1 randperm(20)];
    indPsyl = [];
    indBstart = [];
    indOff = [];
    prevPsylEnd = 1; 
    for i = 1:(nsteps/CyclesPerBout/trainint)
        istart = (i-1)*CyclesPerBout*trainint+1+bOnOffsetVar(i)+bOnOffset; 
        indPsyl = [indPsyl istart istart+trainint istart+2*trainint];
        indBstart = [indBstart istart-bOnOffset]; 
        indOff = [indOff prevPsylEnd:(istart-bOnOffset-1)];
        prevPsylEnd = istart+3*trainint;
    end
    indPsyl = indPsyl(indPsyl<=nsteps);
    indBstart = indBstart(indBstart<=nsteps);
    trainingNeurons{1}.tind = indBstart+bOnOffset;
    trainingNeurons{2}.tind = setdiff(indPsyl, indBstart+bOnOffset); 
    Input(trainingNeurons{2}.nIDs,indPsyl) = HowOnPsyl; % alternating rhythmic activation of training neurons
    Input(trainingNeurons{1}.nIDs,indBstart) = HowOn; % alternating rhythmic activation of training neurons
    Input(:,indOff) = -HowClamped; % clamp all neurons between bouts
    
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(:,indOff) = -HowClamped; % clamp all neurons between bouts
    bdyn(1:k,:) = Input; 
    p.w = w; 
    p.input = bdyn;
    p.gamma = gammas(i); 
    [w xdyn] = HVCBout(p);
end
PlottingParams.thisPanel = 4;
plotHVCnet_boutOnset(w, xdyn, trainingNeurons, PlottingParams)


%%
% figure parameters
figw = 6;
figh = 4; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw figh])
print -dmeta -r150
