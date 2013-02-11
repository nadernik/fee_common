%%
close all
clear all

sn = SparseNet();

sn.MICHALE_IS_WATCHING = true;

sn.nhvc  =  100;
sn.nmsn  =  300;
sn.niter = 3000;

sn.hvcburstlen = 11; % Width of HVC burst
sn.kernelstd   =  0; % Standard deviation of Gaussian dopamine kernel

maxtemplate   = 1;   % maximum template value (this is arbitrary)
sn.wLstd      = 0.1; % standard deviation of LMAN weights

% Derived parameters
sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise
sn.winit      = 0.1  * sn.lmanstd;  % Maximum initial HVC-MSN weight
sn.msnthresh  = 1    * sn.winit;    % Threshold for MSN output
sn.v0offset   = 3    * sn.lmanstd;  % v0 will always be this 

sn.v0decay    = 1e-1; % FIXME how does this scale?

sn.latinhib = 0.0005; % FIXME how does this scale?
sn.LTPrate  = 0.02;   % FIXME how does this scale?
sn.LTDrate  = 2e-6;   % FIXME how does this scale?
sn.pinhib   = 0.75;   % FIXME how does this scale?

% Square template
% sn.template = [zeros(1,20), (ones(1,60)-sn.lmanoffset), zeros(1,20)] + sn.lmanoffset;

% Cosine template
a = (maxtemplate - sn.lmanoffset)/2;
b = sn.lmanoffset + a;
t = linspace(0,4*pi,sn.nhvc);
sn.template = -a*cos(t) + b;

sn.init()
% plot(sn.hvcout(50,:))
% return
sn.simulate()

y = [repmat([-1, -1, -1, 1 1 1], 1, 400) repmat([-1, -1, 1 1], 1, 200), repmat([-1, 1], 1, 200)];
% sound(y)
%%
if ~sn.MICHALE_IS_WATCHING
    iter = sn.niter
    % for iter = 1:sn.niter
    subplot(1,3,1)
    sn.wimage(iter)
    subplot(1,3,2)
    sn.plotbiasvstemplate(iter)
    title(int2str(iter))
    subplot(1,3,3)
    % if iter == 1
    sn.plotmse();
    % end
    % drawnow
    % end
end