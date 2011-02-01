function displaySpectralDerivativeWithStims(specDeriv, sampAdv, startTime, maxfreq, colorRange, stimTimes, catchTimes, inchPerSec, inchPerkHz)

SAP_displaySpectralDerivative(specDeriv, sampAdv, startTime, maxfreq, colorRange, inchPerSec, inchPerkHz);

l = line([stimTimes,stimTimes]',repmat(ylim',1,length(stimTimes)));
set(l,'color','red');

l = line([catchTimes,catchTimes]',repmat(ylim',1,length(catchTimes)));
set(l,'color','green');