%%
% Set initial conditions to the weights from a stored simulation and see
% if the model is stable.
close all
clear all

old = load('c:\stetner\data\xmodel\hardwired.mat');

sn = SparseNet();
sn.MICHALE_IS_WATCHING = true;
sn.niter = 20;

% Copy parameters from old simulation
sn.nhvc        = old.sn.nhvc;
sn.nmsn        = old.sn.nmsn; % WAS 200!!!!
sn.hvcburstlen = old.sn.hvcburstlen;
sn.kernelstd   = old.sn.kernelstd;
sn.lmanstd     = old.sn.lmanstd;
sn.lmanoffset  = old.sn.lmanoffset;
sn.winit       = old.sn.winit;
sn.msnthresh   = old.sn.msnthresh;
sn.wLstd       = old.sn.wLstd;
sn.v0offset    = old.sn.v0offset;
sn.v0decay     = old.sn.v0decay;
sn.template    = old.sn.template;

% Set some parameters differently
sn.latinhib = 2;
sn.LTPrate  = 0.08;
sn.LTDrate  = 0.01;
sn.pinhib   = 0.75;

% Initialize
sn.init()
sn.wH(:,:,1) = old.sn.wH(:,:,end);
sn.rexp(:,1) = -abs(sn.bias(1) - sn.template);

% 
sn.simulate()

%%
if ~sn.MICHALE_IS_WATCHING
    iter = sn.niter;
    subplot(1,3,1)
    sn.wimage(iter)
    subplot(1,3,2)
    sn.plotbiasvstemplate(iter)
    title(int2str(iter))
    subplot(1,3,3)
    sn.plotmse();
end