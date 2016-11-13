classdef (Sealed) AcqMaster < handle
    properties (Access = private)
        %% Experiment related properties
        ExperimentManager
        
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