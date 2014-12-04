%% syllable differentiation model
% Hannah Payne 8/2013 with Michale Fee, Emily Mackevici
% Based on model of Fiete et al. 2010.
% Modified in order to:
% 1. Allow wide chains to form organically from a single "initiator"
%    external input
% 2. Implement splitting of wide chains by separating external inputs, and
%    increasing lateral or feedforward inhibition
%
% ======Example usage=======
% Step 1: Form sequence
% w0 = sim_seq;
%
% Step 2: Differentiate into 2 chains using lateral inhibition ('gamma',.7)
% w1 = sim_seq('w',w0,'split',1,'m',4,'gamma',.7);
%
% Or increase feedforward inhibition: 'beta', .1
% Or increase time constant of adaptation: 'tau', 4
%
% =====
% Modified 11/14/14 to different between m (number of wmax synapses
% allowed) and k (each external input targets k neurons)

function [wsort, xdyncleansort, groupings, p] = simSplit(varargin)
p = inputParser;
addParamValue(p,'n',80);            % n neurons
addParamValue(p,'m',8);             % desired number of synapses per neuron (wmax = Wmax/m)
addParamValue(p,'k',8);             % Target chain width - each external input tagets k neurons
addParamValue(p,'alpha',50);        % strength of neural adaptation
addParamValue(p,'tau',4);           % time-constant of neural adaptation (only used if alpha is not 0)
addParamValue(p,'beta',0.01);      % global inhibition strength
addParamValue(p,'eta',0.01);        % learning rate parameter
addParamValue(p,'epsilon',.2);      % relative strength of heterosynaptic LTD
addParamValue(p,'wmax',1);          % single synapse hard bound
addParamValue(p,'pin',.01);           % probability of external stimulation of at least one neuron at any time
addParamValue(p,'w',[]);            % Initial weight matrix (random if blank)
addParamValue(p,'split',0);         % Split up inputs into two groups
addParamValue(p,'gamma',0);         % for splitting, if gamma=1 then neurons will only fire if they are activated more than average compared to other active neurons. 0 = normal rule
addParamValue(p,'inhscaling',10);    % Scale strength of inhibition with strength of excitatory inputs - avoids spurious chain activation
addParamValue(p,'recordvid',[]);
addParamValue(p,'seed',randi(1000));
addParamValue(p,'psuccess',1);      % Prob of a neuron firing if above thresh
addParamValue(p,'niters',2000);
addParamValue(p,'nsteps',100);      % time-steps in one "iteration" - plot generated once per iter
addParamValue(p,'trainint',10);      % Time interval between inputs
parse(p,varargin{:}); p = p.Results;

niters = p.niters; % Number of iterations total
nsteps = p.nsteps;
n = p.n;
m = p.m;
k = p.k;
wmax = p.wmax;
Wmax = wmax*m;
eta = p.eta;
trainint = p.trainint;
rng(p.seed); % Optional set seed

if isempty(p.w)
    %   w = rand(n)*2*Wmax/n; % Each row's total weight ~= Wmax
    w = zeros(n); %*** 11/20/14 More general case: start ws at 0
else
    w = p.w;
end

if ~isempty(p.recordvid)
    writerobj = VideoWriter(p.recordvid);
    open(writerobj)
end

% Set up training input
bdyn = zeros(n,nsteps);
bdyn(1:k,:) = -1;
if p.split
    bdyn(1:round(k/2),mod(1:nsteps,trainint*2) == 1) = 1;
    bdyn(round(k/2)+1:k,mod(1:nsteps,trainint*2)==trainint+1) = 1;
else
    bdyn(1:k,mod(1:nsteps,trainint)==1) = 1;
end

for iter=1:niters
    
    xdyn=zeros(n,nsteps);
    cdyn=false(n,nsteps);
    oldx = zeros(n,1);
    oldy = zeros(n,1);
    
    for i = 1:nsteps
        % Random activation
        
        c = double(rand(n,1)>=(1-p.pin)); % random activation
        c(1:k) = 0; % Don't activate training neurons
        cdyn(:,i) = c>0;
        
        % Training neuron input
        b = bdyn(:,i);
        
        % Adaptation
        y = oldy + 1/p.tau*(-oldy+oldx);
        
        % Neural activity.  beta = inh, alpha = adaptation
        %         inhscaling = 10; %10 %***
        r = max(0,w*oldx + b - p.beta*sum(oldx)/k - sum(w,2)/Wmax - p.alpha*y); %*** works
        % r = max(0,w*oldx + b - p.beta*sum(oldx)/k*(1+p.inhscaling*sum(w,2)/Wmax)- p.alpha*y);
        % temp = (sum(r)-r)/(nnz(r)-1); % Average of all the other neurons that are active
        temp = mean(r(r>0)); %*** Average of all feedforward activity
        x = r - p.gamma*temp > 0;
        
        % Random failures
        x(rand(size(x))>(p.psuccess + (1-p.psuccess)*r/Wmax)) = 0;
        
        % Absolute control over random neurons
        x(c>0)=1; %***
        
        % Absolute control over training neurons
        x(b>0)=1;
        x(b<0)=0;
        
        % STDP rule (Fiete et al 2010)
        dw = eta*(x*double(oldx)'-double(oldx)*x');
        
%         dw = eta*(w/wmax+1).*(x*double(oldx)'-double(oldx)*x');
                % This version gives advantage to already-strong weights,
                % to encourage weights going all the way to 1 (WTA)
                                
        % Hetersynaptic LTD  (Fiete et al 2010)
        dw2 = ones(n,1)*max(0, sum(w+dw,1)-Wmax);  % Weights leaving cells (pre)
        dw3 = max(0, sum(w+dw,2)-Wmax)*ones(1,n);  % Weights onto cells (post)
        
        % Update weights
        % eta = learning rate, epsilon = penalty rate. Hard bounds [0 wmax]
        dwtotal = dw-eta*p.epsilon*(dw2+dw3);
        w = min(wmax, max(0, w + dwtotal - eye(n)*10000*wmax));
        
        oldx = x;
        oldy = y;
        xdyn(:,i)=x;
    end
    
    %% For plotting: run without noise
    oldx = zeros(n,1);
    oldy = zeros(n,1);
    xdynclean = zeros(n,nsteps);
    for i = 1:nsteps
        % Adaptation
        y = oldy + 1/p.tau*(-oldy+oldx);
        % Neural activity
        
        r = max(0,w*oldx + bdyn(:,i)*k - p.beta*sum(oldx)/k - sum(w,2)/Wmax - p.alpha*y); %*** works
%         r = max(0,w*oldx + bdyn(:,i)*k - p.beta*sum(oldx)/k*(1+p.inhscaling*sum(w,2)/Wmax) - p.alpha*y); %*** works
        %         temp = (sum(r)-r)/(nnz(r)-1); % Average of all the other neurons that are active
        temp = mean(r(r>0)); %*** Average of all feedforward activity
        x = r - p.gamma*temp > 0;
        
        x(bdyn(:,i)>0) = 1;
        
        oldx = x;
        oldy = y;
        xdynclean(:,i) = x;
    end
    
    %% Sort the weight matrix based on activity for plotting
    % Preserve training neurons at the top
    [~, ind] = sortrows(xdynclean((k+1:end),:)); ind = flipud(ind);
    ind = [1:k ind'+k];

    if p.split                 % Don't rearrange W further after split
        xsort = xdyn;
        wsort = w;
        xdyncleansort = xdynclean;
    else
        xsort = xdyn(ind, :);
        wsort = w(ind, ind);
        xdyncleansort = xdynclean(ind,:);
    end
    
    xdyn_temp = xsort;
    xdyn_temp(cdyn) = .5;
    
    xdynplot = cat(3,1-xdyn_temp, 1-xdyn_temp,1-xdyn_temp);
    xdynplot(1:k,:,1) = 1; % Color top row red
    %     xdynplot(cdyn>0,
%     diagnosticplot
    %% Plotting
    if iter==1
        figure(1); clf
        set(gcf,'WindowStyle','docked')
        s(1)=subplot(2,2,1);
        h1 = imagesc(wsort,[0,wmax]); colormap(hot);axis square;
        xlabel('Neuron (pre)'); ylabel('Neuron (post)');box off
        set(gca,'XTick',[1 n],'YTick',[1 n])
        s(3)=subplot(2,2,3);
        bincenters = linspace(0,wmax);
        ymax = n*m; %y lim for plot
        yhist = hist(w(:),bincenters,'k'); yhist(yhist>ymax) = ymax;
        h3 = bar(bincenters, yhist,1,'k');
        ylim([0 ymax]); xlim([-bincenters(2)/2 wmax]);
        xlabel('Synapse strength'); ylabel('Count'); box off; hold on
        set(gca,'YTick',[0 ymax])
        
%         subplot(2,2,2);
%         box off; axis off
        
        s(4)=subplot(2,2,4);
        h4 = imagesc(xdynplot);
        xlabel('Time (au)');ylabel('Neuron'); box off
        set(gca,'YTick',[1 n],'XTick',[1 50:50:nsteps])
        
        set(findall(gcf,'-property','FontSize'),'FontSize',12)
        subplot(2,2,2);
        set(findall(gca,'-property','FontSize'),'FontSize',2)

        set(gcf,'UserData',0,'WindowButtonDownFcn', 'set(gcf,''UserData'',1)')
    else % faster plotting
        if get(gcf,'UserData'); return; end % Stop on click
        figure(1);
        set(h1,'CData',wsort);
        
        yhist = hist(w(:),bincenters,'k');  yhist(yhist>ymax) = ymax;
        set(h3,'YData',yhist);
        subplot(2,2,3)
        title(sprintf('W (iter = %d)',iter))

        
        set(h4,'CData',xdynplot);
    end
    
    %% Draw connectivity graph
    subplot(2,2,2)
    groupings = graphSplit(w, xdynclean,k,wmax);
    drawnow;
    
    if ~isempty(p.recordvid)
        frame = getframe(gcf);
        slowrate = 4;
        for l = 1:slowrate
            writeVideo(writerobj,frame);
        end
    end
end

if p.recordvid
    close(writerobj);
end
