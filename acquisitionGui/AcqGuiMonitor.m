classdef (Sealed) AcqGuiMonitor < handle
    properties
        GuiModel
    end
    properties (SetAccess = private, Dependent = true)
        updateListenerValid
        bufferDelay
    end
    properties (Access = private)
        %% Daq related properties
        daqFs
        bufferSecs
        updateFreq
        
        %% Monitoring related properties
        detectingSong
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
        DetectionChangeListeners % N x 1 cell array of DetectionChangeListeners
    end
    methods
        function self = AcqGuiMonitor(GuiModel, varargin)
            p = inputParser();
            p.KeepUnmatached = true;
            addParameter(p, 'peekSecs', 1); % in seconds
            addParameter(p, 'peekOverlap', 0.1);
            self.GuiModel = GuiModel;
            self.peekSecs = Params.peekSecs;
            self.peekOverlap = Params.peekOverlap;
        end
        
        %% public methods
        function init_monitor(self)
            self.daqFs = self.GuiModel.DaqObj.samplingRate;
            self.bufferSecs = self.GuiModel.DaqObj.bufferSecs;
            self.updateFreq = self.GuiModel.DaqObj.updateFreq;
            secBetweenReq = (1 + self.peekOverlap) * self.peekSecs - (1 / self.GuiModel.updateFreq); % Amount of time between peek requests
            self.sampBetweenRequests = ceil(secBetweenReq * self.GuiModel.daqFs);
            self.peekNSamp = ceil(self.peekSecs * self.GuiModel.daqFs);
            self.peekOverlapSamp = ceil(self.peekNSamp * self.peekOverlap);
        end
        
        function update_song_detection(self)
            self.songDetectingExpers = cellfun(@(E) E.detectingSong, self.GuiModel.Experiments);
            self.peekHWChannels = self.GuiModel.songHWChannels(self.songDetectingExpers);
            self.detectingExperNdx = find(self.songDetectingExpers);
            nowDetectingSong = any(self.songDetectingExpers);
            if nowDetectiongSong ~= self.detectingSong % State changed
                if nowDetectingSong % start detecting song
                    self.start_song_detection();
                else % turn off song detection
                    self.stop_song_detection();
                end
            end
        end
        
        %% Callbacks -- do not use externally
        function update_complete_callback(self, ~, ~)
            if self.detectingSong
                sampsSincePeek = self.GuiModel.DaqObj.lastSample - self.lastPeekSamp;
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
                status = self.Experiments{experNdx}. ...
                    detect_song_and_record(PeekEvent.data(:, experNo), peekStartSamp);
                assert(status, 'Song detetion failed');
            end
        end
        
        function detection_changed_callback(self, ~, ~)
            self.update_song_detection();
        end
        
        %% Dependent property getters
        function val = get.updateListenerValid(self)
            val = ~isempty(self.UpdateCompleteListener) && isvalid(self.UpdateCompleteListener);
        end
        function val = get.bufferDelay(self)
            val = seconds(self.peekSecs * self.peekOverlap);
        end
    end
    methods (Access = private)
        function request_peek(self)
            %REQUEST_PEEK Ask DAQ for peek of data in buffer
            if ~self.GuiModel.DaqObj.isUpdating && ~self.GuiModel.DaqObj.isPeeking % will re-attempt at next update
                peekSample = self.lastPeekSamp - self.peekOverlapSamp;
                self.GuiModel.DaqObj.request_peek(self.peekHWChannels, peekSample);
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
            self.lastPeekSamp = self.GuiModel.DaqObj.lastSample;
            self.UpdateCompleteListener = ...
                addlistener(self.GuiModel.DaqObj, 'UpdateComplete', @self.update_complete_callback);
            self.PeekAvailableListener = ...
                addlistener(self.GuiModel.DaqObj, 'PeekAvailable', @self.analyze_peek);
        end
        function stop_song_detection(self)
            % This should not be called for stopping song detection of an
            % individual experiment, only call if NO experiments are doing
            % song detection
            if ~self.detectingSong
                warning('Song detection not happening');
                return
            end
            delete(self.UpdateCompleteListener);
            delete(self.PeekAvailableListener);
            self.detectingSong = false;
        end
    end
    events (NotifyAccess = private)
        RecordingStarted
        RecordingComplete
        DetectionChanged
    end
end