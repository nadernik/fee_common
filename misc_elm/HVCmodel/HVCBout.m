function [w xdyn] = HVCBout(p)
% Runs one iteration (bout) of the simulation.  p is a structure of parameters.
% See RunHVC_split for parameter definitions
%
% Emily Mackevicius 12/10/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

% redefining params that are used often outside the for loop
nsteps = p.nsteps;
n = p.n;
m = p.m;
w = p.w; 
wmax = p.wmax;
Wmax = wmax*m; 
eta = p.eta;
bdyn=p.input;
nOnes = ones(n,1);
clampDiagonal = eye(n)*10000*wmax;

% initializing variables
xdyn=zeros(n,nsteps);
oldx = zeros(n,1);
oldy = zeros(n,1);

for i = 1:nsteps
    % input
    b = bdyn(:,i);

    % Adaptation
    y = oldy + 1/p.tau*(-oldy+oldx);

    % Net feedforward input.  beta = inh, alpha = adaptation
    r = (w*oldx + b - p.beta*sum(oldx) - p.alpha*y); 
    r(r<0)=0;
    
    % Binary output
    x = r > p.gamma*sum(r); % only fire if r exceeds recurrent inhibition

    % Absolute control over training neurons
    x(p.trainingInd)=b(p.trainingInd); 

    % STDP rule (Fiete et al 2010)
    dw = eta.*(x*(oldx)'-(oldx)*x');
    
    % Hetersynaptic penalty (Fiete et al 2010)
    dw2 = eta*nOnes*max(0, sum(w+dw,1)-Wmax);  % Weights leaving cells (pre)
    dw3 = eta*max(0, sum(w+dw,2)-Wmax)*nOnes';  % Weights onto cells (post)
    
    % Update weights:  eta = learning rate, epsilon = heterosynaptic penalty rate
    dwtotal = dw-p.epsilon*(dw2+dw3);
    w = min(wmax, max(0, w + dwtotal - clampDiagonal));
    
    oldx = double(x);
    oldy = y;
    xdyn(:,i)=x;
end




