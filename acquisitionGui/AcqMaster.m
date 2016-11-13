classdef (Sealed) AcqMaster < handle
    %ACQMASTER manages a group of song-triggered experiments
    properties (Access = private)
        %% Experiment related properties
        ExperManager
        
        %% Daq related properties
        DaqObj
        daqLogFile
        
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
        
        startupArgs
    end
    methods
        %% Constructor and destructor
        function self = AcqMaster(varargin)
            %ACQMASTER Creates a pool of experiments and starts the DAQ
            %   obj = ACQMASTER() creates an empty acquisition seesion
            %   obj = ACQMASTER(ParameterName, ParamterValue)
            %
            %   Parameters are used directly by the constructor, and passed
            %   onto subordinate constructors. Constructor parameters are:
            %   'daqLogFile': filename to log daq information
            %   'updateFreq': How often to pull data from the daq, in Hz
            %   'bufferSecs': The length of the buffer to maintain, in secs
            
            %% Parse inputs
            p = inputParser();
            p.keepUnmatched = true;
            addParameter(p, 'daqLogFile', '');
            addParameter(p, 'updateFreq', 4);
            addParameter(p, 'bufferSecs', 20);
            parse(p, varargin{:});
            Params = p.Results;
            self.startupArgs = vararagin;
            
            %% Set properties, create subordinate objects
            self.daqLogFile = Params.daqLogFile;
            self.updateFreq = Params.updateFreq;
            self.bufferSecs = Params.bufferSecs;
            self.ExperManager = AcqGuiExperimentManager(varargin{:});
            self.RestartManager = AcqGuiRestartManager(self.ExperManager, varargin{:});
            
            %% Set up DaqBuffer
            if ~self.ExperManager.isEmpty
                self.init_daq();
                self.start_daq();
            end
        end
    end
    methods (Access = private)
        %% Methods to interface with DaqBuffer
        function init_daq(self)
            if isempty(self.ExperManager.Experiments)
                return
            end
            %% Set up DAQ
            DaqBuffer.reset(); % Clear any existing channels
            self.DaqObj = DaqBuffer.get_instance( ...
                self.ExperManager.inChannels, ...
                self.ExperManager.commonFs, ...
                self.bufferSecs, ...
                self.updateFreq);
            if ~isempty(self.daqLogFile)
                self.DaqObj.logFID = fopen(self.daqLogFile, 'w');
            end
            
            %% Store daq parameters
            self.daqFs = self.DaqObj.samplingRate;
            self.bufferSecs = self.DaqObj.bufferSecs;
            self.updateFreq = self.DaqObj.updateFreq;
            self.SongMonitor = AcqGuiMonitor(self.DaqObj, self.ExperManager, self.startupArgs{:});
            
            %% Pass daq information to experiments
            self.ExperManager.set_daq_params(self.DaqObj);
        end
        function start_daq(self)
            self.DaqObj.start();
            self.wait_for_buffer();
        end
        function stop_daq(self)
            recordingExpers = cellfun(@(E) E.isRecording, self.ExperManager.Experiments);
            if any(recordingExpers)
                cellfun(@(E) E.force_stop_recording(), self.ExperManager.Experiments(recordingExpers));
            end
            self.DaqObj.stop();
            notify(self, 'DaqChanged');
        end
        
        %% Methods related to state transitions
        function wait_for_buffer(self)
            self.isBuffering = true;
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
    end
end