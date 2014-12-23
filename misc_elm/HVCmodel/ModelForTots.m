%% running individual simulations for slices through time.
[wsort1 xsort groupings] = sim_seq('niters', 50, 'plotting', 0);%, 'seed', 52);
%%
wsort = wsort1; 
[wsort xsort groupings] = sim_seq('niters', 100,'split',1,'w',wsort,'m',4,'gamma',.7, 'plotting', 0);
figure(4); imagesc(xsort)
%% plotting simulations 

xplot = xsort(:,1:16); 
cmap = flipud(gray);

Red = 1:4;
Green = 5:8; 
if issame(xplot(Red,:), xplot(Green,:))
    Green = [];
    Red = 1:8; 
end
xplot(Red,:) = xplot(Red,:)*(1+3/size(cmap,1)); 
xplot(Green,:) = xplot(Green,:)*(1+5/size(cmap,1));
cmap(68,:) = [1 0 0]; % some red training neurons
cmap(69,:) = [0 1 0]; % some green training neurons

[~,sortind] = sortrows(xplot>0); 
xplot = xplot(flipud(sortind),:);
sharedind = sum(xplot,2)>=2;
rest = find(~sharedind); 
xplot = xplot([find(sharedind); (rest)],:);
figure(1); clf; imagesc(xplot); colormap(cmap)
hold on; %plot([.5 16.5], [8 8], 'k'); axis tight
plot([0.5 7.5], [-3 -3], 'r', 'linewidth', 10)
plot([8.5 15.5], [-3 -3], 'g', 'linewidth', 10)

ylim([-4 size(xplot,1)+1])
ylabel('neuron'), xlabel('timestep')
set(gcf, 'color', [1 1 1],'papersize', [4 6], 'paperposition', [0 0 4 6])
figure(2); clf; [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
figure(1)




%% running multiple simulations for summary plots of shared neurons
pshared = {};
SharedPhase = {};
for sim = 1:1
    
    [wsort1 xsort groupings] = sim_seq('niters', 50, 'plotting', 0);
    wsort = wsort1;
    figure(2); clf; [pshared{sim},sp] = mygraph_elm(wsort,xsort,8, 0);

    diter = 5; 
    ncheckshared = 60; 
    niter = (1:ncheckshared)*diter;
    SharedPhase{sim} = {};
    for i = 1:ncheckshared;
        [wsort xsort groupings] = sim_seq('niters', diter,'w',wsort,'split',1, 'm',4,'gamma',.7, 'plotting', 0);
        figure(2); clf; [pshared{sim}(i),sp] = mygraph_elm(wsort,xsort,8, 0);
        SharedPhase{sim}{i} = sp;
    end
    sim
end
%% 
figure(2); clf;hold on
MatPshared = [];
for j = 1:numel(pshared)
    %plot(niter,pshared{j})
    MatPshared(j,:) = pshared{j}; 
end
errorpatch(niter, mean(MatPshared), std(MatPshared)); 
plot(niter, mean(MatPshared), 'k')
xlabel('number of iterations'); ylabel('shared neurons (%)')
set(gcf, 'Color', [1 1 1], 'papersize', [6 3], 'paperposition', [0 0 6 3]); 


%% % fix calculation of shared neurons to allow neurons at different phases
figure(4); clf; hold on
for j = 1:numel(pshared)
    for i = 1:niter
        plot(SharedPhase{j}{i}(:,1)+.1*randn(size(SharedPhase{j}{i},1),1),SharedPhase{j}{i}(:,1)+.1*randn(size(SharedPhase{j}{i},1),1), 'k.'); 
    end
end
xlabel('time in syllable A')
ylabel('time in syllable B')
set(gcf, 'Color', [1 1 1], 'papersize', [4 4], 'paperposition', [0 0 4 4]); 


%% running bout onset differentiation

% % set up initial protosequence
% [wsort1 xsort groupings] = sim_seq('niters', 50, 'plotting', 0);
% wsort = wsort1;
% figure(2); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
% 
% % bout onset differentiation
% diter = 5; 
% ncheckshared = 200; 
% niter = (1:ncheckshared)*diter;
% for i = 1:ncheckshared;
%     [wsort xsort groupings] = sim_seq('niters', diter,'w',wsort,'boutOnset',1, 'm',4,'gamma',.7, 'plotting', 0);
%     figure(2); [pshared(i),sp] = mygraph_elm(wsort,xsort,8, 1);
% end
% 
% % run without driving training inputs
% diter = 5; 
% ncheckshared = 60; 
% niter = (1:ncheckshared)*diter;
% for i = 1:ncheckshared;
%     [wsort xsort groupings] = sim_seq('niters', diter,'w',wsort,'InitiatorFree',1, 'm',4,'gamma',.7, 'plotting', 0, 'eta', 0);
%     figure(2); %[pshared(i),sp] = mygraph_elm(wsort,xsort,8, 1);
%     clf; imagesc(xsort)
% end

%% fixed seed for plots
seedstart = 20; 
figure(4); clf
Margin = 1/5; 
nplots = 4;
plotw = .23; 
netw = plotw-.01;
rasterw = plotw-Margin/2;
rasterh = 3/4; 
netoffset = Margin/3;
neth = 1/4-Margin/4-.01; 

% early chain
[wsort xsort groupings] = sim_seq('niters', 1, 'plotting', 0, 'seed', seedstart, 'eta', 0);
subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+0 Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% form protosyllable
[wsort xsort groupings] = sim_seq('niters', 100, 'plotting', 0, 'w', wsort, 'seed', seedstart+1);
subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% early splitting
[wsort xsort groupings] = sim_seq('niters', 20,'w',wsort,'split',1,'m',4,'gamma',.7, 'plotting', 0, 'seed', seedstart+2);
subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% split
[wsort xsort groupings] = sim_seq('niters', 200,'w',wsort,'split',1, 'm',4,'gamma',.7, 'plotting', 0, 'seed', seedstart+3);
subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')

figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seedstart)])
print -dmeta -r150
%%

%% trying tonic differentiation fixed seed for plots
seedstart = 20; 
figure(4); clf
Margin = 1/5; 
nplots = 4;
plotw = .23; 
netw = plotw-.01;
rasterw = plotw-Margin/2;
rasterh = 3/4; 
netoffset = Margin/3;
neth = 1/4-Margin/4-.01; 

% early chain
[wsort xsort groupings] = sim_seq('niters', 1, 'plotting', 0,'seed', seedstart, 'eta', 0);
subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+0 Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% form protosyllable
[wsort xsort groupings] = sim_seq('niters', 100, 'plotting', 0, 'w', wsort,'seed', seedstart+1);
subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% early splitting
m = 5;
indA = randperm(size(wsort,1)); indA = indA(1:m); 
indB = randperm(size(wsort,1)); indB = indB(1:m); 
wsort(indA,m) = .2;%*((1:m)>(length(wsort)+m*2+1)/2); % increase weights from these tonic seed neurons
wsort(indB,m*2) = .2;%*(((m*2+1):length(wsort))'<(length(wsort)+m*2+1)/2); % increase weights from these tonic seed neurons....2*(rand(size(wsort,1),1)>.7);
%wsort(:,1:m*2) = zeros(size(wsort,1),m*2); % no input from 'initiator' neurons
numiters = 10; 
gamma = .7; 
m_elm = 3; 
[wsort xsort groupings] = sim_seq('niters', numiters,'w',wsort,'split', 1,'m',4,'gamma',gamma, 'plotting', 0, 'm_elm',m_elm,'seed', seedstart+2);
subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
title([num2str(numiters) ' iters, g=' num2str(gamma) ', m=' num2str(m_elm)])

subplot('position', [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% split
[wsort xsort groupings] = sim_seq('niters', 100,'w',wsort,'split', 1, 'm',4,'gamma',gamma, 'plotting', 0, 'm_elm',m_elm,'seed', seedstart+3);
subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')

figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seedstart)])
print -dmeta -r150

%% trying 'bout onset' differentiation fixed seed for plots
seedstart = 20; 
figure(4); clf
Margin = 1/5; 
nplots = 4;
plotw = .23; 
netw = plotw-.01;
rasterw = plotw-Margin/2;
rasterh = 3/4; 
netoffset = Margin/3;
neth = 1/4-Margin/4-.01; 

% early chain
[wsort xsort groupings] = sim_seq('niters', 1, 'plotting', 0, 'seed', seedstart, 'eta', 0);
subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+0 Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% form protosyllable
[wsort xsort groupings] = sim_seq('niters', 100, 'plotting', 0, 'w', wsort, 'seed', seedstart+1);
subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% early splitting
[wsort xsort groupings] = sim_seq('niters', 200,'w',wsort,'m',4,'beta',.05, 'gamma', .8, 'ffInhTrain',10, 'plotting', 0,  'boutOnset', 1, 'm_elm', 8, 'wmaxtraining', 8,'seed', seedstart+2);
subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% split
[wsort xsort groupings] = sim_seq('niters', 200,'w',wsort, 'm',4,'beta',.05, 'gamma', .8,'ffInhTrain', 10, 'plotting', 0, 'boutOnset', 1,'m_elm', 8,'wmaxtraining', 8, 'seed', seedstart+3);
subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')

figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seedstart)])
print -dmeta -r150




%% Using Hannah's new code!  fixed seed for plots
seed = 21; 
figure(4); clf
Margin = 1/5; 
nplots = 4;
plotw = .23; 
netw = plotw-.01;
rasterw = plotw-Margin/2;
rasterh = 3/4; 
netoffset = Margin/3;
neth = 1/4-Margin/4-.01; 


% INPUTS
k = 8;          % External input drives k neurons simultaneously
m = k;          % Each neuron can have m*wmax incoming(outgoing) synaptic weight before heterosynaptic LTD kicks in
n = 80;        % Number of neurons
trainint = 8;  % Interval between training input
beta = .01;      % Strength of feed-forward inhibition. .02 for trainint 10
eta = .01;      % Overall learning rate
epsilon = .01;  % Relative strength of heterosynaptic LTD
pin = .02;      % Probability of random activation of any one neuron
vidname = [];   % Save video name (leave empty [] if unneeded)
vidname2 = [];
psuccess = 1;   % P firing given above thresh activity - leave at 1
gamma = .1;     % Level of lateral inhibition at baseline

% early chain
%[wsort xsort groupings] = sim_seq('niters', 1, 'plotting', 0, 'seed', seedstart, 'eta', 0);
[w0, xsort, ~, p] = simSplit('w',[],'wmax',1,'split',0,'recordvid',vidname,...
    'n',n,'m',m,'k',k,'beta',beta,'trainint',trainint,...
    'eta',eta,'pin',pin,'gamma',gamma,'epsilon',epsilon,...
    'niters',100,'psuccess',psuccess, 'seed', seed);
subplot('position', [netoffset+0 Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+0 Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% form protosyllable
%[wsort xsort groupings] = sim_seq('niters', 100, 'plotting', 0, 'w', wsort, 'seed', seedstart+1);
[w0, xsort, ~, p] = simSplit('w',w0,'wmax',1,'split',0,'recordvid',vidname,...
    'n',n,'m',m,'k',k,'beta',beta,'trainint',trainint,...
    'eta',eta,'pin',pin,'gamma',gamma,'epsilon',epsilon,...
    'niters',500,'psuccess',psuccess, 'seed', seed+1);
subplot('position', [netoffset+plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% early splitting
%[wsort xsort groupings] = sim_seq('niters', 20,'w',wsort,'split',1,'m',4,'gamma',.7, 'plotting', 0, 'seed', seedstart+2);
[w1, xsort, ~, psplit]= simSplit('w',w0,'wmax',2,'split',1,'recordvid',vidname2,...
    'n',n,'m',m,'k',k,'beta',beta,'trainint',trainint,...
    'eta',eta*2,'pin',pin,'gamma',.7,'epsilon',epsilon,...
    'niters',50,'psuccess',psuccess, 'seed', seed+2); %129
subplot('position', [netoffset+2*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+2*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')
% split
%[wsort xsort groupings] = sim_seq('niters', 200,'w',wsort,'split',1, 'm',4,'gamma',.7, 'plotting', 0, 'seed', seedstart+3);
[w1, xsort, ~, psplit]= simSplit('w',w1,'wmax',2,'split',1,'recordvid',vidname2,...
    'n',n,'m',m,'k',k,'beta',beta,'trainint',trainint,...
    'eta',eta*2,'pin',pin,'gamma',.7,'epsilon',epsilon,...
    'niters',200,'psuccess',psuccess, 'seed', seed+3); %129
subplot('position', [netoffset+3*plotw Margin/4+rasterh netw neth]); [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);
set(gca, 'color', 'none')
subplot('position', [Margin/2+3*plotw Margin+0 rasterw rasterh-Margin]); mysimraster_elm(wsort,xsort,8);
set(gca, 'color', 'none')

figw = 6;
figh = 3; 
set(gcf, 'color', [1 1 1],'papersize', [figw figh], 'paperposition', [0 0 figw*.9 figh])
suptitle(['seed ', num2str(seedstart)])
print -dmeta -r150