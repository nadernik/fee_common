function variability_vs_drug(birdname, days, targetSyll, targetRegion)

figure(5211)
clf
hold on

for d = 1:length(days)
    timeRanges = [days(d).time_in, days(d).time_out];
    if isnan(timeRanges(1))
        timeRanges(1) = -Inf;
    end
    if isnan(timeRanges(2))
        timeRanges(2) = Inf;
    end
    [pitchTraj, absTime, syllType, dura] = getProcessedPitchTrajectories( ...
        birdname, days(d).expername, ...
        'timeRanges', timeRanges, ...
        'targetSyll', targetSyll, ...
        'targetRegion', targetRegion, ...
        'rootdir', 'c:\stetner\data');
    mean_pitch = cellfun(@mean, pitchTraj);
    std_pitch = cellfun(@std, pitchTraj);
	
	mean_mean_pitch = mean( mean_pitch );
	std_mean_pitch  = std(  mean_pitch );
	mean_std_pitch  = mean( std_pitch ); % aaron's paper, in supplement
	std_std_pitch   = std(  std_pitch );
	
	scatter(d, mean_std_pitch)
	text(d, mean_std_pitch, [days(d).drug ', ' days(d).concentration 'mM'])
end
set(gca, 'XTick', 1:length(days))
date_labels = cellfun(@datestr, days.datenum, repmat({'MM/DD'},size(days)), 'UniformOutput', false);
set(gca, 'XTickLabel', date_labels)