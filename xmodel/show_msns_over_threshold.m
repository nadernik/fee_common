
show_only_msns_in_competition = false;

%%
for m = 1:msn_units
    
    [t1, t2] = detectThresholdCrossings(msn_output(m,:,1), msn_burst_activity_threshold);
    length_of_bursts = t2-t1;
    number_of_bursts = length(t1);
    % If this unit has more than one burst, or if any of its bursts are
    % too long, then it is too active. We should decrease its synaptic
    % weights.
    in_comp(m) = number_of_bursts > 1 || any(length_of_bursts > msn_burst_time_threshold);
    
    if ~show_only_msns_in_competition || in_comp(m)
        plot(msn_output(m,:,end))
        hold on
        t = 1:motif_steps;
        is_over = false(1,motif_steps);
        for b = 1:length(t1)
            is_over = is_over | (t >= t1(b) & t <= t2(b));
        end
        Yover = msn_output(m,:,1);
        Yover(~is_over) = nan;
        plot(Yover, 'r', 'LineWidth', 3)
        hold off
        titlestr = sprintf('MSN unit %g has %g bursts', m, number_of_bursts);
        if any(length_of_bursts > msn_burst_time_threshold)
            titlestr = [titlestr ' and a burst is too long!'];
        end
        title(titlestr)
        pause
    end
end
