%%
close all
clear all

%%
sold = SparseNet();

sold.nhvc = 50;
sold.nmsn = 100;
sold.niter = 600;

sold.LTPrate = 5e-3;
sold.LTDrate = 1e-4;
% sold.tinhib = 1;
sold.tinhib2 = 1;
sold.winit = 0.1;

sold.init()
sold.tonicinhib(:,1) = .9;
sold.simulate()

sn = sold;

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