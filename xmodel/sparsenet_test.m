close all
clear all
stdp = -0.2 * ones(1, 21);
stdp(11) = 1;
sn = SparseNet(stdp, 0.01); 
sn = sn.simulate();

%% Weights
figure(1)
sn.wimage();

%% Sparsness on last motif
figure(2)
numspikes = sum(sn.msnout(:,:,end), 2);
hist(numspikes)

%% Stability
figure(3)
for i = 1:sn.nmsn
    sn.msnimage(i);
    pause
end