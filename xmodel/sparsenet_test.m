%%
close all
clear all
%%
sn = SparseNet();
%%
sn.nhvc = 100;
sn.nmsn = 500;
sn.niter = 2000;
%%
sn.LTPrate = 1e-1;
sn.LTDrate = 0;%1e-2;
sn.tinhib = 1;
%%
sn.init()
sn.simulate()
%%
figure
clf
subplot(1,3,1)
sn.wimage
subplot(1,3,2)
lastsongs = sn.lmanout(:,end-100:end);
learning = mean(lastsongs, 2);
plot(learning)
hold all
plot(sn.template)
ylim([0, 5])
xlabel('Time (ms)')
ylabel('Pitch')
legend('Learned Song', 'Template')
subplot(1,3,3)
plot(-sum(sn.rexp, 1))
xlabel('Trial')
ylabel('Mean squared error')