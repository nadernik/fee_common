close all
clear all
sn = SparseNet();
sn.niter = 5e3;
sn.tinhib = 1;
sn.niter = 1000;
sn.LTPrate = 3.5e-4;
sn.nhvc = 100;
sn.nmsn = 500;
sn.LTDrate = 1.0e-3;
sn.tinhib = 1;
sn.init()
sn.simulate()

clf
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