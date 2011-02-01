function daq_waitForRecording(channels)
%Wait for recordings on a set of channels to be completed before returning.

%channels:  an array of hardward channels numbers.  This set of channels
%will be waited upon.

global BTRIGGER;
global GINCHANS;

if(daq_isUpdating)
    error('daq_waitForRecording function has interrupted daq_bufferUpdate.  This must be prevented.');
end

%Convert hardward channel numbers to matlab channel indices.
matchannels = [];
for(i = 1:length(channels))
    matchannels(i) = find(GINCHANS == channels(i));
end

while(find(BTRIGGER(matchannels)))
    pause(.5);
end