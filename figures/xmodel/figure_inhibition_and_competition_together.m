%%
sparsemodel_parameters
inhibition_strength = 0; %Turn off inhibition!
lman_rand = 1; % no randomness in LMAN-MSN connection
competition_strength = 0;
sparsemodel_initialize
sparsemodel_run
save('c:\stetner\data\figures\xmodel\all_hvc_to_all_msn_naive.mat')

clear all
sparsemodel_parameters
sparsemodel_initialize
sparsemodel_run
save('c:\stetner\data\figures\xmodel\all_hvc_to_all_msn_smart.mat')

%%
d = load('c:\stetner\data\figures\xmodel\all_hvc_to_all_msn_naive.mat');
d2 = load('c:\stetner\data\figures\xmodel\all_hvc_to_all_msn_smart.mat');
figure
subplot(1,2,1)
weightimage(d)
colorbar
title('No inhibition or competition')
subplot(1,2,2)
weightimage(d2)
colorbar
title('Yes inhibition and competition')

figure
m = [10 60 200];
subplot(1,2,1)
msn_examples(d, m)
title('No inhibition or competition')
subplot(1,2,2)
msn_examples(d2, m)
title('Yes inhibition and competition')

%%
% selectivity index
comp = d2;
nocomp = d;
sel_comp = selectivity(comp.weights_on_msn_from_hvc');
sel_nocomp = selectivity(nocomp.weights_on_msn_from_hvc');
w = [nocomp.weights_on_msn_from_hvc; comp.weights_on_msn_from_hvc]';
f = [repmat({'No Competition'},1,nocomp.msn_units), repmat({'Competition'},1,comp.msn_units)];
slct = selectivity(w) - selectivity(ones(comp.hvc_units,1));
figure
barbyfactor(f, slct)
ylabel('Selectivity')
setticklimy([0, 1])
xlim([0.5, 2.5])

% Sparseness
f = [repmat({'No Competition'},1,nocomp.hvc_units), repmat({'Competition'},1,comp.hvc_units)];
sprs = [sparseness(nocomp.weights_on_msn_from_hvc'), ...
    sparseness(comp.weights_on_msn_from_hvc')];
figure
barbyfactor(f, sprs)
ylabel('Sparseness')
setticklimy([0, 1])
xlim([0.5, 2.5])






