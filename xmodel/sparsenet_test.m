%%
close all
clear all

sn = SparseNet();

sn.MICHALE_IS_WATCHING = true;

sn.nhvc  =  100;
sn.nmsn  =  300;
sn.niter = 3000;

sn.hvcburstlen = 11; % Width of HVC burst
sn.kernelstd   = 12; % Standard deviation of Gaussian dopamine kernel

maxtemplate   = 1;   % maximum template value (this is arbitrary)

% Derived parameters
sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise
sn.winit      = 0.1  * sn.lmanstd;  % Maximum initial HVC-MSN weight
sn.msnthresh  = 1    * sn.winit;    % Threshold for MSN output

sn.latinhib = 0.0005; % FIXME how does this scale?
sn.LTPrate  = 0.05;   % FIXME how does this scale?
sn.LTDrate  = 2e-6;   % FIXME how does this scale?
sn.pinhib   = 0.75;   % FIXME how does this scale?

a = (maxtemplate - sn.lmanoffset)/2;
b = sn.lmanoffset + a;
t = linspace(0,2*pi,sn.nhvc);
sn.template = a*sin(t) + b;

sn.init()
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