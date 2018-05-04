function competition_makes_selectivity(do_simulations)

if ~exist('do_simulations', 'var')
    do_simulations = false;
end

%%
if do_simulations
    %% Make data with competition
    clear all
    sparsemodel_parameters
    sparsemodel_initialize
    sparsemodel_run
    save('c:\stetner\data\figures\xmodel\competition.mat')

    %% Make data without competition
    clear all
    sparsemodel_parameters
    competition_strength = 0; % turn off competition
    sparsemodel_initialize
    sparsemodel_run
    save('c:\stetner\data\figures\xmodel\nocompetition.mat')
end

%%
clear all;
comp = load('c:\stetner\data\figures\xmodel\competition.mat', ...
    'weights_on_msn_from_hvc', 'msn_units', 'hvc_units', 'bias', ...
    'template', 'msn_output', 'total_motifs');
nocomp = load('c:\stetner\data\figures\xmodel\nocompetition.mat', ...
    'weights_on_msn_from_hvc', 'msn_units', 'hvc_units', 'bias', ...
    'template', 'msn_output', 'total_motifs');

% distribution of weights
% figure
% weights_lumped = weights_on_msn_from_hvc(:);
% bin_centers = 0:
% counts = hist(weights_lumped, bin_centers);
% probability = counts ./ sum(counts);
% stairs(bin_centers, probability)

% selectivity index
sel_comp = selectivity(comp.weights_on_msn_from_hvc');
sel_nocomp = selectivity(nocomp.weights_on_msn_from_hvc');
w = [comp.weights_on_msn_from_hvc; nocomp.weights_on_msn_from_hvc]';
f = [repmat({'Competition'},1,comp.msn_units), repmat({'No Competition'},1,nocomp.msn_units)];
slct = selectivity(w);
figure
histbyfactor(f, slct, -4:0.25:0)
xlabel('Selectivity')
ylabel('Number of neurons')

f = [repmat({'Competition'},1,comp.hvc_units), repmat({'No Competition'},1,nocomp.hvc_units)];
sprs = [sparseness(comp.weights_on_msn_from_hvc'), ...
    sparseness(nocomp.weights_on_msn_from_hvc')];
figure
histbyfactor(f, sprs, -6:0.25:0)
xlabel('Sparseness')
ylabel('Number of HVC bins')

%% image of weights

figure
subplot(2,1,1)
imagesc(nocomp.weights_on_msn_from_hvc)
colorbar
xlabel('HVC')
ylabel('MSN')
title('No Competition')

subplot(2,1,2)
imagesc(comp.weights_on_msn_from_hvc)
colorbar
xlabel('HVC')
ylabel('MSN')
title('Competition')

%% Learning rates
figure
plotmsebias(comp)
hold all
plotmsebias(nocomp)
legend({'Competition', 'No competition'})

%% example MSNs overlayed on song and template
figure
mlist = [47, 75, 274];
msn_examples(comp, mlist);
figure
mlist = [48, 64, 295];
msn_examples(nocomp, mlist);
end