clear all; close all; clc
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


nIters = 10*ones(1,50);

gammas = sigmf(1:sum(nIters),[1/100 200])*gammaSplit;%gammas = gammaSplit*(1-exp(-(1:Niter(end))/300)); 
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
gamma = p.gamma; 

Wmax = p.wmax*p.m;

Nseeds = 50; 
c = 1; 
Nshared = zeros(Nseeds,length(nIters));
Nspecific = zeros(Nseeds,length(nIters));
LatA = [];
LatB = []; 


% training inputs
k = length(p.trainingInd);
trainint = p.trainint;
nsteps = p.nsteps;
n = p.n;
pn = p.pn;
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

%%
for seedi = 1:(Nseeds)
    tic
    % random initial weights
    rng(seedi);
    w0 = 2*rand(p.n)*Wmax/p.n; 

    w = w0; 
    niter = 100;        % number of iterations to run to form protosyllable
    p.wmax = wmax; 
    p.m = m;
    p.gamma = gamma; 
    for i = 1:niter
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
    gc = 1; 
    %wmax = wmaxSplit;   
    HowOnPsyl = 1; 
    p.wmax = wmaxSplit;  
    p.m = Wmax/p.wmax;
    for niteri = 1:length(nIters)
        niter = nIters(niteri); 
        for i = 1:niter
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
        Latency = findHVClatency_boutOnset(xdyn, trainingNeurons); 
        sharedID = find(and(Latency{1}.FireDur,Latency{2}.FireDur));
        Nshared(seedi,niteri) = length(sharedID);
        length(sharedID)
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
save(['C:\Users\emackev\Documents\MATLAB\code\misc_elm\HVCmodel\SharedNeuronsOverTime15.mat'])
%%

cumIters = cumsum(nIters)*10; %10 bouts/iteration 
% Nshared = Nshared(1:8,:); 
% Nspecific = Nspecific(1:8,:); 

indKeep = (Nshared(:,1))<=20;
indKeep = sum(indKeep,2)==0; 
Nshared = Nshared(indKeep,:);
Nspecific = Nspecific(indKeep,:);

PlottingParams.numFontSize = 5; 
PlottingParams.labelFontSize = 8; 

figure(1); clf
PercentShared = 100*Nshared./(Nshared+Nspecific-length(p.trainingInd)+eps); 
for ni = 1:size(PercentShared,1)
    PercentShared(ni,:) = smooth(PercentShared(ni,:),5);
end
%plot(cumIters, PercentShared,'color', [.8 .8 .8])
errorpatch_asym(cumIters, (prctile(PercentShared,50)), (prctile(PercentShared,5)), (prctile(PercentShared,95)));shg
hold on
%errorpatch(cumIters, mean(PercentShared), std(PercentShared)); hold on
plot(cumIters,(prctile(PercentShared,50)), 'k')
xlabel('Number of bouts', 'fontsize', PlottingParams.labelFontSize); 
ylabel('Percent shared neurons', 'fontsize', PlottingParams.labelFontSize)
figw = 3;
figh = 2; 
set(gca, 'fontsize', PlottingParams.numFontSize)
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
% 
figure(2); clf
CNT = zeros(length(trainingNeurons{2}.candLat),length(trainingNeurons{1}.candLat))
for i = 1:length(trainingNeurons{2}.candLat)
    for j = 1:length(trainingNeurons{1}.candLat)
        iTest = trainingNeurons{2}.candLat(i);
        jTest = trainingNeurons{1}.candLat(j);
        CNT(i,j) = sum(LatA==iTest*10&LatB==jTest*10); 
    end
end
%
CNT = CNT/sum(CNT(:));
CNT = -log(CNT+eps).*(CNT~=0);
CNT1 = zeros((size(CNT,1))*10,(size(CNT,2))*10); 
indInsert1 = (1:size(CNT,1))*10-5;
indInsert2 = (1:size(CNT,2))*10-5;
CNT1(indInsert1, indInsert2) = CNT; 
win = 25; imagesc(CNT1)
CNT1 = conv2(CNT1, gausswin(win)*gausswin(win)', 'same')
imagesc(CNT1, 'xdata', 10*[trainingNeurons{1}.candLat 11]-5, 'ydata', 10*[trainingNeurons{2}.candLat 11]-5); colormap hot
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
