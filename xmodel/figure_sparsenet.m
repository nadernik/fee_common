close all
clear all
datadir = 'c:\stetner\data\sparsenet';


%%
sn = SparseNet();
sn.niter = 5e3;
sn.tinhib = 1;
sn.niter = 5e3;
sn.LTPrate = 3.5e-4;
sn.nmsn = 100;

%%
disp('yes ltd yes inhib')
sn.LTDrate = 1.0e-3;
sn.tinhib = 1;
sn.init()
sn.simulate()
save(fullfile(datadir, 'yesltd_yesinhib.mat'), 'sn');

%%
disp('No ltd yes inhib')
sn.LTDrate = 0;
sn.tinhib = 1;
sn.init()
sn.simulate()
save(fullfile(datadir, 'noltd_yesinhib.mat'), 'sn');

%%
disp('No ltd no inhib')
sn.LTDrate = 0;
sn.tinhib = 0;
sn.init()
sn.simulate()
save(fullfile(datadir, 'noltd_noinhib.mat'), 'sn');

%%
clear sn
load(fullfile(datadir, 'yesltd_yesinhib.mat'), 'sn');
figure(2)
clf
subplot(2,3,1)
sn.wimage
subplot(2,3,2)
lastsongs = sn.lmanout(:,end-100:end);
learning = mean(lastsongs, 2);
plot(learning)
hold all
plot(sn.template)
ylim([0, 40])
xlabel('Time (ms)')
ylabel('Pitch')
legend('Learned Song', 'Template')
subplot(2,3,3)
plot(-sum(sn.rexp, 1))
xlabel('Trial')
ylabel('Mean squared error')

%%
clear sn
load(fullfile(datadir, 'noltd_yesinhib.mat'), 'sn');
subplot(2,3,4)
sn.wimage
subplot(2,3,5)
lastsongs = sn.lmanout(:,end-100:end);
learning = mean(lastsongs, 2);
plot(learning)
hold all
plot(sn.template)
ylim([0, 40])
xlabel('Time (ms)')
ylabel('Pitch')
legend('Learned Song', 'Template')
subplot(2,3,6)
plot(-sum(sn.rexp, 1))
xlabel('Trial')
ylabel('Mean squared error')
