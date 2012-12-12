%% Parameter tuning
close all
clear all
LTPrate = 7.5e-2;
rates = linspace(0, 1e-1, 20);

allmsnout = zeros(20,10,1e3,length(rates));

for i = 1:length(rates)
    fprintf('Run %g\n', i)
    LTDrate = rates(i);
    sn = SparseNet(LTPrate, LTDrate);
    sn.simulate();
    allmsnout(:,:,:,i) = sn.msnout;
end

%% Parameter tuning (see results)
for i = 1:length(rates)
    for j = 1:size(allmsnout,1)
        image(squeeze(allmsnout(j,:,:,i))' * 64)
        title(sprintf('LTPrate = %g    MSN %g', rates(i), j))
        pause
    end
end

%% Run with good parameters
close all
clear all
LTPrate = 7.5e-2;
LTDrate = 5.0e-3;
sn = SparseNet(LTPrate, LTDrate);
sn.simulate();
for i = 1:sn.nmsn
    sn.msnimage(i)
    pause
end