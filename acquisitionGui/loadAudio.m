function [audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,num,whichSamples)
%Find datafile num in the appropriate experiment folder.  Then open it.

if(~exist('whichSamples','var'))
    whichSamples = [];
end

[audio, time, HWChannels, startSamp, timeFileCreated, startTime, names, values, info] = loadData(exper,num,exper.audioCh,whichSamples);
