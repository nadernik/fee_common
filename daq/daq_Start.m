function [aiStartTime, aoStartTime] = daq_Start()
%This function starts data collections, and begins output if any has been
%specified.  daq_Init must be called prior to calling daq_Start.

global GINCHANS
global GOUTCHANS
global GAI
global GAO

%Start the daq
if(length(GINCHANS) > 0)
    start(GAI);
    pause(1);
end

if(length(GOUTCHANS) > 0)
    if(get(GAO,'SamplesAvailable') > 0)
        start(GAO);
        pause(1);
    end
end

if(length(GINCHANS) > 0)
    trigger([GAI]);
    aiStartTime = GAI.initialTriggerTime;
else
    aiStartTime = -1;
end

if(length(GOUTCHANS) > 0)
    if(get(GAO,'SamplesAvailable') > 0)
        trigger([GAO]);
        aoStartTime = GAO.initialTriggerTime;
    else
        aoStartTime = -1;
    end
else
    aoStartTime = -1;
end
