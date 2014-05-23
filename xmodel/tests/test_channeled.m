% Test of SparseNetChanneled.m

clear all
sn = SparseNetChanneled;

%%
sn.nvocal = 1;
sn.nhvc = 100;
sn.niter = 2;

sn.hvcburstlen = 11;
sn.template = zeros(sn.nvocal, sn.nhvc);

sn.nlman = 2 * sn.nvocal;
sn.nmsn = sn.nlman * sn.nhvc;

sn.init()
%% check wiring from LMAN to MSN
% each LMAN unit is connected to exactly sn.nhvc MSNs and those MSNs are 
% connected one-to-one with all HVC units.

% each MSN is only connected to one LMAN
lmans_per_msn = sum(sn.wL, 2);
assert(all(lmans_per_msn == 1));

% each LMAN is connected to exactly sn.nhvc MSNs
msns_per_lman = sum(sn.wL, 1);
assert(all(msns_per_lman == sn.nhvc));

% in each channel, msns are connected one-to-one with all hvc units
for ilman = 1:sn.nlman
    imsn = sn.wL(:,ilman) > 0;
    w = sn.wH(imsn,:,1);
    assert(all(all(rref(w) == eye(sn.nhvc))))
end
    

%% test learning
sn.template = 10 * sin(linspace(0,2*pi,sn.nhvc));
sn.niter = 1000;
sn.msnthresh = 0;
sn.LTPrate = 1e-2;
sn.init
sn.simulate
%%
figure(1)
clf
subplot(1,3,1)
plot(sn.bias(sn.niter))
hold all
plot(sn.template)
legend({'Bias', 'Template'})
subplot(1,3,2)
imagesc(sn.wH(:,:,sn.niter))
ylabel('MSN unit')
xlabel('HVC unit')
title('Weight matrix')
subplot(1,3,3)
mse = zeros(1,sn.niter);
for iter = 1:sn.niter
    e = sn.bias(iter) - sn.template;
    mse(iter) = mean(e.^2);
end
plot(mse)
xlabel('Trial')
ylabel('MSE')