classdef SongTriggeredExperiment < handle
    properties
        %% Song detection parameters
        minFreq
        maxFreq
        ratioThreshold
        songDuration
        songDensity
        daqParameters
    end
    properties (SetAccess = private)
        %% Information about which channels are part of this experiment
        songHWChannel
        nonSongHWChannels
        
        %% Information about saved files
        directory
        lastFileNo
        fileTimes
        
        %% Recording/monitoring status
        detectingSong
        forcedRecording
    end
    properties (Access = private)
        desiredDaqParameters
        recordingListener
        
        %% Derived song detection parameters
        windowLength
        windowAvg
        minNdx
        maxNdx
        windowSize
        windowOverlap
    end
    
    methods
        function self = SongTriggeredExperiment(directory, songHWChannel, nonSongHWChannels, daqParameters, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
                    addParameter(p, 'minFreq', 2000);
                    addParameter(p, 'maxFreq', 6000);
                    addParameter(p, 'songDensity', 0.5); % aka durationThreshold
                    addParameter(p, 'ratioThreshold', 2); % aka powerThreshold
                    addParameter(p, 'songDuration', 1); % aka songLength
            end
        end
    end
end