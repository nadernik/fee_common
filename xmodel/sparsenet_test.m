%%
close all
clear all


sn = SparseNet();

sn.nhvc = 100;
sn.nmsn = 100;
sn.niter = 1000;

sn.hvcburstlen = 3;
sn.kernelstd = 1/8;

% Choose maximum template value = 1.
template = 0.5 * sin(linspace(0,2*pi,sn.nhvc)) + 0.5;


% Choose LMAN fluctuations to have standard deviation = 1/4 of template
sn.lmanstd    = 0.1 * max(template);
sn.lmanoffset = 2    * sn.lmanstd;
sn.winit      = 1    * sn.lmanstd;
sn.msnthresh  = 1    * sn.winit; % MSN threshold
sn.wLstd      = 0.2; %standard deviation of LMAN weights
sn.istr       = sn.lmanoffset + 1.5 * sn.lmanstd;
sn.latinhib   = 1; % down from 3
sn.plearn = 0.1;

sn.LTPrate = 1e-0; % down from 2e-1 with lateral inhibition of 3
sn.LTDrate = 5e-2;

sn.init()
sn.template = template;
% sn.wH = diag(max(0,sn.template-sn.lmanoffset + sn.msnthresh)); %FIXME

sn.simulate()

%%
figure
clf
subplot(1,3,1)
sn.wimage(sn.niter)
subplot(1,3,2)
sn.plotbiasvstemplate(sn.niter)
subplot(1,3,3)
sn.plotmse();