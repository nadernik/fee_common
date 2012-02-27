for m = 1:msn_units
    plot(msn_output(m,:,end))
    hold all
    above = msn_output(m,:,end) > msn_burst_activity_threshold;
    plot(above)
    hold off
    title(['msn unit ' int2str(m) ' is above threshold at ' int2str(sum(above)) ' timesteps'])
    ylim([0 1.1])
    pause
end
