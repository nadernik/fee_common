% %% Run with good parameters
close all
clear all
sn = SparseNet();
sn.niter = 200;
sn.tinhib = 6;
sn.LTPrate = 5e-4%1e-3;
sn.LTDrate = 1e-3%1e-4;
sn.winit = 10;
sn.istr = 1;
sn.nhvc = 10;
sn.nmsn = 20;
sn.init()
sn.simulate()

clf
subplot(1,3,1)
sn.wimage
subplot(1,3,2)
lastsongs = sn.lmanout(:,end-100:end);
learning = mean(lastsongs, 2);
plot(learning)
hold all
plot(sn.template)
ylim([0, 40])
xlabel('Time (ms)')
ylabel('Pitch')
legend('Learned Song', 'Template')
subplot(1,3,3)
plot(-sum(sn.rexp, 1))
xlabel('Trial')
ylabel('Mean squared error')