% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 
clear all; close all; clc
% params used for runs #1 &#2
% wmax = 1;           % single synapse hard bound
% m = 10;              % desired number of synapses per neuron (wmax = Wmax/m)
% n = 100;            % n neurons
% trainint = 10;       % Time interval between inputs
% nsteps = 100;        % time-steps to simulate -- each time-step is 1 burst duration.
% pn = .01;           % probability of external stimulation of at least one neuron at any time
% trainingInd = 1:10;  % index of training neurons
% beta = .13; 
% wmaxSplit = 2; 
% gammaSplit =.18; 
% betaSplit = beta; 
% %gammascale = .001; 
% 
% nIters = 10*ones(1,300);
% gammas = sigmf(1:sum(nIters),[1/200 500])*gammaSplit;%gammas = gammaSplit*(1-exp(-(1:sum(nIters))/300)); 
% Wmax = wmax*m;

% params used for run #7:
% p.wmax = 1;             % single synapse hard bound
% p.m = 10;               % desired number of synapses per neuron (wmax = Wmax/m)
% p.n = 100;              % n neurons
% p.trainint = 10;        % Time interval between inputs
% p.nsteps = 100;         % time-steps to simulate -- each time-step is 1 burst duration.
% p.pn = .01;             % probability of external stimulation of at least one neuron at any time
% p.trainingInd = 1:10;   % index of training neurons
% p.beta = .12; 
% p.alpha = 30;           % strength of neural adaptation
% p.eta = .025;           % learning rate parameter
% p.epsilon = .12;        % relative strength of heterosynaptic LTD
% p.tau = 3; 
% p.gamma= .01;       
% wmaxSplit = 2; 
% gammaSplit =.18; 

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

nIters = 10*ones(1,150);
gammas = sigmf(1:sum(nIters),[1/200 500])*gammaSplit;%gammas = gammaSplit*(1-exp(-(1:Niter(end))/300)); 
p.gammas = gammas;
p.wmaxSplit = wmaxSplit; 
p.gammaSplit = gammaSplit; 
trainint = p.trainint;
nsteps = p.nsteps;
n = p.n;
pn = p.pn;
trainingInd = p.trainingInd;
wmax = p.wmax;
m = p.m;

%
PlotIters = 1; 
%
Wmax = p.wmax*p.m;

Nseeds = 300; 
c = 1; 
Nshared = zeros(Nseeds,length(nIters));
Nspecific = zeros(Nseeds,length(nIters));
LatA = [];
LatB = []; 

%Psyl inputs
% training inputs
k = length(trainingInd);
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(:,mod(1:nsteps,trainint)==1) = 1; % rhythmic activation of training neurons
PsylInput = Input; 

%Alternating Inputs
% training inputs
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([false(1,trainint) true(1,trainint)],1,nsteps/trainint/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(trainingNeurons{1}.nIDs,mod(1:nsteps,2*trainint)==1) = 1; % alternating rhythmic activation of training neurons
Input(trainingNeurons{2}.nIDs,mod(1:nsteps,2*trainint)==trainint+1) = 1; % alternating rhythmic activation of training neurons
AltInput = Input;
%
for seedi = 1:(Nseeds)
    tic
    % random initial weights
    rng(seedi);
    %w0 = rand(n)*wmax*m/n; % old version through #7
    w0 = 2*rand(n)*Wmax/n; 

    w = w0; 
    niter = 500;        % number of iterations to run to form protosyllable
    for i = 1:niter
        % Construct input
        bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
        bdyn(1:k,:) = PsylInput; 
        % One 'bout' of learning
        p.w = w; 
        p.input = bdyn;
        [w xdyn] = HVCBout(p);
        %[w xdyn] = HVCBout('w', w, 'input', bdyn,'beta', beta, 'wmax', wmax, 'm', m, 'n', n, 'trainingInd', trainingInd);
    end
    gc = 1; 
    %wmax = wmaxSplit;   
    p.wmax = wmaxSplit;  
    p.m = Wmax/p.wmax;
    for niteri = 1:length(nIters)
        niter = nIters(niteri); 
        for i = 1:niter
            % Construct input
            bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
            bdyn(1:k,:) = AltInput; 
            p.gamma = gammas(gc); gc = gc+1; 
            p.w = w; 
            p.input = bdyn;
            [w xdyn] = HVCBout(p);
            %[w xdyn] = HVCBout('w', w, 'input', bdyn,'beta', beta, 'wmax', wmax, 'm', Wmax/wmax, 'n', n, 'gamma', gamma, 'trainingInd', trainingInd);
        end
        Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
        sharedID = find(and(Latency{1}.FireDur,Latency{2}.FireDur));
        Nshared(seedi,niteri) = length(sharedID);
        Nspecific(seedi,niteri) = sum(xor(Latency{1}.FireDur,Latency{2}.FireDur));
%         for sharedi = 1:Nshared(seedi,niteri)
%             if mod(sharedi,1000)==1 % don't need to record all shared neurons
%                 LatA(c) = 10*Latency{1}.mode(sharedID(sharedi));
%                 LatB(c) = 10*Latency{2}.mode(sharedID(sharedi));
%                 c = c+1;
%             end
%         end
    end
    seedi
    toc
end
%%
%save(['C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SharedNeuronsOverTime8.mat'])
% #1: 20 runs; #2: 378 runs #3: 70 runs, bad params for splitting #4: 300,
% bad params for splitting, #5: 100 runs, bad params for splitting
% runs, #6: 14 runs #7: 50 runs #8: 69 runs
%%
load C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SharedNeuronsOverTime8
cumIters = cumsum(nIters); 
cumIters = cumIters(cumIters<=1500);
Nshared = Nshared(1:69,cumIters<=1500); 
Nspecific = Nspecific(1:69,cumIters<=1500); 


PlottingParams.numFontSize = 5; 
PlottingParams.labelFontSize = 8; 

figure(1); clf
PercentShared = 100*Nshared./(Nshared+Nspecific-length(p.trainingInd)+eps); 
for ni = 1:size(PercentShared,1)
    PercentShared(ni,:) = smooth(PercentShared(ni,:));
end
figure; plot(cumIters, PercentShared,'color', [.8 .8 .8])
errorpatch_asym(cumIters, (prctile(PercentShared,50)), (prctile(PercentShared,25)), (prctile(PercentShared,75)));shg
hold on
%errorpatch(cumIters, mean(PercentShared), std(PercentShared)); hold on
plot(cumIters,(prctile(PercentShared,50)), 'k')
xlabel('Number of bouts', 'fontsize', PlottingParams.labelFontSize); 
ylabel('Percent shared neurons', 'fontsize', PlottingParams.labelFontSize)
figw = 3;
figh = 2; 
xlim([0 1500])
set(gca, 'fontsize', PlottingParams.numFontSize)
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
% 
% figure(2); 
% J = randn(2,length(LatA)); 
% plot(LatA+J(1,:), LatB+J(2,:), 'k.')
% xlabel('Latency in A'); ylabel('Latency in B')
% figw = 3;
% figh = 2; 
% set(gca, 'fontsize', PlottingParams.numFontSize)
% set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
% 
% figure(3); clf; hold on
% for i = 1:1000
%     LatASim = LatA(randperm(length(LatA))); 
%     Sim(i) = sum(LatASim==LatB)/length(LatA);
% end
% Data = sum(LatA==LatB)/length(LatA)
% hist(Sim*100); 
% ylabel('#'); xlabel('% same latency, shuffled'); title(['Actual % same latency = ' num2str(Data*100)]);%plot([Data Data], [0 max(hist(Sim))],'r')


