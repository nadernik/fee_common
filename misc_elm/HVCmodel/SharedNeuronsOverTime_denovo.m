% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 
clear all; close all; clc
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

nIters = 10*ones(1,150);
gamma = p.gamma; 
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

Wmax = p.wmax*p.m;

Nseeds = 500; 
c = 1; 
Nshared = zeros(Nseeds,length(nIters));
Nspecific = zeros(Nseeds,length(nIters));
LatA = [];
LatB = []; 

%Alternating Inputs
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
trainingNeurons{2}.tind = repmat([false(1,trainint) true(1,trainint)],1,nsteps/trainint/2);
Input =-HowClamped*ones(k, nsteps); % clamp training neurons (effectively giving them higher threshold)
Input(trainingNeurons{1}.nIDs,mod(1:nsteps,2*trainint)==1) = HowOn; % alternating rhythmic activation of training neurons
Input(trainingNeurons{2}.nIDs,mod(1:nsteps,2*trainint)==trainint+1) = HowOn; % alternating rhythmic activation of training neurons
%%
for seedi = 31:(Nseeds)
    tic
    % random initial weights
    rng(seedi);
    %w0 = rand(n)*wmax*m/n; % old version through #7
    w0 = 2*rand(n)*Wmax/n; 

    w = w0; 
    niter = 500;        % number of iterations to run to form protosyllable
    p.wmax = wmax; 
    p.m = m;
    p.gamma = gamma; 
    for i = 1:niter
        % Construct input
        bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
        bdyn(1:k,:) = Input; 
        % One 'bout' of learning
        p.w = w; 
        p.input = bdyn;
        [w xdyn] = HVCBout(p);
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
            bdyn(1:k,:) = Input; 
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
        for sharedi = 1:Nshared(seedi,niteri)
            LatA(c) = 10*Latency{1}.mode(sharedID(sharedi));
            LatB(c) = 10*Latency{2}.mode(sharedID(sharedi));
            c = c+1;
        end
    end
    seedi
    toc
end
%%
save(['C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SharedNeuronsOverTime14.mat'])
% #14: 30 runs, denova differentiation 
%%
load C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SharedNeuronsOverTime14
%
cumIters = cumsum(nIters); 
cumIters = cumIters(cumIters<=1500);
Nshared = Nshared(1:30,cumIters<=1500); 
Nspecific = Nspecific(1:30,cumIters<=1500); 

% indKeep = (Nshared(:,1:50)+Nspecific(:,1:50))<=20;
% indKeep = sum(indKeep,2)==0; 
% Nshared = Nshared(indKeep,:);
% Nspecific = Nspecific(indKeep,:);

PlottingParams.numFontSize = 5; 
PlottingParams.labelFontSize = 8; 

figure(1); clf
PercentShared = 100*Nshared./(Nshared+Nspecific-length(p.trainingInd)+eps); 
for ni = 1:size(PercentShared,1)
    PercentShared(ni,:) = smooth(PercentShared(ni,:),5);
end
plot(cumIters, PercentShared,'color', [.8 .8 .8])
errorpatch_asym(cumIters, (prctile(PercentShared,50)), (prctile(PercentShared,5)), (prctile(PercentShared,95)));shg
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
figure(2); clf
CNT = zeros(trainint,trainint)
for i = 1:trainint
    for j = 1:trainint
        CNT(i,j) = sum(LatA==i*10&LatB==j*10); 
    end
end
CNT = CNT/sum(CNT(:));
CNT = -log(CNT+eps).*(CNT~=0);
CNT1 = zeros((trainint+1)*10,(trainint+1)*10); 
indInsert = (trainint:trainint:trainint*10)
CNT1(indInsert, indInsert) = CNT; 
win = 25; imagesc(CNT1)
CNT1 = conv2(CNT1, gausswin(win)*gausswin(win)', 'same')
imagesc(CNT1, 'xdata', 10*(0:trainint+1), 'ydata', 10*(0:trainint+1)); colormap hot
%plot(LatA+J(1,:), LatB+J(2,:), 'k.')
xlabel('Latency in A'); ylabel('Latency in B')
figw = 3;
figh = 2; 
set(gca, 'fontsize', PlottingParams.numFontSize, 'ydir', 'normal')
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])

figure(3); clf
TotalActive = (Nshared+Nspecific); 
for ni = 1:size(TotalActive,1)
    TotalActive(ni,:) = smooth(TotalActive(ni,:),5);
end
plot(cumIters, TotalActive,'color', [.8 .8 .8])
errorpatch_asym(cumIters, (prctile(TotalActive,50)), (prctile(TotalActive,5)), (prctile(TotalActive,95)));shg
hold on
%errorpatch(cumIters, mean(PercentShared), std(PercentShared)); hold on
plot(cumIters,(prctile(TotalActive,50)), 'k')
xlabel('Number of bouts', 'fontsize', PlottingParams.labelFontSize); 
ylabel('Number of active neurons', 'fontsize', PlottingParams.labelFontSize)
figw = 3;
figh = 2; 
xlim([0 1500]); ylim([0 100])
set(gca, 'fontsize', PlottingParams.numFontSize)
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])

% figure(3); clf; hold on
% for i = 1:1000
%     LatASim = LatA(randperm(length(LatA))); 
%     Sim(i) = sum(LatASim==LatB)/length(LatA);
% end
% Data = sum(LatA==LatB)/length(LatA)
% hist(Sim*100); 
% ylabel('#'); xlabel('% same latency, shuffled'); title(['Actual % same latency = ' num2str(Data*100)]);%plot([Data Data], [0 max(hist(Sim))],'r')
% 

