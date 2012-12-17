% %% Run with good parameters
close all
clear all
% sn = SparseNet();
% sn.niter = 5e3;
% sn.tinhib = 1;
datadir = 'c:\stetner\data\sparsenet';
% Prates = logspace(-5, -3, 10);
% Drates = logspace(-5, -3, 10);
% for i = 1:length(Prates)
%     for j = 1:length(Drates)
%         fname = sprintf('tuning_%02.f_%02.f.mat', i, j)
%         sn.LTPrate = Prates(i);
%         sn.LTDrate = Drates(j);
%         sn.init()
%         sn.simulate()
%         save(fullfile(datadir, fname), 'sn')
%     end
% end


i = 8;
j = 10;
fname = sprintf('tuning_%02.f_%02.f.mat', i, j)
load(fullfile(datadir, fname), 'sn')
%%
figure
for i = 1:sn.nmsn
    sn.msnimage(i)
    pause
end

%%
figure
lastsongs = sn.lmanout(:,end-100:end);
learning = mean(lastsongs, 2);
plot(learning)
hold all
plot(sn.template)

%%
figure
for iter = 1:sn.niter
    vp(:,iter) = sn.vpost(1,iter);
end
imagesc(vp)

%%
figure
plot(sum(sn.rexp, 1))

%%
figure
t = 5;
y = squeeze(sn.msnout(:,t,:))' - sn.noise(t,:)'*ones(1,sn.nmsn);
plot(y)

%%
figure
yy = diff(y,[],2);
plot(yy)