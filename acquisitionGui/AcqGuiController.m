classdef (Sealed) AcqGuiController < handle
    properties (Access = private)
        %% Gui
        GuiFig
        GuiData
        
        %% Experiment related properties
        Experiments % N x 1 cell array of SongTriggeredExperiment objects
        rememberedDetect = []; % N x 1 boolean array of songDetection states when experiments last suspended, empty if not suspended
        
        %% Display data
        currentExperNdx = 0;
        experDisplayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
        displayRecordingNo = nan(0, 1);% Nx1 matrix of file number to display
        startNdx = 0;
        endNdx = 0;
        
        %% Daq related properties
        DaqObj
        daqLogFile
        songHWChannels = [];
        inChannels = [];
        daqFs = -1;
        bufferSecs = -1;
        updateFreq = -1;
        
        %% Restart related properties
        restartDaily
        startHour
        stopHour
        RestartTimer
        
        %% Monitoring related properties
        SongDetectionTimer
        detectingSong
        peekSecs
        peekNSamp = -1;
        BufferTimer
    end
    properties (Access = private, Dependent = true)
        restartTimerValid
        isDaytime
        detectionTimerValid
    end
    methods
        function self = AcqGuiController(GuiFig, varargin)
            %% Parse inputs
            p = inputParser();
            addParameter(p, 'restartDaily', false);
            addParameter(p, 'startHour', 7);
            addParameter(p, 'stopHour', 23);
            addParameter(p, 'Experiments', {});
            addParameter(p, 'daqLogFile', '');
            addParameter(p, 'peekSecs', 1); % in seconds
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.GuiFig = GuiFig;
            self.GuiData = guidata(self.GuiFig);
            self.GuiData.AcqGuiController = self; % insert self reference into gui data
            self.restartDaily = Params.restartDaily;
            self.startHour = Params.startHour;
            self.stopHour = Params.stopHour;
            self.Experiments = Params.Experiments;
            self.daqLogFile = Params.daqLogFile;
            self.peekSecs = Params.peekSecs;
            
            %% Set gui into initial, disabled, state
            self.gui_init();
            
            %% Add a reference to this object into gui data
            guidata(self.GuiFig, self.GuiData); % Place guidata back into gui figure
            
            %% Set restart timer
            if self.restartDaily
                self.set_restart();
            end
            
            %% Set up daq
            self.init_daq();
            self.start_daq();
            
            %% Finish setting up GUI
            self.gui_exper();
        end
        
        function delete(self)
            % Clean up
        end
        
        function restart_night_callback(self, ~, ~)
            if ~self.restartTimerValid
                error('Error with night restart timer');
            end
            stop(self.RestartTimer);
            delete(self.RestartTimer);
            self.suspend_experiments();
            self.queue_morning_timer();
        end
        function restart_morning_callback(self, ~, ~)
            if ~self.restartTimerValid
                error('Error with morning restart timer');
            end
            stop(self.RestartTimer);
            delete(self.RestartTimer);
            self.reset_experiments(); % Creates new experiments for the new day
            self.resume_experiments(); % Restores whatever triggering state they had before the night timer
            self.queue_night_timer(); % Start the night timer for later in the day
        end
        
        function restartTimerValid = get.restartTimerValid(self)
            restartTimerValid = ~isempty(self.RestartTimer) && isvalid(self.RestartTimer);
        end
        function val = get.detectionTimerValid(self)
            val = ~isempty(self.SongDetectionTimer) && isvalid(self.SongDetectionTimer);
        end
        function isDaytime = get.isDaytime(self)
            currentTime = datetime();
            isDaytime = currentTime.Hour >= self.startHour && ...
                currentTime.Hour <= self.stopHour;
        end
    end
    methods (Access = private)
        function init_daq(self)
            if isempty(self.Experiments)
                return
            end
            %% Make sure all experiments are compatible
            desiredFs = cellfun(@(E) E.desiredFs, self.Experiments);
            updateFreq = cellfun(@(E) E.daqUpdateFreq, self.Experiments);
            bufferSecs = cellfun(@(E) E.daqBufferSecs, self.Experiments);
            assert(all(desiredFs == desiredFs(1)), 'All experiments must have the same sampling rate');
            assert(all(updateFreq == updateFreq(1)), 'All experiments must have the same update frequency');
            assert(all(bufferSecs == bufferSecs(1)), 'All experiments must have the same buffer size');
            
            %% Store channel parameters
            self.inChannels = cellfun(@(E) E.inChannels, self.Experiments);
            self.songHWChannels = cellfun(@(E) E.songHWChannel, self.Experiments);
            
            %% Set up DAQ
            DaqBuffer.reset(); % Clear any existing channels
            self.DaqObj = DaqBuffer.get_instance(self.inChannels, desiredFs(1), bufferSecs(1), updateFreq(1));
            if ~isempty(self.daqLogFile)
                self.DaqObj.logFID = fopen(self.daqLogFile, 'w');
            end
            
            %% Store daq parameters
            self.daqFs = self.DaqObj.samplingRate;
            self.bufferSecs = self.DaqObj.bufferSecs;
            self.updateFreq = self.DaqObj.updateFreq;
            
            %% Pass daq information to experiments
            cellfun(@(E) E.set_daq_params(self.DaqObj), self.Experiments);
        end
        function start_daq(self)
            self.DaqObj.start();
            self.gui_startdaq();
            self.wait_for_buffer();
        end
        function status = stop_daq(self)
        end
        
        function wait_for_buffer(self)
            self.gui_wait_buffer();
            self.BufferTimer = timer('Name', 'bufferTimer', ...
                'TimerFcn', @self.buffering_complete, ...
                'ExecutionMode', 'singleShot', ...
                'BusyMode', 'queue');
            CurrentTime = datetime();
            BufferUntil = CurrentTime + seconds(self.peekSecs);
            startat(self.BufferTimer, BufferUntil);
        end
        
        function buffering_complete(self, ~, ~)
            stop(self.BufferTimer);
            delete(self.BufferTimer);
            self.update_song_detection();
            self.gui_buffering_complete();
        end
        
        function update_song_detection(self)
            nowDetectingSong = any(cellfun(@(E) E.detectingSong, self.Experiments));
            if nowDetectiongSong ~= self.detectingSong % State changed
                if nowDetectingSong % start detecting song
                    self.start_song_detection();
                else % turn off song detection
                    self.stop_song_detection();
                end
            end
        end
        function start_song_detection(self)
            assert(~self.detectionTimerValid, 'Song timer already exists');
            
        end
        function stop_song_detection(self)
            assert(self.detectionTimerValid, 'Song timer does not exist');
        end
        
        function append_experiment(self, Experiment)
        end
        function remove_experiment(self, experNo)
        end
        
        function suspend_experiments(self)
            maxTries = 100;
            if isempty(self.rememberedDetect)
                nExper = numel(self.Experiments);
                self.rememberedDetect = false(nExper, 1);
                for experNo = 1:nExper
                    self.rememberedDetect(experNo) = self.Experiments{experNo}.detectingSong;
                    status = false;
                    tryNo = 1;
                    while ~status && tryNo <= maxTries
                        status = self.Experiments{experNo}.change_detectingSong(false);
                        tryNo = tryNo + 1;
                    end
                    if ~status
                        error('Could not suspend experiments');
                    end
                end
            else
                warning('Experiments already suspended');
            end
        end
        
        function resume_experiments(self)
            maxTries = 100;
            if isempty(self.rememberedDetect)
                error('Cannot resume experiments: no remembered state');
            else
                for expNo = 1:numel(self.Experiments)
                    status = false;
                    tryNo = 1;
                    while ~status && tryNo <= maxTries
                        status = self.Experiments{expNo}.change_detectingSong(self.rememberedDetect(expNo));
                        tryNo = tryNo + 1;
                    end
                    if ~status
                        error('Could not resume experiments');
                    end
                end
            end
        end
        
        function reset_experiments(self)
            ClonedExperiments = cellfun(@SongTriggeredExperiment.clone_experiment, self.Experiments);
            cellfun(@delete, self.Experiments);
            self.Experiments = ClonedExperiments;
        end
        
        function set_restart(self)
            if self.isDaytime
                self.queue_night_timer()
            else
                self.suspend_experiments();
                self.queue_morning_timer();
            end
        end
        
        function queue_night_timer(self)
            if self.restartTimerValid
                error('Restart timer already exists');
            end
            if ~self.isDaytime
                error('Should be queueing morning timer instead');
            end
            CurrentTime = datetime();
            StopTime = CurrentTime;
            StopTime.Hour = self.stopHour;
            StopTime.Minute = 0;
            StopTime.Second = 0;
            self.RestartTimer = timer('Name', 'acqguiNightRestart', ...
                'TimerFcn', @self.restart_morning_callback, ...
                'ExecutionMode', 'singleShot', ...
                'BusyMode', 'queue');
            startat(self.RestartTimer, StopTime);
        end
        function queue_morning_timer(self)
            if self.restartTimerValid
                error('Restart timer already exists');
            end
            if self.isDaytime
                error('Should be queueing night timer instead');
            end
            CurrentTime = datetime();
            StartTime = CurrentTime;
            if CurrentTime.Hour >= self.startHour % restart happens tomorrow
                StartTime = StartTime + days(1);
            end
            StartTime.Hour = self.startHour;
            StartTime.Minute = 0;
            StartTime.Second = 0;
            self.RestartTimer = timer('Name', 'acqguiMorningRestart', ...
                'TimerFcn', @self.restart_morning_callback, ...
                'ExecutionMode', 'singleShot', ...
                'BusyMode', 'queue');
            startat(self.RestartTimer, StartTime);
        end
        
        function clear_restart(self)
            if self.restartTimerValid
                stop(self.RestartTimer);
                delete(self.RestartTimer);
            end
        end
        
        %% GUI and UI code
        function gui_init(self)
            %% Initialize GUI
            set(self.GuiFig, 'HandleVisibility', 'on');
            self.GuiFig.CloseRequestFcn = @(~, ~) self.delete();
            
            %% Initialize properties of UI elements
            set(self.GuiData.buttonTrigOnSong,'Enable','off');
            set(self.GuiData.buttonRecord,'Enable','off');
            fields = fieldnames(handles);
            for fieldNo = 1:numel(fields)
                UIControl = self.GuiData.(fields{fieldNo});
                if isprop(UIControl,'BusyAction')
                    set(UIControl,'BusyAction','cancel');
                end
                if isprop(UIControl,'Interruptible')
                    set(UIControl,'Interruptible','off');
                end
            end
            
            %% Set restart timer UI elements
            set(self.GuiData.editStartTime, 'String', num2str(self.startHour));
            set(self.GuiData.editStopTime, 'String', num2str(self.stopHour));
            set(self.GuiData.checkboxAutostart, 'Value', self.restartDaily);
        end
        function gui_exper(self)
        end
        function gui_stopdaq(self)
        end
        function gui_startdaq(self)
            set(self.GuiData.buttonRecord,'Enable','on');
        end
        function gui_wait_buffer(self)
            set(self.GuiData.buttonTrigOnSong,'Enable','off');
            set(self.GuiData.textRecordingStatus, 'String', 'Buffering for song detection but ready to record...');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'yellow');
        end
        function gui_buffering_complete(self)
            set(self.GuiData.textRecordingStatus, 'String', 'Ready to record and detect song');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'green');
            set(self.GuiData.buttonTrigOnSong,'Enable','on');
        end
    end
end