classdef (ConstructOnLoad) PeekEvent < event.EventData
   properties
      hwChannels
      data
      timeStamps
      triggerTime
      startDaqSample
   end
   methods
      function self = PeekEvent(hwChannels, data, timeStamps, triggerTime, startDaqSample)
         self.hwChannels = hwChannels;
         self.data = data;
         self.timeStamps = timeStamps;
         self.triggerTime = triggerTime;
         self.startDaqSample = startDaqSample;
      end
   end
end