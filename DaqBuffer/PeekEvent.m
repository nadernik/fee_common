classdef (ConstructOnLoad) PeekEvent < event.EventData
   properties
      data
      timeStamps
   end
   methods
      function self = PeekEvent(data, timeStamps)
         self.data = data;
         self.timeStamps = timeStamps;
      end
   end
end