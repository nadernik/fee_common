close all
clear all

sn = SparseNetHardwired();

sn.MICHALE_IS_WATCHING = false;

sn.nhvc = 100;
sn.nmsn = 200;
sn.niter = 2000;

sn.hvcburstlen = 13;
sn.kernelstd   = 1/8;


maxtemplate = 1;

% Choose LMAN fluctuations to have standard deviation = 1/4 of template
sn.lmanstd    = 0.05 * maxtemplate;
sn.lmanoffset = 2    * sn.lmanstd;
sn.winit      = 1    * sn.lmanstd;
sn.msnthresh  = 1    * sn.winit; % MSN threshold
sn.wLstd      = 0; %standard deviation of LMAN weights

sn.v0offset   = 3    * sn.lmanstd;
sn.v0decay    = 1e-1;
sn.latinhib   = 0;

sn.LTPrate = 4e-2;
sn.LTDrate = 0;

% Choose maximum template value = 1.
A = (maxtemplate - sn.lmanoffset)/2;
sn.template = -A*cos(linspace(0,2*pi,sn.nhvc)) + sn.lmanoffset + A;

sn.init()
plot(sn.template)
sn.simulate()
sn.plotmse()