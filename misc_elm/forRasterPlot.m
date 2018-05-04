function [plotX plotY] = forRasterPlot(spiketimes, boutnums)
spiketimes = spiketimes(:); 
boutnums = boutnums(:); 
nSpks = length(spiketimes); 

plotX = [spiketimes spiketimes nan(nSpks,1)]'; 
plotX = plotX(:); 
plotY = [boutnums boutnums+1 nan(nSpks,1)]'; 
plotY = plotY(:); 