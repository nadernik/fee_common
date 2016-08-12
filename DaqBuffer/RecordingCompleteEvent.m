classdef (ConstructOnLoad) RecordingCompleteEvent < event.EventData
   properties
      hwChannels = [];
      fileNames = {};
   end
   methods
      function self = RecordingCompleteEvent(hwChannels, fileNames)
         self.hwChannels = hwChannels;
         self.fileNames = fileNames;
      end
   end
end