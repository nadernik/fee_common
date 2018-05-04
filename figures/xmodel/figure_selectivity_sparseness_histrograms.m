% Compare the selectivity and sparseness of MSN population before and after
% learning

bins = -6:0.5:0.5; % bin centers for histogram

selectivity_pre   = selectivity(d.initial_weights');
selectivity_post = selectivity(d.weights_on_msn_from_hvc');

selectivity_pre_probability  = hist(selectivity_pre,  bins) / d.msn_units;
selectivity_post_probability = hist(selectivity_post, bins) / d.msn_units;

sparseness_pre  = sparseness(d0.initial_weights');
sparseness_post = sparseness(d.weights_on_msn_from_hvc');

sparseness_pre_probability  = hist(sparseness_pre,  bins) / d.hvc_units;
sparseness_post_probability = hist(sparseness_post, bins) / d.hvc_units;

figure
subplot(1,2,1)
stairs(bins, selectivity_pre_probability, 'Color', [.7 .7 .7], 'LineWidth', 3)
hold on
stairs(bins, selectivity_post_probability, 'Color', [0 0 0], 'LineWidth', 3)
xlabel('Selectivity')
ylabel('Probability')
legend({'Before learning', 'After learning'})

subplot(1,2,2)
stairs(bins, sparseness_pre_probability, 'Color', [.7 .7 .7], 'LineWidth', 3)
hold on
stairs(bins, sparseness_post_probability, 'Color', [0 0 0], 'LineWidth', 3)
xlabel('Sparseness')
ylabel('Probability')
legend({'Before learning', 'After learning'})