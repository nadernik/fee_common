function figure_inhibition(do_simulations)

file_yes_inhib = 'c:\stetner\data\figures\xmodel\inhibition_yes.mat';
file_no_inhib  = 'c:\stetner\data\figures\xmodel\inhibition_no.mat';
msns_to_plot = [50, 100, 200];
bins = -5:.5:0; % bin centers for 

%% Do simulations if requested (skip by default)
if exist('do_simulations', 'var') && (do_simulations == 1)

    % Simulate with inhibition
    sparsemodel_parameters
    assert(inhibition_strength > 0) %Make sure there is inhibition!
    sparsemodel_initialize
    sparsemodel_run
    save(file_yes_inhib)
    
    % Simulate without inhibition
    sparsemodel_parameters
    inhibition_strength = 0; %Turn off inhibition!
    sparsemodel_initialize
    sparsemodel_run
    save(file_no_inhib)
end

%% Load results

vars_to_load = {'msn_output', 'weights_on_msn_from_hvc', 'template', 'bias'};

inhib = load(file_yes_inhib, vars_to_load{:});
noinhib = load(file_no_inhib, vars_to_load{:});

%% Image of weights with and without inhibition
figure
subplot(1,2,1)
weightimage(inhib)
title('With Inhibition')
subplot(1,2,2)
weightimage(noinhib)
title('No Inhibition')

%% Template, bias, and example MSN activity
figure
subplot(1,2,1)
msn_examples(inhib, msns_to_plot)
title('With Inhibition')
subplot(1,2,2)
msn_examples(noinhib, msns_to_plot)
title('No Inhibition')

%% Selectivity histogram with and without inhibition
figure
sel_inhib   = selectivity(  inhib.weights_on_msn_from_hvc');
sel_noinhib = selectivity(noinhib.weights_on_msn_from_hvc');
p_inhib   = hist(sel_inhib,   bins) / length(sel_inhib);
p_noinhib = hist(sel_noinhib, bins) / length(sel_noinhib);
stairs(bins, p_inhib, '-k', 'LineWidth', 3)
hold on
stairs(bins, p_noinhib, ':k', 'LineWidth', 3)
hold off
xlabel('Selectivity')
ylabel('Probability')

%% Sparseness histogram with and without inhibition
figure
spa_inhib   = sparseness(  inhib.weights_on_msn_from_hvc');
spa_noinhib = sparseness(noinhib.weights_on_msn_from_hvc');
p_inhib   = hist(spa_inhib,   bins) / length(spa_inhib);
p_noinhib = hist(spa_noinhib, bins) / length(spa_noinhib);
stairs(bins, p_inhib, '-k', 'LineWidth', 3)
hold on
stairs(bins, p_noinhib, ':k', 'LineWidth', 3)
hold off
xlabel('Sparseness')
ylabel('Probability')