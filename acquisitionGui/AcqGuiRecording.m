classdef (Sealed) AcqGuiRecording < handle
    %ACQGUIRECORDING loads and stores the files from a recording
    %   It initially loads the audio file, and incrementally loads other
    %   channels as they are requested.
    properties (SetAccess = private)
        filesExist = false;
        
        recordingNo
        
        signalChannels
        signals
        propertyNames
        propertyValues
        fileFs
        fileCreationTime
        numSamples
        
        maxLoadSize
        
        fileNames
        fileHwChans
    end
    properties (Access = private)
        Experiment
        samplesToLoad
    end
    methods
        function self = AcqGuiRecording(Experiment, recordingNo, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
                p.KeepUnmatched = true;
                addParameter(p, 'maxLoadSize', 2000000);
            end
            parse(p, varargin{:});
            Params = p.Results;
            self.Experiment = Experiment;
            self.recordingNo = recordingNo;
            self.maxLoadSize = Params.maxLoadSize;
            
            %% Find data files
            [relFileNames, self.fileHwChans] = self.Experiment.find_files(self.recordingNo);
            self.filesExist = ~isempty(relFileNames);
            
            if self.filesExist
                self.fileNames = fullfile(self.Experiment.experDirectory, relFileNames);
                songFile = self.fileNames{self.Experiment.songHWChannel == self.fileHwChans};
                
                %% Initialize signal variables
                nChan = numel(self.Experiment.nonSongHWChannels) + 1;
                self.signals = cell(nChan, 1);
                self.signalChannels = nan(nChan, 1);
                
                %% Determine if the recording is too big to load
                [~, info] = daq_readDatafile(songFile, true, 0);
                if info.numSamples > self.maxLoadSize
                    self.samplesToLoad = [1, self.maxLoadSize];
                else
                    self.samplesToLoad = []; % Load everything
                end
                
                %% Load the audio signal
                self.signalChannels(1) = self.Experiment.songHWChannel;
                if ~isempty(self.Experiment.nonSongHWChannels)
                    self.signalChannels(2:end) = self.Experiment.nonSongHWChannels;
                end
                [self.signals{1}, info] = daq_readDatafile(songFile, true, self.samplesToLoad);
                self.fileFs = info.fs;
                self.fileCreationTime = datetime(info.absStartTime, 'ConvertFrom', 'datenum');
                self.propertyNames = info.propertyNames;
                self.propertyValues = info.propertyValues;
                self.numSamples = numel(self.signals{1});
            end
        end
        
        function load_channels(self, hwChans)
            nChan = numel(hwChans);
            for chanNo = 1:nChan
                thisChan = hwChans(chanNo);
                chanNdx = find(self.signalChannels == thisChan, 1, 'first');
                if ~isempty(chanNdx) && isempty(self.signals{chanNdx}) % Still need to load this file
                    fileName = self.fileNames{self.fileHwChans == thisChan};
                    [self.signals{chanNdx}, info] = ...
                        daq_readDatafile(fileName, true, self.samplesToLoad);
                    assert(info.fs == self.fileFs, 'Different sampling frequency!');
                end
            end
        end
    end
end