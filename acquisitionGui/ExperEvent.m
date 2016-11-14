classdef (ConstructOnLoad) ExperEvent < event.EventData
   properties
      experNo
   end
   methods
      function self = ExperEvent(experNo)
         self.experNo = experNo;
      end
   end
end