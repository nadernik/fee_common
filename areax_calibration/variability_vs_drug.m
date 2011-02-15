function variability_vs_drug(birdname, days, targetSyll, targetRegion)

figure(5211)
clf
hold on

for d = 1:length(days)
    [pitchTraj, absTime, syllType, dura] = getProcessedPitchTrajectories( ...
        birdname, days(d).expername, ...
        'timeRanges', [days(d).], ...
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