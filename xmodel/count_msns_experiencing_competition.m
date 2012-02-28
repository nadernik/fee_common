in_comp = zeros(msn_units,1);
for m = 1:msn_units
    [t1, t2] = detectThresholdCrossings(msn_output(m,:,1), msn_burst_activity_threshold);
    length_of_bursts = t2-t1;
    number_of_bursts = length(t1);
    % If this unit has more than one burst, or if any of its bursts are
    % too long, then it is too active. We should decrease its synaptic
    % weights.
    in_comp(m) = number_of_bursts > 1 || any(length_of_bursts > msn_burst_time_threshold);
end
fprintf('Total MSN units in competition: %g of %g\n', sum(in_comp), msn_units)