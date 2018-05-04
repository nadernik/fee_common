function [w xdyn] = HVCBout(varargin)
% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

p = inputParser;
addParamValue(p,'n',80);            % n neurons
addParamValue(p,'m',8);             % desired number of synapses per neuron (wmax = Wmax/m)
addParamValue(p,'alpha',30);        % strength of neural adaptation
addParamValue(p,'beta',0.1);      % global inhibition strength
addParamValue(p,'eta',.025);         % learning rate parameter
addParamValue(p,'epsilon',.1);      % relative strength of heterosynaptic LTD
addParamValue(p,'tau',4);           % time-constant of neural adaptation (only used if alpha is not 0)
addParamValue(p,'wmax',1);          % single synapse hard bound
addParamValue(p,'pn',.01);          % probability of external stimulation of at least one neuron at any time
addParamValue(p,'w',[]);            % Initial weight matrix (random if blank)
addParamValue(p,'input', []);       % none if blank
addParamValue(p,'gamma',.1);        % for splitting, if gamma=1 then neurons will only fire if they are activated more than average compared to other active neurons. 0 = normal rule
addParamValue(p,'nsteps',80);       % time-steps to simulate -- each time-step is 1 burst duration.
addParamValue(p,'trainingInd',1:8); % index of training neurons


parse(p,varargin{:}); p = p.Results;

nsteps = p.nsteps;
n = p.n;
m = p.m;
w = p.w; 
wmax = p.wmax;
Wmax = wmax*m; 
eta = p.eta;


xdyn=zeros(n,nsteps);
bdyn=p.input;

oldx = zeros(n,1);
oldy = zeros(n,1);

for i = 1:nsteps
    % input
    b = bdyn(:,i);

    % Adaptation
    y = oldy + 1/p.tau*(-oldy+oldx);

    % Neural activity.  beta = inh, alpha = adaptation
    r = (w*oldx + b - p.beta*sum(oldx) - p.alpha*y); 
    %inhscaling = 20; r = max(0,w*oldx + b - p.beta*sum(oldx)*(1+inhscaling*sum(w,2)/Wmax)- p.alpha*y); 
    
    q = sum(r>0); 
    temp = mean(r(r>0)); % Average of all feedforward activity
    x = r > p.gamma*temp; % only fire if r exceeds average r*gamma
    [q temp]

    % Absolute control over training neurons
    x(p.trainingInd)=b(p.trainingInd); 

    % STDP rule (Fiete et al 2010)
    dw = p.eta.*(x*double(oldx)'-double(oldx)*x');%dw = p.eta*(w/wmax+.001).*(x*double(oldx)'-double(oldx)*x');
    % Alternatively: dw = eta*(x*double(oldx)'-double(oldx)*x');
    
    
    % Hetersynaptic penalty 
    dw2 = eta*ones(n,1)*max(0, sum(w+dw,1)-Wmax);  % Weights leaving cells (pre)
    dw3 = eta*max(0, sum(w+dw,2)-Wmax)*ones(1,n);  % Weights onto cells (post)
    
    % Update weights:  eta = learning rate, epsilon = penalty rate
    dwtotal = dw-p.epsilon*(dw2+dw3);
    w = min(wmax, max(0, w + dwtotal - eye(n)*10000*wmax));
    
    oldx = x;
    oldy = y;
    xdyn(:,i)=x;
end

%5




