% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

% plotting setup
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

%% Alternating seed neuron differentiation
figure(1); clf

% seed = 29876;         % seed random number generator
% wmax = 1;           % single synapse hard bound
% m = 10;              % desired number of synapses per neuron (wmax = Wmax/m)
% n = 110;            % n neurons
% trainint = 10;       % Time interval between inputs
% nsteps = 100;        % time-steps to simulate -- each time-step is 1 burst duration.
% pn = .01;           % probability of external stimulation of at least one neuron at any time
% trainingInd = 1:10;  % index of training neurons
% beta = .15; 
% wmaxSplit = 2; 
% gammaSplit =.2; 
% betaSplit = .15; 
% gammascale = .02; 


seed = 220;         % seed random number generator
wmax = 1;           % single synapse hard bound
m = 8;              % desired number of synapses per neuron (wmax = Wmax/m)
n = 100;            % n neurons
trainint = 8;       % Time interval between inputs
nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.
pn = .01;           % probability of external stimulation of at least one neuron at any time
trainingInd = 1:8;  % index of training neurons
beta = .1; 
wmaxSplit = 4; 
gammaSplit =.8; 
betaSplit = .1; 
gammascale = 0; 

Niter = [10 50 1000 500]; % number of iterations for each plot (first 2 are protosyll, last 2 are splitting)

Wmax = wmax*m;

% random initial weights
rng(seed);
w0 = rand(n)*m*Wmax/n;

% training inputs
k = length(trainingInd);
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
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'beta', beta, 'wmax', wmax, 'm', m, 'n', n, 'trainingInd', trainingInd);
    if mod(i,10)==0
        subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); 
        cla; plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
        pause(.01)
    end
end

subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
PlottingParams.axesPosition = [Margin/2+0 Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% finish forming protosyllable
niter = Niter(2);     % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'beta', beta, 'wmax', wmax, 'm', m, 'n', n,'trainingInd', trainingInd);
end


subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
PlottingParams.axesPosition = [Margin/2+plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
%
% Early splitting 

wmax = wmaxSplit;         
gamma = gammaSplit;        

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
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'beta', betaSplit, 'wmax', wmax, 'm', Wmax/wmax, 'n', n, 'gamma', gamma, 'trainingInd', trainingInd);
    Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
    NotSplit = sum(and(Latency{1}.FireDur,Latency{2}.FireDur))/(sum(or(Latency{1}.FireDur,Latency{2}.FireDur))-k);
    NotActive = (n-sum(or(Latency{1}.FireDur,Latency{2}.FireDur)))/(n-k);
    NotEven = abs(sum(Latency{2}.FireDur)-sum(Latency{1}.FireDur))/(sum(or(Latency{1}.FireDur,Latency{2}.FireDur)));
    gamma = max(0,gamma+gammascale*(NotSplit-NotActive-NotEven));
    %beta = max(0, beta+gammascale*(NotSplit-NotActive))
    storeGamma(i) = gamma; 
    %storeBeta(i) = beta; 
    if  mod(i,50)==0
        subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); 
        cla; plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
        pause(.1)
    end
end


subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
PlottingParams.axesPosition = [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')


subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]);
plot(storeGamma)
%%
% Later splitting 

niter = Niter(4); 
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'beta', beta,'wmax', wmax, 'm', Wmax/wmax, 'n', n, 'gamma', gamma, 'trainingInd', trainingInd);
    
    if mod(i,10)==0
        subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); 
        cla; plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams); pause(.1)
    end
end

subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
PlottingParams.axesPosition = [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]; plotHVCraster_split(w,xdyn,trainint,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
HowSplit = sum(xor(Latency{1}.FireDur,Latency{2}.FireDur))/sum(or(Latency{1}.FireDur,Latency{2}.FireDur))

figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seed)])
print -dmeta -r150
