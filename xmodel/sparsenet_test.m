close all
clear all
Lrate = 0.01;
dmin = .1;
dmax = .11;
dsteps = 20;
d = linspace(dmin, dmax, dsteps);
for id = 1:dsteps
    fprintf('Run %g of %g\n',id,dsteps)
    stdp = -d(id) * ones(1, 21);
    stdp(11) = 1;
    sn = SparseNet(stdp, Lrate);
    sn = sn.simulate();
    nburst = sum(sn.msnout(:,:,end), 2);
    bins = 0:sn.nhvc;
    Y(:,id) = hist(nburst,bins);
end

imagesc(Y)

%%
stdp = -0.1074 * ones(1, 21);
stdp(11) = 1;
sn = SparseNet(stdp, Lrate);
sn = sn.simulate();
sn.wimage();

figure
for i = 1:sn.nmsn
    sn.msnimage(i);
    pause
end