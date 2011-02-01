function [aiStartTime, aoStartTime] = daq_StartConstOutput(outputSig)
%Start DAQ such that a repeating constant output signal is generated.
%See daq_Start

%outputSig: the signal to be repeated over and over on the output channels.
%   It should have as many columns a output channels.

global GAO
global GOUTCHANS;

if(size(outputSig,2) ~= length(GOUTCHANS))
    error('outputSig needs to have as many columns as there are output channels. (at least as currently coded)');
end

%Repeat output signal to reduce frequency of call to qmoredata.  This code
%ensures that qmoredata is not called at more than 1 Hz.
actOutSampleRate = get(GAO,'SampleRate');
extendedOutSig = repmat(outputSig, ceil(actOutSampleRate/size(outputSig,1)),1);

%Set up the output channels to repeat a signal over and over.
set(ao,'SamplesOutputFcn',{'qmoredata',ai,extendedOutSig})
set(ao,'SamplesOutputFcnCount',size(extendedOutSig,1))

if(get(ao,'SamplesOutputFcnCount') ~= size(extendedOutSig,1))
    error('The SamplesOutputFcnCount was not set correctly.');
end
    
%Begin by cueing several copies of the outputSig to ensure the output queue never
%empties, even if the call to qmoredata is late.
putdata(ao, repmat(extendedOutSig, 10, 1));

[aiStartTime, aoStartTime] = daq_Start;