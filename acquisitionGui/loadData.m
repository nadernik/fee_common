function [data, time, HWChannels, startSamp, timeCreated, startTime, names, values, info] = loadData(exper,num,chan,whichSamples)
%LOADDATA Loads data from acquisitionGui exper
%
%Syntax:
%  [data, time, HWChannels, ...
%   startSamp, timeCreated, ...
%   startTime, names, ...
%   values, info]               = loadData(exper, num, chan, whichSamples);
% 
%Inputs:
%  exper [struct]
%    exper struct, created by acquisitionGui. This usually comes from a
%    call to LOADEXPER
%  num [1x1 double]
%    File number to load.
%  chan [1x1 double]
%    Channel number to load.
%  whichSamples [1x2 double]
%    OPTIONAL: 
%Outputs:
%  data [Nx1 double]
%    the raw data
%  time [1x15 double]
%    Time information
%      time(1:6)  = time of first sample in data, in DATEVEC format
%      time(7:12) = time the data file was created, in DATEVEC format
%      time(13)   = 
%      time(14)   =
%      time(15)   =
%  HWChannels [1x1 double]
%    DAQ Channel on which the data was recorded.
%  startSamp [1x1 double]
%    The sample number of the first sample in the file, with 1
%    being the first sample since data acquisition start.
%  timeCreated [1x15 char]
%    Time the data file was created, in format YYYYMMDDTHHMMSS. Might not 
%    be accurate.
%  startTime [1x1 double]
%    The absolute time the file began recording in matlab time...
%    based on the sample number and the time data acquisition began, for
%    older file formates startTime is just a copy of timeCreated.
%  names [Mx1 cell]
%  values [Mx1 cell]
%  info [1x1 struct]
%    Miscellaneous information about the file. The sampling frequency is in
%    info.fs
%
%See also: LOADEXPER, LOADAUDIO

if(~exist('whichSamples','var'))
    whichSamples = [];
end

filename = getExperDatafile(exper,num,chan);
if(~strcmp(filename,''))
    timeCreated = extractDatafileTime(exper,filename);
    
    %old
    %[HWChannels, data, time, startSamp, names, values, trigFileFormat] = daq_readDatafile([exper.dir,filename],false, whichSamples);
    
    %new
    [data, info] = daq_readDatafile(fullfile(exper.dir,filename),true, whichSamples);
    HWChannels = info.daqchannels;
    time = [datevec(info.absStartTime - (info.startSampleNum/(info.fs*60*60*24))), ...
            datevec(convertExperTimeStr2MatlabTime(timeCreated)), ...
            info.startSampleNum/info.fs, (info.startSampleNum+info.numSamples-1)/info.fs, ...
            info.startSampleNum+info.numSamples-1];           
    startSamp = info.startSampleNum;
    names = info.propertyNames;
    values = info.propertyValues;
    trigFileFormat = info.trigFileFormat;
    
    if(trigFileFormat <= -3)
        startTime = datenum(time(1:6)) + time(13)/(24*60*60);
    else
        startTime = datenum(timeCreated,'yyyymmddTHHMMSS');
    end
else
    data = [];
    time = [];
    HWChannels = [];
    startSamp = [];
    timeCreated = '';
    startTime = [];
    names = {};
    values = {};
end