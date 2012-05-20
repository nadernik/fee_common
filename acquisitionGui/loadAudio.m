function [audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,num,whichSamples)
%LOADAUDIO Loads audio from a file in created by acquisitionGui experiment
%
%
%[audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,num,whichSamples)

if(~exist('whichSamples','var'))
    whichSamples = [];
end

[audio, time, HWChannels, startSamp, timeFileCreated, startTime, names, values, info] = loadData(exper,num,exper.audioCh,whichSamples);
