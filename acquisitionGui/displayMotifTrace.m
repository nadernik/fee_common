function displayMotifTrace(cell,motifNum, bMarkSpikes, bOldMarker, xLimits )

if(~exist('bMarkSpikes'))
    bMarkSpikes = true;
end

if(motifNum>0 & motifNum < length(cell.motifData))
	sampRate = cell.exper.desiredInSampRate;
	marker = cell.motifData{motifNum}.marker;
    if(bOldMarker)
        marker = cell.motifData{motifNum}.oldMarker;
    end
	startTime = -marker / sampRate;
	endTime = startTime + (cell.motifData{motifNum}.ndxStop - cell.motifData{motifNum}.ndxStart)/sampRate; 
	
	sig = cell.motifData{motifNum}.sig;
    sig = real(highPassFilterHack(sig, 2000, 40000));
	plot([1:length(sig)]/sampRate + startTime, sig, 'k');
	if(isfield(cell.motifData{motifNum}, 'spikeNdx') & bMarkSpikes)
        hold on;
        spikeNdx = cell.motifData{motifNum}.spikeNdx;
        plot((spikeNdx - marker)/sampRate, sig(spikeNdx), 'ro');
        hold off;
	end
    if(exist('xLimits'))
        xlim(xLimits);
    else
	    xlim([startTime, endTime]);
    end
end