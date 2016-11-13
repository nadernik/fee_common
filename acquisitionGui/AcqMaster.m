classdef (Sealed) AcqMaster < handle
    properties (Access = private)
        %% Gui properties
        GuiFig
        GuiData
        Views
        
        %% Experiment related properties
        ExperimentManager
        Experiments % N x 1 cell array of SongTriggeredExperiment objects
        experimentStrings % strings used to describe experiments
        rememberedDetect = []; % N x 1 boolean array of songDetection states when experiments last suspended, empty if not suspended
        
        
        %% Display data
        CurrentRecording
        
        currentExperNdx = 0;
        experDisplayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, -1 for nothing
        displayRecordingNo = nan(0, 1);% Nx1 matrix of file number to display, -1 for nothing
        startNdx = 0;
        endNdx = 0;
        fileFs
        autoSpec
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
        
        %% Daq related properties
        DaqObj
        daqLogFile
        songHWChannels = [];
        nonSongHWChannels = {};
        inChannels = [];
        daqFs = -1;
        bufferSecs;
        updateFreq;
        
        %% Restart related properties
        RestartManager
        
        %% Monitoring related properties
        SongMonitor
        isBuffering
        daqRunning
        BufferTimer
    end
    methods
        %% Constructor and destructor
        function self = AcqGuiModel(GuiFig, varargin)
            %% Parse inputs
            p = inputParser();
            p.keepUnmatched = true;
            addParameter(p, 'Experiments', {});
            addParameter(p, 'daqLogFile', '');
            addParameter(p, 'updateFreq', 4);
            addParameter(p, 'bufferSecs', 20);
            addParameter(p, 'autoSpec', true);
            addParameter(p, 'maxLoadSize', 2000000);
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.GuiFig = GuiFig;
            self.GuiData = guidata(self.GuiFig);
            self.GuiData.GuiModel = self; % insert self reference into gui data
            self.ExperimentManager = AcqGuiExperimentManager(self, varargin{:});
            self.daqLogFile = Params.daqLogFile;
            self.updateFreq = Params.updateFreq;
            self.bufferSecs = Params.bufferSecs;
            self.ExperimentManager = AcqGuiExperimentManager();
            self.RestartManager = AcqGuiRestartManager(self.ExperimentManager, varargin{:});
            self.SongMonitor = AcqGuiMonitor(self, varargin{:});
            self.Views = AcqGuiViews(self, varargin{:});
            
            %% Add a reference to this object into gui data
            guidata(self.GuiFig, self.GuiData); % Place guidata back into gui figure
            
            %% Set up DaqBuffer
            if ~isempty(self.Experiments)
                nExper = numel(self.Experiments);
                self.experDisplayChannels = -1 * ones(3, nExper); % 3xN matrix of HW channels to display for each of N experiments, -1 for nothing
                self.displayRecordingNo = zeros(nExper, 1);% Nx1 matrix of file number to display
                self.default_exper_display(1:nExper);
                self.update_exper_strings();
                self.init_daq();
                self.start_daq();
            end
        end
    end
    methods (Access = private)
        %% Display methods
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
        
        %% Methods to add or remove experiments
        function append_experiment(self, Experiment)
            assert(~self.DaqObj.isRunning, 'Cannot add experiment when DAQ is running');
            self.Experiments{end + 1} = Experiment;
            self.experDisplayChannels(:, end + 1) = -1 * ones(1, 3);
            self.displayRecordingNo(end + 1) = 0;
            experNo = numel(self.Experiments);
            self.default_exper_display(experNo);
            self.update_exper_strings();
        end
        function default_exper_display(self, experNdxArray)
            nExper = numel(experNdxArray);
            for experNo = 1:nExper
                experNdx = experNdxArray(experNo);
                nCh = numel(self.Experiments{experNdx}.nonSongHWChannels);
                self.experDisplayChannels(:, experNo) = self.Experiments{experNdx}.songHWChannel;
                self.experDisplayChannels(1:nCh, experNo) = self.Experiments{experNdx}.nonSongHWChannels;
                self.displayRecordingNo(experNo) = self.Experiments{experNdx}.lastFileNo;
            end
        end
        
        %% Methods to interface with DaqBuffer
        function init_daq(self)
            if isempty(self.Experiments)
                return
            end
            %% Make sure all experiments are compatible
            desiredFs = cellfun(@(E) E.desiredFs, self.Experiments);
            assert(all(desiredFs == desiredFs(1)), 'All experiments must have the same sampling rate');
            
            %% Store channel parameters
            inChannels = cellfun(@(E) E.inChannels, self.Experiments, 'UniformOutput', false); %#ok<PROP>
            self.inChannels = vertcat(inChannels{:}); %#ok<PROP>
            self.songHWChannels = cellfun(@(E) E.songHWChannel, self.Experiments);
            self.nonSongHWChannels = cellfun(@(E) E.nonSongHWChannels, self.Experiments, 'UniformOutput', false);
            
            %% Set up DAQ
            DaqBuffer.reset(); % Clear any existing channels
            self.DaqObj = DaqBuffer.get_instance(self.inChannels, desiredFs(1), self.bufferSecs, self.updateFreq);
            if ~isempty(self.daqLogFile)
                self.DaqObj.logFID = fopen(self.daqLogFile, 'w');
            end
            
            %% Store daq parameters
            self.daqFs = self.DaqObj.samplingRate;
            self.bufferSecs = self.DaqObj.bufferSecs;
            self.updateFreq = self.DaqObj.updateFreq;
            
            self.SongMonitor.monitor_init();
            
            %% Pass daq information to experiments
            cellfun(@(E) E.set_daq_params(self.DaqObj), self.Experiments);
        end
        function start_daq(self)
            self.DaqObj.start();
            self.wait_for_buffer();
        end
        function stop_daq(self)
            recordingExpers = cellfun(@(E) E.isRecording, self.Experiments);
            if any(recordingExpers)
                cellfun(@(E) E.force_stop_recording(), self.Experiments(recordingExpers));
            end
            self.DaqObj.stop();
            notify(self, 'DaqChanged');
        end
        
        %% Methods related to state transitions
        function wait_for_buffer(self)
            self.isBuffering = true;
            self.gui_wait_buffer();
            self.BufferTimer = timer('Name', 'bufferTimer', ...
                'TimerFcn', @self.buffering_complete, ...
                'ExecutionMode', 'singleShot', ...
                'BusyMode', 'queue');
            CurrentTime = datetime();
            BufferUntil = CurrentTime + self.SongMonitor.bufferDelay;
            startat(self.BufferTimer, BufferUntil);
            notify(self, 'DaqChanged');
        end
        
        function buffering_complete(self, ~, ~)
            self.isBuffering = false;
            delete(self.BufferTimer);
            self.SongMonitor.update_song_detection();
            notify(self, 'DaqChanged');
        end

    end
    events (NotifyAccess = private)
        DaqChanged
        RecordingChanged
    end
end