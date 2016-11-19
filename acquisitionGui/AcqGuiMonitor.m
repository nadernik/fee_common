classdef (Sealed) AcqGuiMonitor < handle
    properties (SetAccess = private, Dependent = true)
        updateListenerValid
        bufferDelay
        isRunning
    end
    properties (SetAccess = private)
        detectingSong = false % indicates if ANY experiments are detecting song
    end
    properties (Access = private)
        %% Experiment related properties
        ExperManager
        ExperChangedListener
        DetectionChangedListener
        
        %% Daq related properties
        DaqObj
        daqFs
        bufferSecs
        updateFreq
        
        %% Monitoring related properties
        songDetectingExpers
        detectingExperNdx
        peekHWChannels
        UpdateCompleteListener
        PeekAvailableListener
        peekSecs
        peekOverlap % Fraction of peekSecs shared between successive peeks
        sampBetweenRequests = -1;
        peekNSamp = -1;
        peekOverlapSamp = -1;
        lastPeekSamp = -1;
    end
    methods
        function self = AcqGuiMonitor(ExperManager, varargin)
            %% Parse inputs
            p = inputParser();
            p.KeepUnmatched = true;
            addParameter(p, 'peekSecs', 1); % in seconds
            addParameter(p, 'peekOverlap', 0.1);
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.ExperManager = ExperManager;
            self.peekSecs = Params.peekSecs;
            self.peekOverlap = Params.peekOverlap;
            self.ExperChangedListener = addlistener(self.ExperManager, 'ExperimentsChanged', @self.experiments_changed_callback);
            self.DetectionChangedListener = addlistener(self.ExperManager, 'DetectionChanged', @self.detection_changed_callback);
        end
        
        %% public methods
        function start_monitor(self, DaqObj)
            self.DaqObj = DaqObj;
            self.daqFs = self.DaqObj.samplingRate;
            self.bufferSecs = self.DaqObj.bufferSecs;
            self.updateFreq = self.DaqObj.updateFreq;
            secBetweenReq = (1 + self.peekOverlap) * self.peekSecs - (1 / self.updateFreq); % Amount of time between peek requests
            self.sampBetweenRequests = ceil(secBetweenReq * self.daqFs);
            self.peekNSamp = ceil(self.peekSecs * self.daqFs);
            self.peekOverlapSamp = ceil(self.peekNSamp * self.peekOverlap);
            self.update_song_detection();
        end
        function stop_monitor(self)
            if self.detectingSong
                self.stop_song_detection();
            end
            self.DaqObj = [];
            self.daqFs = -1;
            self.bufferSecs = -1;
            self.updateFreq = -1;
            self.sampBetweenRequests = -1;
            self.peekNSamp = -1;
            self.peekOverlapSamp = -1;
        end
        function update_song_detection(self)
            self.songDetectingExpers = cellfun(@(E) E.detectingSong, self.ExperManager.Experiments);
            self.peekHWChannels = self.ExperManager.songHWChannels(self.songDetectingExpers);
            self.detectingExperNdx = find(self.songDetectingExpers);
            nowDetectingSong = any(self.songDetectingExpers);
            if nowDetectingSong ~= self.detectingSong % State changed
                if nowDetectingSong % start detecting song
                    self.start_song_detection();
                else % turn off song detection
                    self.stop_song_detection();
                end
            end
        end
        
        %% Callbacks -- do not use externally
        function update_complete_callback(self, ~, ~)
            if self.isRunning && self.detectingSong
                sampsSincePeek = self.DaqObj.lastSample - self.lastPeekSamp;
                if sampsSincePeek >= self.sampBetweenRequests
                    self.request_peek();
                end
            end
        end
        
        function analyze_peek(self, ~, PeekEvent)
            nDetect = numel(self.detectingExperNdx);
            peekStartSamp = PeekEvent.startDaqSample;
            for experNo = 1:nDetect
                experNdx = self.detectingExperNdx(experNo);
                status = self.ExperManager.Experiments{experNdx}. ...
                    detect_song_and_record(PeekEvent.data(:, experNo), peekStartSamp);
                assert(status, 'Song detetion failed');
            end
            self.lastPeekSamp = self.DaqObj.lastSample;
            notify(self, 'PeekComplete', ExperEvent(PeekEvent.hwChannels));
        end
        
        function experiments_changed_callback(self, ~, ~)
            if self.isRunning
                self.update_song_detection();
            end
        end
        
        function detection_changed_callback(self, ~, ~)
            if self.isRunning
                self.update_song_detection();
            end
        end
        
        %% Dependent property getters
        function val = get.updateListenerValid(self)
            val = ~isempty(self.UpdateCompleteListener) && isvalid(self.UpdateCompleteListener);
        end
        function val = get.bufferDelay(self)
            val = seconds(self.peekSecs * self.peekOverlap);
        end
        function val = get.isRunning(self)
            val = ~isempty(self.DaqObj) && self.DaqObj.isStarted;
        end
    end
    methods (Access = private)
        function request_peek(self)
            %REQUEST_PEEK Ask DAQ for peek of data in buffer
            if ~self.DaqObj.isUpdating && ~self.DaqObj.isPeeking % will re-attempt at next update
                peekFromSample = self.lastPeekSamp - self.peekOverlapSamp;
                self.DaqObj.request_peek(self.peekHWChannels, peekFromSample);
            end
        end
        
        function start_song_detection(self)
            % This should not be called for starting song detection of an
            % individual experiment, only call to start ANY song detection
            if self.detectingSong
                warning('Song detection already happening');
                return
            end
            self.detectingSong = true;
            self.lastPeekSamp = self.DaqObj.lastSample;
            self.UpdateCompleteListener = ...
                addlistener(self.DaqObj, 'UpdateComplete', @self.update_complete_callback);
            self.PeekAvailableListener = ...
                addlistener(self.DaqObj, 'PeekAvailable', @self.analyze_peek);
        end
        function stop_song_detection(self)
            % This should not be called for stopping song detection of an
            % individual experiment, only call if NO experiments are doing
            % song detection
            if ~self.detectingSong
                warning('Song detection not happening');
                return
            end
            self.lastPeekSamp = -1;
            delete(self.UpdateCompleteListener);
            delete(self.PeekAvailableListener);
            self.detectingSong = false;
        end
    end
    events (NotifyAccess = private)
        RecordingStarted
        RecordingComplete
        DetectionChanged
        PeekComplete
    end
end