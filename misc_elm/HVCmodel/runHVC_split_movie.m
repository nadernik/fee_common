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
PlottingParams.msize = 25;
PlottingParams.linewidth = 1; 
PlottingParams.Syl1Color = [1 0 0]; 
PlottingParams.Syl2Color = [0 1 0]; % please choose orthogonal colors.. if you don't I'll try and normalize colors and it'll look muddy
PlottingParams.ProtoSylColor = [1 0 1]; 
PlottingParams.Syl1Color = PlottingParams.Syl1Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.Syl2Color = PlottingParams.Syl2Color/max(PlottingParams.Syl1Color+PlottingParams.Syl2Color);
PlottingParams.numFontSize = 5; 
PlottingParams.labelFontSize = 14; 
PlottingParams.wplotmin = 0; 
PlottingParams.wplotmax = 2; % this should be wmaxSplit


% Alternating seed neuron differentiation
figure(1); clf

% figure parameters
figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])

seed = 4039
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
wmaxSplit = 2;          % single synapse hard bound to induce splitting (increased to encourage fewer stronger synapses)
gammaSplit =.18;        % increased strength of recurrent inhibition to induce splitting

Niter = [1 499 900 1500]; % number of iterations for each plot (first 2 are protosyll, last 2 are splitting)
gammas = sigmf(1:Niter(end),[1/200 500])*gammaSplit; % gradually increase gamma to gammaSplit
p.gammas = gammas;
p.wmaxSplit = wmaxSplit; 
p.gammaSplit = gammaSplit; 
p.Niter = Niter; 

PlotIters = 1; % set to 1, and increase Niter(3), if you want to plot each step as it goes

Wmax = p.wmax*p.m;

% random initial weights
rng(seed);
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


% set up to record movie
folder = 'C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\NetworkMovies';
timestamp = datestr(now, 'mmm-dd-yyyy-HH-MM-SS');
filename = ['NetLearnsSeed' num2str(seed) timestamp];
writerobj = VideoWriter(fullfile(folder, filename));
writerobj.FrameRate = 60; 
open(writerobj);


w = w0; 
for i = 1:500
    % Construct input
    bdyn = (rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    p.w = w; 
    p.input = bdyn;
    [w xdyn] = HVCBout(p);
    if mod(i,2)==0
        plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
        title([num2str(i) ' bouts'], 'fontsize', PlottingParams.labelFontSize)
        set(gca, 'color', 'none');
        frame = getframe(gcf);
        slowrate =1;
        for l = 1:slowrate
            writeVideo(writerobj,frame);
        end
    end
end
%


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
for i = 1:1500
    % Construct input
    bdyn = (rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    p.w = w; 
    p.input = bdyn;
    p.gamma = gammas(i); 
    [w xdyn] = HVCBout(p);
    Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
    Nsplit = sum(xor(Latency{1}.FireDur,Latency{2}.FireDur));
    if 1%mod(i,5)==0
        plotHVCnet(w,xdyn,trainint,trainingNeurons,PlottingParams)
        title([num2str(i+500) ' bouts'],'fontsize', PlottingParams.labelFontSize)
        set(gca, 'color', 'none');
        frame = getframe(gcf);
        if i>485 & i<505
            slowrate = 40; 
        elseif i>400
            slowrate =4;
        else
            slowrate = 1;
        end
        for l = 1:slowrate
            writeVideo(writerobj,frame);
        end
    end
end

close(writerobj);

% calculate how split it is
Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
HowSplit = sum(xor(Latency{1}.FireDur,Latency{2}.FireDur))/sum(or(Latency{1}.FireDur,Latency{2}.FireDur))

%suptitle(['seed ', num2str(seed)])
print -dmeta -r150
