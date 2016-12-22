function warpedSpiketimes = TimeWarp_elm(Spiketimes, ActualSegTimes, DesiredSegTimes)
ActualSegTimes = ActualSegTimes'; ActualSegTimes = ActualSegTimes(:); 
DesiredSegTimes = DesiredSegTimes'; DesiredSegTimes = DesiredSegTimes(:); 
% for each segment
for segi = 2:length(ActualSegTimes)
    % find the spikes in that segment
    segStart = ActualSegTimes(segi-1); segEnd = ActualSegTimes(segi);
    newSegStart = DesiredSegTimes(segi-1); newSegEnd = DesiredSegTimes(segi); 
    sInd = Spiketimes>=segStart & Spiketimes<=segEnd; 
    s = Spiketimes(sInd);
    % changed the times
    s = (s - segStart); s = s/(segEnd-segStart); 
    s = s*(newSegEnd-newSegStart); s = s+newSegStart; 
    warpedSpiketimes(sInd) = s; 
end
