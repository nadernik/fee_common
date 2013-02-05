%%
close all
clear all

sn = SparseNet();

sn.MICHALE_IS_WATCHING = true;

sn.nhvc = 100;
sn.nmsn = 100;
sn.niter = 5000;

sn.hvcburstlen = 13; % set to 3 for hvc bursts to be impulses
sn.kernelstd = .125;%8; % set to 1/8 for instantaneous rewards

% Choose maximum template value = 1.
maxtemplate = 1;

% template = [zeros(1,ceil(sn.hvcburstlen/2)), template, zeros(1,floor(sn.hvcburstlen/2))];

% Choose LMAN fluctuations to have standard deviation = 1/4 of template
sn.lmanstd    = 0.05 * maxtemplate;
sn.lmanoffset = 2    * sn.lmanstd;
sn.winit      = 1    * sn.lmanstd;
sn.msnthresh  = 1    * sn.winit; % MSN threshold
sn.wLstd      = 0.2; %standard deviation of LMAN weights

sn.v0offset   = 3    * sn.lmanstd;
sn.v0decay    = 1e-1;

sn.latinhib = 1;
sn.LTPrate  = 0.03;
sn.LTDrate  = 0.0001;
sn.pinhib   = 0.75;

template = [zeros(1,20), (ones(1,60)-sn.lmanoffset), zeros(1,20)] + sn.lmanoffset;
sn.template = template;

sn.init()
sn.simulate()

y = [repmat([-1, -1, -1, 1 1 1], 1, 400) repmat([-1, -1, 1 1], 1, 200), repmat([-1, 1], 1, 200)];
sound(y)
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