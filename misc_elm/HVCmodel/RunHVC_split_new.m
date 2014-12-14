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

% Alternating seed neuron differentiation
figure(1); clf
set(gcf, 'color', ones(1,3));

seed = 9877
p.seed = seed;          % seed random number generator
p.wmax = 1;             % single synapse hard bound
p.m = 10;               % desired number of synapses per neuron (wmax = Wmax/m)
p.n = 100;              % n neurons
p.trainint = 10;        % Time interval between inputs
p.nsteps = 100;         % time-steps to simulate -- each time-step is 1 burst duration.
p.pn = .01;             % probability of external stimulation of at least one neuron at any time
p.trainingInd = 1:10;   % index of training neurons
p.beta = .115;          % strength of feedforward inhibition
p.alpha = 30;           % strength of neural adaptation
p.eta = .025;           % learning rate parameter
p.epsilon = .2;         % relative strength of heterosynaptic LTD
p.tau = 4;              % time constant of adaptation
p.gamma= .01;           % strength of recurrent inhibition

wmaxSplit = 2;          % single synapse hard bound to induce splitting (increased to encourage fewer stronger synapses)
gammaSplit =.18;        % increased strength of recurrent inhibition to induce splitting


Niter = [1 499 492 2000]; % number of iterations for each plot (first 2 are protosyll, last 2 are splitting)
gammas = sigmf(1:Niter(end),[1/200 500])*gammaSplit; % gradually increase gamma to gammaSplit
Wmax = p.wmax*p.m;

% saving params for later.
p.gammas = gammas;
p.wmaxSplit = wmaxSplit; 
p.gammaSplit = gammaSplit; 
p.Niter = Niter; 
folder = 'C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SavedParams';
timestamp = datestr(now, 'mmm-dd-yyyy-HH-MM-SS');
SavedHere = fullfile(folder, ['Params', timestamp])
save(SavedHere,'p');
%%

% random initial weights
rng(seed);
w0 = 2*rand(p.n)*Wmax/p.n; 

%Psyl inputs
% training inputs
k = length(p.trainingInd);
trainint = p.trainint;
nsteps = p.nsteps;
n = p.n;
pn = p.pn;
HowClamped = 10; 
HowOn = 10; 
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
Input = -HowClamped*ones(k, nsteps); %clamp training neurons (effectively giving them higher threshold)
Input(:,mod(1:nsteps,trainint)==1) = HowOn; % rhythmic activation of training neurons
PsylInput = Input; 
trainingNeuronsPsyl = trainingNeurons; 

%Alternating Inputs
% training inputs
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([false(1,trainint) true(1,trainint)],1,nsteps/trainint/2);
Input =-HowClamped*ones(k, nsteps); % clamp training neurons (effectively giving them higher threshold)
Input(trainingNeurons{1}.nIDs,mod(1:nsteps,2*trainint)==1) = HowOn; % alternating rhythmic activation of training neurons
Input(trainingNeurons{2}.nIDs,mod(1:nsteps,2*trainint)==trainint+1) = HowOn; % alternating rhythmic activation of training neurons
AltInput = Input;
trainingNeuronsAlt = trainingNeurons; 



%  forming protosyllable
w = w0; 
trainingNeurons = trainingNeuronsPsyl; 
niter = Niter(1);     % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = PsylInput; 
    p.w = w; 
    p.input = bdyn;
    % One 'bout' of learning
    %tmp = p; tmp.eta = 0; 
    [w xdyn] = HVCBout(p);
end

subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none'); title(Niter(1))
PlottingParams.axesPosition = [Margin/2+0 Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

niter = Niter(2);     % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = PsylInput; 
    p.w = w; 
    p.input = bdyn;
    % One 'bout' of learning
    %tmp = p; tmp.eta = 0; 
    [w xdyn] = HVCBout(p);
end
%HVCtestRaster(xdyn,Input,w);
wpsyl = w; 
%
subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none');title(Niter(2))
PlottingParams.axesPosition = [Margin/2+plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
%%

PlotIters = 0;  % set to 1, and increase Niter(3), if you want to plot each step as it goes

%  splitting 
w = wpsyl;
p.wmax = wmaxSplit;  
p.m = Wmax/p.wmax;

trainingNeurons = trainingNeuronsAlt; 
niter = Niter(3); 
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = AltInput; 
    p.w = w; 
    p.input = bdyn;
    p.gamma = gammas(i); 
    [w xdyn] = HVCBout(p);
    if  PlotIters &  i>470%& mod(i,1)==0 ; % if you want to plot each step as it goes
        i
        %HVCtestRaster(xdyn,Input,w);
        subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
        %plotHVCnet(w, xdyn, trainint, trainingNeurons, PlottingParams);
        pause(.5)
    end
end

% 
subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none');title(Niter(3))
PlottingParams.axesPosition = [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')


% Later splitting 
niter = Niter(4); 
for i = (Niter(3)+1):Niter(4)
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = AltInput; 
    % One 'bout' of learning
    p.w = w; 
    p.input = bdyn;
    p.gamma = gammas(i); 
    [w xdyn] = HVCBout(p);
end
% HVCtestRaster(xdyn,Input,w);
% subplot(2,2,3); plotHVCnet(w, xdyn, trainint, trainingNeurons, PlottingParams);
% 
subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none');title(Niter(4))
PlottingParams.axesPosition = [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% calculate how split it is
Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
HowSplit = sum(xor(Latency{1}.FireDur,Latency{2}.FireDur))/sum(or(Latency{1}.FireDur,Latency{2}.FireDur))

% figure parameters
figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seed)])
print -dmeta -r150
