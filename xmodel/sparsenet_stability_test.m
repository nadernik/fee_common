%%
% Set initial conditions to the weights from a stored simulation and see
% if the model is stable.
close all
clear all

old = load('c:\stetner\data\xmodel\hardwired.mat');

sn = SparseNet();
sn.MICHALE_IS_WATCHING = true;
sn.niter = 600;

% Copy parameters from old simulation
sn.nhvc        = old.sn.nhvc;
sn.nmsn        = old.sn.nmsn;
sn.hvcburstlen = old.sn.hvcburstlen;
sn.kernelstd   = old.sn.kernelstd;
sn.lmanstd     = old.sn.lmanstd;
sn.lmanoffset  = old.sn.lmanoffset;
sn.winit       = old.sn.winit;
sn.wLstd       = old.sn.wLstd;
sn.template    = old.sn.template;

% Set some parameters differently
sn.msnthresh = 1 * sn.winit;
sn.latinhib  = 1.5;
sn.LTPrate   = 0.3;
sn.LTDrate   = 0.0001;
sn.pinhib    = 1;

% Initialize
sn.init()
% w = old.sn.wH(:,:,end);
% assert(old.sn.msnthresh == 0)
% w(w>0) = w(w>0) + sn.msnthresh;
sn.wH(:,:,1) = old.sn.wH(:,:,end);
sn.rexp(:,1) = -abs(sn.bias(1) - sn.template);
sn.wL = old.sn.wL;

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