%% Run with good parameters
close all
clear all
LTPrate = 7.5e-3;
LTDrate = 5e-4;
sn = SparseNet(LTPrate, LTDrate);
sn.simulate();
%%
figure
for i = 1:sn.nmsn
    sn.msnimage(i)
    %pause
end

%%
figure
for i = 1:sn.niter
    rpe(:,i) = sn.rpe(i);
end
hist(rpe(:))

%%
figure
lastsongs = squeeze(sum(sn.msnout(:,:,end-100:end), 1)); % time x motif
learning = mean(lastsongs, 2);
plot(learning)
hold all
plot(sn.template)