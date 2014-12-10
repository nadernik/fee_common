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

% Early chain formation
% seed = 21;          % seed random number generator
% wmax = .2;          % single synapse hard bound
% m = 8;              % desired number of synapses per neuron (wmax = Wmax/m)
% n = 80;             % n neurons
% trainint = 8;       % Time interval between inputs
% nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.
% pn = .01;           % probability of external stimulation of at least one neuron at any time
% trainingInd = 1:8;  % index of training neurons


% seed = 80;          % seed random number generator
% wmax = 1;          % single synapse hard bound
% m = 8;              % desired number of synapses per neuron (wmax = Wmax/m)
% n = 100;             % n neurons
% trainint = 8;       % Time interval between inputs
% nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.
% pn = .01;           % probability of external stimulation of at least one neuron at any time
% trainingInd = 1:8;  % index of training neurons

seed = 80;          % seed random number generator
wmax = 1;          % single synapse hard bound
m = 8;              % desired number of synapses per neuron (wmax = Wmax/m)
n = 100;             % n neurons
trainint = 8;       % Time interval between inputs
nsteps = 80;        % time-steps to simulate -- each time-step is 1 burst duration.
pn = .01;           % probability of external stimulation of at least one neuron at any time
trainingInd = 1:8;  % index of training neurons
wmaxSplit = 2; 
gammaSplit = .9; 


nIters = 50*ones(1,50);

gammas = .8:.1:1.4; 
wmaxs = 1:8; 

Wmax = wmax*m;

% random initial weights
rng(seed);
w0 = rand(n)*wmax*m/n;

% training inputs
k = length(trainingInd);
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(:,mod(1:nsteps,trainint)==1) = 1; % rhythmic activation of training neurons

w = w0; 
niter = 500;        % number of iterations to run to form protosyllable
for i = 1:niter
    % Construct input
    bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
    bdyn(1:k,:) = Input; 
    % One 'bout' of learning
    [w xdyn] = HVCBout('w', w, 'input', bdyn, 'wmax', wmax, 'm', m, 'n', n, 'trainingInd', trainingInd);
end

% training inputs
trainingNeurons{1}.nIDs = 1:k/2;
trainingNeurons{2}.nIDs = (k/2+1):k;
trainingNeurons{1}.tind = repmat([true(1,trainint) false(1,trainint)],1,nsteps/trainint/2);
trainingNeurons{2}.tind = repmat([false(1,trainint) true(1,trainint)],1,nsteps/trainint/2);
Input = zeros(k, nsteps); % clamp training neurons
Input(trainingNeurons{1}.nIDs,mod(1:nsteps,2*trainint)==1) = 1; % alternating rhythmic activation of training neurons
Input(trainingNeurons{2}.nIDs,mod(1:nsteps,2*trainint)==trainint+1) = 1; % alternating rhythmic activation of training neurons

wPSyl = w; 
HowSplit = zeros(length(gammas),length(wmaxs),length(nIters));
for gammai = 1:length(gammas)
    for wmaxi = 1:length(wmaxs)
        w = wPSyl; 
        % splitting
        gamma = gammas(gammai);             
        wmax =  wmaxs(wmaxi);       
        for niteri = 1:length(nIters)
            niter = nIters(niteri); 
            for i = 1:niter
                % Construct input
                bdyn = double(rand(n,nsteps)>=(1-pn)); % Random activation
                bdyn(1:k,:) = Input; 
                % One 'bout' of learning
                [w xdyn] = HVCBout('w', w, 'input', bdyn,'wmax', wmax, 'm', Wmax/wmax, 'n', n, 'gamma', gamma, 'trainingInd', trainingInd);
            end
            Latency = findHVClatency(xdyn,trainint,trainingNeurons); 
            sum(xor(Latency{1}.FireDur,Latency{2}.FireDur))/sum(or(Latency{1}.FireDur,Latency{2}.FireDur));
        end
    end
    %squeeze(HowSplit(gammai,:,end))
    gammai
end
%%
cumIters = cumsum(nIters); 
CMAP = hot; 
nCmap = size(CMAP,1);
figure(3); clf; hold on 
ylabel('gamma'); xlabel('wmax'); 
ylim([gammas(1)-.1 gammas(end)+.1]); xlim([wmaxs(1)-1 wmaxs(end)+1])
set(gca, 'color', 'k')
for gammai = 1:length(gammas)
    for wmaxi = 1:length(wmaxs)
        tmp = squeeze(HowSplit(gammai,wmaxi,:)); % amount split over time
        M = max(tmp); 
        tmp1 = find((M-tmp)<.1); % within 10% of max
        TimeToSplit(gammai,wmaxi) = cumIters(tmp1(1)); 
        MaxSplit(gammai,wmaxi) = M*100;
        plot(wmaxs(wmaxi),gammas(gammai), '.','Color', CMAP(ceil(M*nCmap),:),...
            'MarkerSize', .1*(TimeToSplit(gammai,wmaxi)))
    end
end
figw = 6;
figh = 4; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw figh])


figure(1)
imagesc(MaxSplit, 'ydata', gammas, 'xdata', wmaxs); ylabel('gamma'); xlabel('wmax'); 
cb = colorbar('peer',gca); colormap jet
set(get(cb,'ylabel'),'String', 'Max split (%)');
figw = 6;
figh = 4; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw figh])
shg

figure(2)
imagesc(TimeToSplit, 'ydata', gammas, 'xdata', wmaxs); ylabel('gamma'); xlabel('wmax'); 
cb = colorbar('peer',gca); colormap jet
set(get(cb,'ylabel'),'String', 'Split time (iters)');
figw = 6;
figh = 4; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw figh])
shg
% print -dmeta -r150
