function competition_makes_selectivity(do_simulations)

if ~exist('do_simulations', 'var')
    do_simulations = false;
end

%%
if do_simulations
    %% Make data with competition
    clear all
    sparsemodel_parameters
    inhibition_strength = 0;
    sparsemodel_initialize
    sparsemodel_run
    save('c:\stetner\data\figures\xmodel\competition.mat')

    %% Make data without competition
    clear all
    sparsemodel_parameters
    inhibition_strength = 0;
    competition_strength = 0; % turn off competition
    msn_learning_rate = msn_learning_rate/10;
    sparsemodel_initialize
    sparsemodel_run
    save('c:\stetner\data\figures\xmodel\nocompetition.mat')
end

%%
clear all;
comp = load('c:\stetner\data\figures\xmodel\competition.mat', ...
    'weights_on_msn_from_hvc', 'msn_units', 'hvc_units', 'bias', ...
    'template');
nocomp = load('c:\stetner\data\figures\xmodel\nocompetition.mat', ...
    'weights_on_msn_from_hvc', 'msn_units', 'hvc_units', 'bias', ...
    'template');

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
xlabel('HVC')
ylabel('MSN')
title('No Competition')

subplot(2,1,2)
imagesc(comp.weights_on_msn_from_hvc)
xlabel('HVC')
ylabel('MSN')
title('Competition')

%% Learning rates
comp.mse = xmodel_calculate_mse(permute(comp.bias, [3 1 2]), comp.template);
nocomp.mse = xmodel_calculate_mse(permute(nocomp.bias, [3 1 2]), nocomp.template);
figure
plot(comp.mse)
hold all
plot(nocomp.mse)
legend({'Competition', 'No competition'})
xlabel('Trials')
ylabel('Mean Squared Error')

return
%% example MSNs overlayed on song and template
msn_example_list = [1 2 3];

figure
plot(template, 'Color', [.6, .6, .6])
hold on
xmodel_calculate_bias
plot(bias, 'Color', 'k')
chsv = rgb2hsv([1 0 0]);
sat = linspace(.5, 1, length(msn_example_list));

for ii = 1:length(msn_example_list)
    m = msn_example_list(ii);
    c = hsv2rgb([chsv(1), sat(ii), chsv(3)]);
    plot(msn_output(m,:,end), 'Color', c)
end