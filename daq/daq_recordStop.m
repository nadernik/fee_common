function [bStatus, endSamp] = daq_recordStop(endSamp, channels)
%Stops recording on the specified channels.  endSamp specifies the last
%sample to be included in the file.  Note that if endSamp proceeds the most
%recent sample added to the buffer (see daq_getCurrSampNum), then the file
%will contain samples beyond endSamp.

global BTRIGGER;
global TRIGGEREND;
global GINCHANS;

%convert hardware channel numbers into matlab channel indices.
%[junk, matchannels] = intersect(GINCHANS, channels); %intersect function does not preserve order
matchannels = [];
for(i = 1:length(channels))
    matchannels(i) = find(GINCHANS == channels(i));
end

for(i = 1:length(matchannels))
    if(BTRIGGER(matchannels(i)) & TRIGGEREND(matchannels(i))==-2)
        TRIGGEREND(matchannels(i)) = endSamp;
        bStatus(i) = true;
    else
        warning(['Record stop failed for channel number ', num2str(channels(i))]);
        bStatus(i) = false;
    end
end