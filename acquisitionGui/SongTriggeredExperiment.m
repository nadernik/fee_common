classdef SongTriggeredExperiment < handle
    properties
        %% Song detection parameters
        windowSize
        windowOverlap
        minFreq
        maxFreq
        minNdx
        maxNdx
        ratioThreshold
        songDuration
        windowLength
        windowAvg
        durationThreshold
    end
    properties (SetAccess = private)
        lastFileNo
        fileTimes
        detectingSong
        forcedRecording
        directory
    end
    properties (Access = private)
        daqParameters
        recordingListener
    end
    
    methods
        function self = SongTriggeredExperiment()
        end
    end
end