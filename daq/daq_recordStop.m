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
nChan = numel(channels);
matchannels = nan(1,nChan);
for chanNo = 1:nChan
    matchannels(chanNo) = find(GINCHANS == channels(chanNo));
end
bStatus = false(nChan, 1);
for chanNo = 1:nChan
    if BTRIGGER(matchannels(chanNo)) && TRIGGEREND(matchannels(chanNo))==-2 %channel is recording and has been set to open ended
        TRIGGEREND(matchannels(chanNo)) = endSamp;
        bStatus(chanNo) = true;
    else
        warning(['Record stop failed for channel number ', num2str(channels(chanNo))]);
        bStatus(chanNo) = false;
    end
end