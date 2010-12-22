function displayMotifAudio(cell, motifNum)

if(motifNum>0 & motifNum < length(cell.motifData))
	motifData = cell.motifData{motifNum};
	sampRate = cell.exper.desiredInSampRate;
	marker = cell.motifData{motifNum}.marker;
	startTime = -marker / sampRate;
	endTime = startTime + (motifData.ndxStop - motifData.ndxStart)/sampRate; 
	displayAudioSpecgram(cell.motifData{motifNum}.audio, sampRate, startTime);
	xlim([startTime, endTime]);
end