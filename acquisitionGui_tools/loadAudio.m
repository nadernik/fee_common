function [audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,num,whichSamples)
%LOADAUDIO Loads audio from a file in created by acquisitionGui experiment
%
%   Example 1 (full usage):
%       exper = loadExper('birdname', 'expername', 'C:\data');
%       samples_to_load =  % first one second
%       [audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,num,samples_to_load)
%       sound(audio, info.fs)
%
%   Example 2:
%       exper = loadExper('birdname', 'expername', 'C:\data');


if(~exist('whichSamples','var'))
    whichSamples = [];
end

[audio, time, HWChannels, startSamp, timeFileCreated, startTime, names, values, info] = loadData(exper,num,exper.audioCh,whichSamples);
