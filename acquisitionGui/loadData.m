function [data, time, HWChannels, startSamp, timeCreated, startTime, names, values, info] = loadData(exper,num,chan,whichSamples)
%Find datafile num in the appropriate experiment folder.  Then open it.
%Num is the number of the datafile to load.
%Chan is the HWChannel number to be loaded.
%data - the raw data
%time - a vector containing various time information about the file.
%startSamp - the sample number of the first sample in the file, with 1
%   being the first sample since data acquisition start.
%timeCreated - the time stored in the filename of the file... not accurate.
%startTime - the absolute time the file began recording in matlab time...
%   based on the sample number and the time data acquisition began, for
%   older file formates startTime is just a copy of timeCreated.

if(~exist('whichSamples','var'))
    whichSamples = [];
end

filename = getExperDatafile(exper,num,chan);
if(~strcmp(filename,''))
    timeCreated = extractDatafileTime(exper,filename);
    
    %old
    %[HWChannels, data, time, startSamp, names, values, trigFileFormat] = daq_readDatafile([exper.dir,filename],false, whichSamples);
    
    %new
    [data, info] = daq_readDatafile([exper.dir,filename],true, whichSamples);
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