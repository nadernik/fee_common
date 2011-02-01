function absBoutStartTimes = aSAP_getAbsBoutTimesFromSumm(singingSumm)

absBoutStartTimes = 0;
for(nFile = 1:length(singingSumm.fileinfo))
    fileSumm = singingSumm.fileinfo(nFile);
    absBoutStartTimes = [absBoutStartTimes, fileSumm.rawSyllStartTimesAbs(fileSumm.boutStartSyll)];
end

absBoutStartTimes = absBoutStartTimes(find(absBoutStartTimes~=0));
