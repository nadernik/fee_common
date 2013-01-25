%%
close all
clear all

sn = SparseNet();

sn.nhvc = 100;
sn.nmsn = 200;
sn.niter = 4000;

sn.hvcburstlen = 15; % set to 3 for hvc bursts to be impulses
sn.kernelstd = 8; % set to 1/8 for instantaneous rewards

% Choose maximum template value = 1.
template = 0.5 * sin(linspace(0,2*pi,sn.nhvc)) + 0.5;


% Choose LMAN fluctuations to have standard deviation = 1/4 of template
sn.lmanstd    = 0.1 * max(template);
sn.lmanoffset = 2    * sn.lmanstd;
sn.winit      = 1    * sn.lmanstd;
sn.msnthresh  = 1    * sn.winit; % MSN threshold
sn.wLstd      = 0.2; %standard deviation of LMAN weights
sn.istr       = sn.lmanoffset + 1.5 * sn.lmanstd;
sn.latinhib   = 6; % down from 3

sn.LTPrate = 0.8; % down from 2e-1 with lateral inhibition of 3
sn.LTDrate = 0.1;

sn.pinhib = 0.75;

sn.init()
sn.template = template;
% sn.wH = diag(max(0,sn.template-sn.lmanoffset + sn.msnthresh)); %FIXME

sn.simulate()

y = [repmat([-1, -1, -1, 1 1 1], 1, 400) repmat([-1, -1, 1 1], 1, 200), repmat([-1, 1], 1, 200)];
sound(y)
%%
figure
for iter = 126:sn.niter
subplot(1,3,1)
sn.wimage(iter)
subplot(1,3,2)
sn.plotbiasvstemplate(iter)
title(int2str(iter))
subplot(1,3,3)
if iter == 1
    sn.plotmse();
end
drawnow
end