function daq_waitForRecording(channels)
%Wait for recordings on a set of channels to be completed before returning.

%channels:  an array of hardward channels numbers.  This set of channels
%will be waited upon.

global BTRIGGER;
global GINCHANS;

if daq_isUpdating
    error('daq_waitForRecording function has interrupted daq_bufferUpdate.  This must be prevented.');
end

%Convert hardward channel numbers to matlab channel indices.
nChan = numel(channels);
matchannels = nan(1, nChan);
for chanNo = 1:nChan
    matchannels(chanNo) = find(GINCHANS == channels(chanNo));
end

while any(BTRIGGER(matchannels))
    pause(.5);
end