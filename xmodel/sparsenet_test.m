%%
close all
clear all


sn = SparseNet();

sn.nhvc = 100;
sn.nmsn = 100;
sn.niter = 1000;

sn.hvcburstlen = 3;
sn.kernelstd = 1/8;

template = 0.5 * sin(linspace(0,2*pi,sn.nhvc)) + 0.5;

sn.lmanstd    = 0.25 * max(template);
sn.lmanoffset = 2    * sn.lmanstd;
sn.winit      = 1    * sn.lmanstd;
sn.msnthresh  = 1    * sn.winit; % MSN threshold
sn.wLstd      = 0.2; %standard deviation of LMAN weights
sn.istr       = sn.lmanoffset + 2 * sn.lmanstd;

sn.LTPrate = 1e-1;
sn.LTDrate = 5e-2;

sn.init()
sn.template = template;

sn.simulate()

%%
figure
clf
subplot(1,3,1)
sn.wimage(sn.niter)
subplot(1,3,2)
lastsongs = sn.lmanout(:,end-100:end);
learning = mean(lastsongs, 2);
plot(learning)
hold all
plot(sn.template)
%ylim([0, 5])
xlabel('Time (ms)')
ylabel('Pitch')
legend('Learned Song', 'Template')
subplot(1,3,3)
plot(-sum(sn.rexp, 1))
xlabel('Trial')
ylabel('Mean squared error')