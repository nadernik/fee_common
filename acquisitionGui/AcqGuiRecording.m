classdef (Sealed) AcqGuiRecording < handle
    % Class to load and store the files associated with a recording on disk
    properties
        maxLoadSize
        samplesToLoad
        fileNames
        fileHwChans
        audioSignal
        nonSongSignals = cell(0, 1);
        nonSongSignalNdx
        propertyNames
        propertyValues
        fileCreationTime
    end
    methods
        function self = AcqGuiRecording(varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
                p.keepUnmatched = true;
                addParameter(p, 'maxLoadSize', 2000000);
            end
            parse(p, varargin{:});
            Params = p.Results;
            self.maxLoadSize = Params.maxLoadSize;
        end
        function load_recording(self)
            %% Convenience variables
            experNdx = self.currentExperNdx;
            currExper = self.Experiments{self.currentExperNdx};
            currDir = currExper.experDir;
            
            %% Reset signal variables
            nChan = numel(self.nonSongHWChannels{experNdx});
            self.nonSongSignals = cell(nChan, 1);
            
            %% Find data files
            [relFileNames, self.fileHwChans] = currExper.find_files(recordingNo);
            self.fileNames = fullfile(currDir, relFileNames);
            songFile = self.fileNames{self.songHWChannels(experNdx) == hwChannels};
            
            %% Determine if the recording is too big to load
            [~, info] = daq_readDatafile(songFile, true, 0);
            if info.numSamples > self.maxLoadSize
                self.samplesToLoad = [1, self.maxLoadSize];
            else
                self.samplesToLoad = []; % Load everything
            end
            
            %% Load the audio signal
            [self.audioSignal, info] = daq_readDatafile(songFile, true, self.samplesToLoad);
            self.fileFs = info.fs;
            self.fileCreationTime = datetime(info.absStartTime, 'ConvertFrom', 'datenum');
            self.propertyNames = info.propertyNames;
            self.propertyValues = info.propertyValues;
            
            %% Load the other signals
            for dispCh = 1:3
                self.load_channel(self.experDisplayChannels(dispCh, experNdx));
            end
            
            self.gui_spectrogram();
            self.gui_file_properties();
            self.gui_signals();
        end
        
        function load_channel(self, hwChan)
            experNdx = self.currentExperNdx;
            nonSongChans = self.nonSongHWChannels{experNdx};
            chanNdx = find(nonSongChans == hwChan, 1, 'first');
            if ~isempty(chandNdx) && isempty(self.nonSongSignals{chanNdx}) % Still need to load this file
                fileName = self.fileNames{self.fileHwChans == hwChan};
                [self.nonSongSignals{chanNdx}, info] = ...
                    daq_readDatafile(fileName, true, self.samplesToLoad);
                assert(info.fs == self.fileFs, 'Different sampling frequency!');
            end
        end
    end
end