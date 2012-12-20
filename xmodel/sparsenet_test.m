%%
close all
clear all
%%
snew = SparseNet();

snew.nhvc = 100;
snew.nmsn = 100;
snew.niter = 2000;

snew.LTPrate = 1e-2;
snew.LTDrate = 1e-5;
snew.tinhib = .6;
snew.winit = 0.005;

snew.init()
snew.simulate()

%%
sold = SparseNet();

sold.nhvc = 100;
sold.nmsn = 100;
sold.niter = 2000;

sold.LTPrate = 1e-1;
sold.LTDrate = 1e-2;
sold.tinhib = 1;
sold.tinhib2 = 1;
sold.winit = 0.5;

sold.init()
sold.simulate()


%%
snew = SparseNet();

snew.nhvc = 100;
snew.nmsn = 100;
snew.niter = 2000;

snew.LTPrate = 1e-2;
snew.LTDrate = 1e-4;
snew.tinhib = 0;
snew.winit = 0.5;

snew.init()
snew.template = snew.template + 29;
snew.simulate()

sn =snew;
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