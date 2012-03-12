load('c:\stetner\data\sparsemodel\lman_rand_test_5.mat', ...
    'weights_on_msn_from_hvc', 'competing_msns', 'msn_burst_activity_threshold', ...
    'msn_burst_time_threshold', 'msn_output', 'msn_units')

%%
 bins = 0:.02:1;%-5:0.25:0;
% 
% se = selectivity(weights_on_msn_from_hvc');
% 
% counts_competing = hist(se(competing_msns), bins);
% counts_noncompeting = hist(se(~competing_msns), bins);
% 
% stairs(bins, counts_competing, 'LineWidth', 3, 'Color', 'r')
% hold on
% stairs(bins, counts_noncompeting, 'LineWidth', 3, 'Color', 'k')
% hold off
% xlabel('Selectivity')
% ylabel('Number of neurons')
% legend({'Competing', 'Non-competing'}, 'Location', 'northwest')

%%
has_zero_bursts = false(1,msn_units);
has_one_burst = false(1,msn_units);
has_multiple_bursts = false(1,msn_units);
has_long_burst = false(1,msn_units);


for m = 1:msn_units
    [t1, t2] = detectThresholdCrossings(msn_output(m,:,1), msn_burst_activity_threshold);
    length_of_bursts = t2-t1;
    number_of_bursts(m) = length(t1);
    
    if number_of_bursts(m) == 0
        has_zero_bursts(m) = 1;
    end
    
    if number_of_bursts(m) == 1
        has_one_burst(m) = 1;
    end
    
    if number_of_bursts(m) > 1
        has_multiple_bursts(m) = 1;
    end
    
    if any(length_of_bursts > msn_burst_time_threshold)
        has_long_burst(m) = 1;
    end
    
    strongest_synapse_on_msn(m) = max(weights_on_msn_from_hvc(m,:));
end

assert(all(has_zero_bursts | has_one_burst | has_multiple_bursts))

w = weights_on_msn_from_hvc >= msn_burst_activity_threshold;
% m = msn_output(:,:,end) > msn_burst_activity_threshold;
% m = msn_output(:,:,end);
% m(m<msn_burst_activity_threshold) = 0;
% se = selectivity(m');
% se = selectivity_maxovertotal(weights_on_msn_from_hvc');
% se = selectivity_maxovertotal(msn_output(:,:,end)');
se = selectivity_franco(weights_on_msn_from_hvc');

figure
scatter(strongest_synapse_on_msn, se)
xlabel('Strongest synapse')
ylabel('Selectivity')

figure
scatter(number_of_bursts, se)
xlabel('Number of bursts')
ylabel('Selectivity')

figure
counts1 = hist(se(has_one_burst), bins);
counts2 = hist(se(has_multiple_bursts), bins);
stairs(bins, counts1/sum(counts1), 'Color', 'k', 'LineWidth', 3)
hold on
stairs(bins, counts2/sum(counts2), 'Color', 'r', 'LineWidth', 3)
hold off
legend({'1 burst', '2+ bursts'})
xlabel('Selectivity')
ylabel('Number of neurons')

figure
nabove = sum(w,2);
scatter(nabove, se);
xlabel('weights above thresh bursting')
ylabel('Selectivity')

% %%
% wtest = zeros(7,50);
% 
% % uniform low
% wtest(1,:) = 0.02;
% 
% % uniform hi
% wtest(2,:) = 0.1;
% 
% % pulse
% wtest(3,10) = 0.2;
% 
% % pulse high
% wtest(4,10) = 1;
% 
% % two pulses
% wtest(5,10) = 0.2;
% wtest(5,40) = 0.2;
% 
% % pulse with background
% wtest(6,:) = 0.02;
% wtest(6,10) = 0.2;
% 
% % pulse with bigger background
% wtest(7,:) = 0.1;
% wtest(7,10) = 0.2;
% 
% selectivity(wtest')