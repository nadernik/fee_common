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
PlottingParams.Syl2Color = [0 1 1]; % please choose orthogonal colors.. if you don't I'll try and normalize colors and it'll look muddy
PlottingParams.ProtoSylColor = [1 0 1]; 
PlottingParams.Syl1Color = PlottingParams.Syl1Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.Syl2Color = PlottingParams.Syl2Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.pltprct = 75; % in network visualization, plot connections > this percentile
PlottingParams.numFontSize = 10; 
PlottingParams.labelFontSize = 10; 

%% Alternating seed neuron differentiation
figure(1); clf
% Early chain formation
seed = 21;          % seed random number generator
Wmax = 1;           % single synapse hard bound
m = 8;              % desired number of synapses per neuron (wmax = Wmax/m)
n = 80;             % n neurons
trainint = 8;       % Time interval between inputs
nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.
pn = .01;           % probability of external stimulation of at least one neuron at any time
trainingInd = 1:8;  % index of training neurons


wmax = Wmax/m; 

% random initial weights
rng(seed);
w0 = rand(n)*2*Wmax/n;

% training inputs
k = length(trainingInd);
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,k) false(1,k)],1,nsteps/k/2);
trainingNeurons{2}.tind = repmat([true(1,k) false(1,k)],1,nsteps/k/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(:,mod(1:nsteps,trainint)==1) = 1; % rhythmic activation of training neurons

w = w0; 
niter = 1;        % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn, 'Wmax', Wmax, 'm', m, 'trainingInd', trainingInd);
end

% sort by order of firing
trainind = 1:k; 
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainind'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+0 Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% finish forming protosyllable

niter = 100;        % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn, 'Wmax', Wmax, 'm', m, 'trainingInd', trainingInd);
end

% sort by order of firing
trainind = 1:k; 
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainind'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+plotw Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% Early splitting 

Wmax = 1;           % single synapse hard bound
m = 3.75;           % desired number of synapses per neuron (wmax = Wmax/m)
n = 80;             % n neurons
gamma = .6;         % for splitting, if gamma=1 then neurons will only fire if they are activated more than average compared to other active neurons. 0 = normal rule
trainint = 8;       % Time interval between inputs
nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.

% training inputs
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,k) false(1,k)],1,nsteps/k/2);
trainingNeurons{2}.tind = repmat([false(1,k) true(1,k)],1,nsteps/k/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(trainingNeurons{1}.nIDs,mod(1:nsteps,2*trainint)==1) = 1; % alternating rhythmic activation of training neurons
Input(trainingNeurons{2}.nIDs,mod(1:nsteps,2*trainint)==trainint+1) = 1; % alternating rhythmic activation of training neurons

niter = 25; 
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'Wmax', Wmax, 'm', m, 'n', n, 'gamma', gamma, 'trainingInd', trainingInd);
end

% sort by order of firing
trainind = 1:k; 
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainind'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')


% Later splitting 

niter = 300; 
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'Wmax', Wmax, 'm', m, 'n', n, 'gamma', gamma, 'trainingInd', trainingInd);
end

% sort by order of firing
trainind = 1:k; 
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainind'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')


figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seed)])
print -dmeta -r150

%% Bout onset differentiation
figure(2);clf
% Early chain formation
seed = 32;          % seed random number generator
Wmax = 1;           % single synapse hard bound
m = 3;              % desired number of synapses per neuron (wmax = Wmax/m)
n = 80;             % n neurons
trainint = 8;       % Time interval between inputs
nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.
pn = .001;           % probability of external stimulation of at least one neuron at any time
trainingInd = 1:8;  % index of training neurons


wmax = Wmax/m; 

% random initial weights
rng(seed);
w0 = rand(n)*2*Wmax/n;
w = w0; 

% training inputs
k = length(trainingInd);
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,k) false(1,k) false(1,k) ],1,floor(nsteps/k/3));
trainingNeurons{2}.tind = repmat([false(1,k) true(1,k) true(1,k) ],1,floor(nsteps/k/3));
Input = -1*ones(k, nsteps); % clamp training neurons
Input(trainingNeurons{1}.nIDs,mod(1:nsteps,trainint*3)==1) = 5; % bout onset neurons
Input(trainingNeurons{2}.nIDs,(mod(1:nsteps,trainint*3)==1)|(mod(1:nsteps,trainint*3)==(trainint+1))|...
    (mod(1:nsteps,trainint*3)==(2*trainint+1))) = 1; % rhythmic seed neurons

w = w0; 
niter = 50;        % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn, 'Wmax', Wmax, 'm', m, 'n', n, 'trainingInd', trainingInd);
end

% sort by order of firing
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainingInd'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+0 Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% finish forming protosyllable

niter = 200;        % number of iterations to run
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn, 'Wmax', Wmax, 'm', m, 'n', n, 'trainingInd', trainingInd);
end

% sort by order of firing
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainingInd'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+plotw Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')

% Early splitting 

Wmax = 1;           % single synapse hard bound
m = 4;              % desired number of synapses per neuron (wmax = Wmax/m)
n = 80;             % n neurons
gamma = 1;         % for splitting, if gamma=1 then neurons will only fire if they are activated more than average compared to other active neurons. 0 = normal rule
beta = .005;         % global inhibition strength
trainint = 8;       % Time interval between inputs
nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.
pn = 0;             % probability of external stimulation of at least one neuron at any time


niter = 5; 
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'Wmax', Wmax, 'm', m, 'n', n, 'gamma', gamma, 'beta', beta, 'trainingInd', trainingInd);
end

% sort by order of firing
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainingInd'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')


% Later splitting 

niter = 20; 
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn,'Wmax', Wmax, 'm', m, 'n', n, 'gamma', gamma, 'beta', beta, 'trainingInd', trainingInd);
end

% sort by order of firing
[~,indrest] = sortrows(xdyn((k+1):end,:));
indsort =  [trainingInd'; k + flipud(indrest)];
wsort = w(indsort,indsort); 
xsort = xdyn(indsort,:); 

subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); plotHVCnet(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')
subplot('position', [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]); plotHVCraster(wsort,xsort,8,trainingNeurons,PlottingParams)
set(gca, 'color', 'none')


figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seed)])
print -dmeta -r150


