close all
clear all

sn = SparseNet([-.25, -.25, 1, -.25, -.25], 0.005); 
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