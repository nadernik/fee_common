classdef (ConstructOnLoad) PeekEvent < event.EventData
   properties
      data
      timeStamps
      triggerTime
      startDaqSample
   end
   methods
      function self = PeekEvent(data, timeStamps, triggerTime, startDaqSample)
         self.data = data;
         self.timeStamps = timeStamps;
         self.triggerTime = triggerTime;
         self.startDaqSample = startDaqSample;
      end
   end
end