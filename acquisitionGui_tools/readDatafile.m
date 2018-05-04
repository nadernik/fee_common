function [data, time, HWChannels, startSamp, timeCreated, names, values] = readDatafile(exper,num,chan)
%Find datafile num in the appropriate experiment folder.  Then open it.

filename = getExperDatafile(exper,num,chan);
timeCreated = extractDatafileTime(exper,filename);
[HWChannels, data, time, startSamp, names, values] = daq_readDatafile([exper.dir,filename]);