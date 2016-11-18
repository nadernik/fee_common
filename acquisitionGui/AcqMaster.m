classdef (Sealed) AcqMaster < handle
    %ACQMASTER manages a group of song-triggered experiments
    properties (SetAccess = private)
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
        isBuffering = false
        daqRunning = false
        BufferTimer
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
            p.KeepUnmatched = true;
            addParameter(p, 'daqLogFile', '');
            addParameter(p, 'updateFreq', 4);
            addParameter(p, 'bufferSecs', 20);
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties, create subordinate objects
            self.daqLogFile = Params.daqLogFile;
            self.updateFreq = Params.updateFreq;
            self.bufferSecs = Params.bufferSecs;
            self.ExperManager = AcqGuiExperimentManager(varargin{:});
            self.RestartManager = AcqGuiRestartManager(self.ExperManager, varargin{:});
            self.SongMonitor = AcqGuiMonitor(self.ExperManager, varargin{:});
            
            %% Set up DaqBuffer
            if ~self.ExperManager.isEmpty
                self.init_daq();
                self.start_daq();
            end
        end
        
        function status = append_exper(self, Experiment)
            modifyFun = @() self.ExperManager.append_experiment(Experiment);
            status = self.modify_experiments(modifyFun);
            if status && ~self.daqRunning
                self.start_daq();
            end
        end
        function status = remove_exper(self, experNo)
            modifyFun = @() self.ExperManager.remove_experiment(experNo);
            status = self.modify_experiments(modifyFun);
        end
        function status = suspend(self)
            if ~self.ExperManager.anyRecording && ~self.ExperManager.suspended && self.daqRunning
                self.ExperManager.suspend_experiments();
                self.SongMonitor.stop_monitor();
                self.ExperManager.clear_daq();
                self.stop_daq();
                status = true;
            else
                status = false;
            end
        end
        function status = resume(self)
            if ~self.daqRunning
                self.init_daq();
                if self.ExperManager.suspended
                    self.ExperManager.resume_experiments();
                end
                self.start_daq();
                status = true;
            else
                status = false;
            end
        end
    end
    methods (Access = private)
        %% Methods to interface with DaqBuffer
        function init_daq(self)
            if self.ExperManager.isEmpty
                return
            end
            %% Set up DAQ
            DaqBuffer.reset(); % Clear any existing channels
            self.DaqObj = DaqBuffer.get_instance( ...
                self.ExperManager.inChannels, ...
                self.ExperManager.commonFs, ...
                self.bufferSecs, ...
                self.updateFreq);
            assert(~isempty(self.DaqObj), 'Did not receive Daq information');
            if ~isempty(self.daqLogFile)
                self.DaqObj.logFID = fopen(self.daqLogFile, 'w');
            end
            
            %% Store daq parameters
            self.daqFs = self.DaqObj.samplingRate;
            self.bufferSecs = self.DaqObj.bufferSecs;
            self.updateFreq = self.DaqObj.updateFreq;
            
            %% Pass daq information to experiments
            self.SongMonitor.start_monitor(self.DaqObj);
            self.ExperManager.set_daq_params(self.DaqObj);
        end
        function start_daq(self)
            if self.ExperManager.isEmpty
                return
            end
            self.DaqObj.start();
            self.daqRunning = true;
            self.wait_for_buffer();
        end
        function stop_daq(self)
            recordingExpers = cellfun(@(E) E.isRecording, self.ExperManager.Experiments);
            if any(recordingExpers)
                cellfun(@(E) E.force_stop_recording(), self.ExperManager.Experiments(recordingExpers));
            end
            self.DaqObj.stop();
            self.daqRunning = false;
            notify(self, 'DaqChanged');
        end
        
        function status = modify_experiments(self, modifyFun)
            wasRunning = self.daqRunning;
            if wasRunning
                status = self.suspend();
            else
                status = true;
            end
            if status
                modifyFun();
                if wasRunning && ~self.ExperManager.isEmpty
                    status = status && self.resume();
                else
                    self.init_daq();
                end
            end
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
            stop(self.BufferTimer);
            delete(self.BufferTimer);
            self.SongMonitor.update_song_detection();
            notify(self, 'DaqChanged');
        end
        
    end
    events (NotifyAccess = private)
        DaqChanged
    end
end