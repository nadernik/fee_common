% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
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
% plotting parameters...
PlottingParams.msize = 5;
PlottingParams.linewidth = .01; 
PlottingParams.Syl1Color = [1 0 0]; 
PlottingParams.Syl2Color = [0 1 0]; % please choose orthogonal colors.. if you don't I'll try and normalize colors and it'll look muddy
PlottingParams.ProtoSylColor = [1 0 1]; 
PlottingParams.Syl1Color = PlottingParams.Syl1Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.Syl2Color = PlottingParams.Syl2Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.pltprct = 50; % in network visualization, plot connections > this percentile
PlottingParams.numFontSize = 5; 
PlottingParams.labelFontSize = 8; 
PlottingParams.wplotmin = 0; 
PlottingParams.wplotmax = 2; 

% Alternating seed neuron differentiation
figure(1); clf

seed = 4039; 
p.seed = seed;          % seed random number generator

p.wmax = 1;             % single synapse hard bound
p.m = 10;               % desired number of synapses per neuron (wmax = Wmax/m)
p.n = 100;              % n neurons
p.trainint = 10;        % Time interval between inputs
p.nsteps = 100;         % time-steps to simulate -- each time-step is 1 burst duration.
p.pn = .01;             % probability of external stimulation of at least one neuron at any time
p.trainingInd = 1:10;   % index of training neurons
p.beta = .11;           % strength of feedforward inhibition
p.alpha = 30;           % strength of neural adaptation
p.eta = .025;           % learning rate parameter
p.epsilon = .2;         % relative strength of heterosynaptic LTD
p.tau = 3;              % time constant of adaptation
p.gamma= .01;           % strength of recurrent inhibition
wmaxSplit = 2; 
gammaSplit =.18; 

Niter = [1 499 496 1500]; % number of iterations for each plot (first 2 are protosyll, last 2 are splitting)
gammas = sigmf(1:Niter(end),[1/200 500])*gammaSplit;%gammas = gammaSplit*(1-exp(-(1:Niter(end))/300)); 
p.gammas = gammas;
p.wmaxSplit = wmaxSplit; 
p.gammaSplit = gammaSplit; 
p.Niter = Niter; 

folder = 'C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SavedParams';
timestamp = datestr(now, 'mmm-dd-yyyy-HH-MM-SS');
SavedHere = fullfile(folder, ['Params', timestamp])
save(SavedHere,'p');
%

PlotIters = 1; 
%
Wmax = p.wmax*p.m;

% random initial weights
rng(seed);
%w0 = rand(p.n)*p.m*Wmax/p.n; % old....
w0 = 2*rand(p.n)*Wmax/p.n; 

% training inputs
k = length(p.trainingInd);
trainint = p.trainint;
nsteps = p.nsteps;
n = p.n;
pn = p.pn;
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(:,mod(1:nsteps,trainint)==1) = 1; % rhythmic activation of training neurons
%
w = w0; 
niter = Niter(1);        % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = (rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    p.w = w; 
    p.input = bdyn;
    [w xdyn] = HVCBout(p);
end

subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none'); title(Niter(1))
PlottingParams.axesPosition = [Margin/2+0 Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% finish forming protosyllable
niter = Niter(2);     % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = (rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    p.w = w; 
    p.input = bdyn;
    % One 'bout' of learning
    [w xdyn] = HVCBout(p);
end

subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none');title(Niter(2))
PlottingParams.axesPosition = [Margin/2+plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% Early splitting 

p.wmax = wmaxSplit;  
p.m = Wmax/p.wmax;

% training inputs
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([false(1,trainint) true(1,trainint)],1,nsteps/trainint/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(trainingNeurons{1}.nIDs,mod(1:nsteps,2*trainint)==1) = 1; % alternating rhythmic activation of training neurons
Input(trainingNeurons{2}.nIDs,mod(1:nsteps,2*trainint)==trainint+1) = 1; % alternating rhythmic activation of training neurons
storeGamma = []; 

niter = Niter(3); 
for i = 1:niter
    % Construct input
    bdyn = (rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    p.w = w; 
    p.input = bdyn;
    p.gamma = gammas(i); 
    [w xdyn] = HVCBout(p);
    Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
    Nsplit = sum(xor(Latency{1}.FireDur,Latency{2}.FireDur));
    if  PlotIters & (Nsplit>14);%mod(i,25)==0
        i
        subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); 
        cla; plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
        PlottingParams.axesPosition = [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
        pause(.1)
    end
end


subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none');title(Niter(3))
PlottingParams.axesPosition = [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')


subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]);
plot(storeGamma)
%
% Later splitting 

niter = Niter(4); 
for i = (Niter(3)+1):Niter(4)
    % Construct input
    bdyn = (rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    p.w = w; 
    p.input = bdyn;
    p.gamma = gammas(i); 
    [w xdyn] = HVCBout(p);
    if 0%mod(i,10)==0
        subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); 
        cla; plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams); pause(.1)
    end
end

subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none');title(Niter(4))
PlottingParams.axesPosition = [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
HowSplit = sum(xor(Latency{1}.FireDur,Latency{2}.FireDur))/sum(or(Latency{1}.FireDur,Latency{2}.FireDur))
%
figw = 6;
figh = 3; 
%
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seed)])
print -dmeta -r150
