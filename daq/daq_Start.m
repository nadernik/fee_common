function [aiStartTime, aoStartTime] = daq_Start()
%This function starts data collections, and begins output if any has been
%specified.  daq_Init must be called prior to calling daq_Start.
global GS
global GINCHANS
global GOUTCHANS
% global GAI
% global GAO
assert(~isempty(GS), 'daq_Init failed');
hasIn = ~empty(GINCHANS);
hasOut = ~empty(GOUTCHANS);
%Start the daq

if hasIn || hasOut
    startBackground(GS);
    pause(1);
end

% if(length(GOUTCHANS) > 0)
%     if(get(GAO,'SamplesAvailable') > 0)
%         start(GAO);
%         pause(1);
%     end
% end
%% I don't know how to get the first sample time!
aiStartTime = -1;
aoStartTime = -1;
% if(length(GINCHANS) > 0)
%     trigger([GAI]);
%     aiStartTime = GAI.initialTriggerTime;
% else
%     aiStartTime = -1;
% end

% if(length(GOUTCHANS) > 0)
%     if(get(GAO,'SamplesAvailable') > 0)
%         trigger([GAO]);
%         aoStartTime = GAO.initialTriggerTime;
%     else
%         aoStartTime = -1;
%     end
% else
%     aoStartTime = -1;
% end
