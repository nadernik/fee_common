d = load('c:\stetner\data\figures\xmodel\no_competition_nor_inhibition.mat');
d2 = load('c:\stetner\data\figures\xmodel\inhibition_yes.mat');

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
w = [comp.weights_on_msn_from_hvc; nocomp.weights_on_msn_from_hvc]';
f = [repmat({'Competition'},1,comp.msn_units), repmat({'No Competition'},1,nocomp.msn_units)];
slct = selectivity(w);
figure
histbyfactor(f, slct, -4:0.25:0)
xlabel('Selectivity')
ylabel('Number of neurons')

% Sparseness
f = [repmat({'Competition'},1,comp.hvc_units), repmat({'No Competition'},1,nocomp.hvc_units)];
sprs = [sparseness(comp.weights_on_msn_from_hvc'), ...
    sparseness(nocomp.weights_on_msn_from_hvc')];
figure
histbyfactor(f, sprs, -6:0.25:0)
xlabel('Sparseness')
ylabel('Number of HVC bins')






