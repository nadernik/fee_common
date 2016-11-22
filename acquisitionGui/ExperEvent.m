classdef (ConstructOnLoad) ExperEvent < event.EventData
   properties
      nos
   end
   methods
      function self = ExperEvent(nos)
         self.nos = nos;
      end
   end
end