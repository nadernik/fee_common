function [aiStartTime, aoStartTime] = daq_StartConstOutput(outputSig)
%Start DAQ such that a repeating constant output signal is generated.
%See daq_Start
%%I'm not confident about the output code, test before use.
%outputSig: the signal to be repeated over and over on the output channels.
%   It should have as many columns a output channels.

global GS;
global GLISTENERS;
global GOUTCHANS;

%default behavior of session is to call NotifyWhenScansQueuedBelow when
%there is less than half a second of scan data remaining, if the goal is to
%queue more data at only 1Hz, then we need to queue 1.5 seconds of data
targetDataTime = 1.5; %in seconds
if size(outputSig,2) ~= length(GOUTCHANS)
    error('outputSig needs to have as many columns as there are output channels. (at least as currently coded)');
end

%Repeat output signal to reduce frequency of call to qmoredata.  This code
%ensures that qmoredata is not called at more than 1 Hz.
actOutSampleRate = GS.Rate;
extendedOutSig = repmat(outputSig, ceil(targetDataTime*actOutSampleRate/size(outputSig,1)),1);
%Add to signal queue
queueOutputData(GS, extendedOutSig);
%Set up the output channels to repeat a signal over and over.
lho = addlistener(GS, 'DataRequired', @(src, event) daq_qmoredata(src, extendedOutSig));
for lNo = 1:numel(GLISTENERS)%Find existing datarequired listener
    if strcmp(GLISTENERS{lNo}.EventName, 'DataRequired') %Compare event names
        delete(GLISTENERS{lNo}); %delete old listener
        GLISTENERS{lNo} = lho; %replace entry in GLISTENERS with new listener
    end
end
[aiStartTime, aoStartTime] = daq_Start;