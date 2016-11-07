classdef (Sealed) AcqGuiController < handle
    properties (Access = private)
        %% Gui
        GuiFig
        GuiData
        
        %% Experiment related properties
        Experiments = {}; % N x 1 cell array of SongTriggeredExperiment objects
        rememberedDetect = []; % N x 1 boolean array of songDetection states when experiments last suspended, empty if not suspended
        
        %% Display data
        currentExperNdx = 0;
        experDisplayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
        displayRecordingNo = nan(0, 1);% Nx1 matrix of file number to display
        startNdx = 0;
        endNdx = 0;
        
        %% Daq related properties
        DaqObj
        
        restartDaily
        startHour
        stopHour
        RestartTimer
        SongMonitoringTimer
    end
    properties (Access = private, Dependent = true)
        restartTimerValid
        isDaytime
    end
    methods
        function self = AcqGuiController(GuiFig, varargin)
            %% Parse inputs
            p = inputParser();
            addParameter(p, 'restartDaily', false);
            addParameter(p, 'startHour', 7);
            addParameter(p, 'stopHour', 23);
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.GuiFig = GuiFig;
            self.GuiData = guidata(self.GuiFig);
            self.experDisplayChannels = nan(3, 0);
            self.displayRecordingNo = nan(0, 1);
            self.startNdx = 0;
            self.endNdx = 0;
            self.restartDaily = Params.restartDaily;
            self.startHour = Params.startHour;
            self.stopHour = Params.stopHour;
            if self.restartDaily
                setMorningRestartTimer(GuiFig);
            end
            
            %% Set up GUI
            self.gui_init();
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
        function isDaytime = get.isDaytime(self)
            currentTime = datetime();
            isDaytime = currentTime.Hour >= self.startHour && ...
                currentTime.Hour <= self.stopHour;
        end
    end
    methods (Access = private)
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
                'TimerFcn', @self.restart_morning_callback);
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
                'TimerFcn', @self.restart_morning_callback);
            startat(self.RestartTimer, StartTime);
        end
        
        function clear_restart(self)
            if self.restartTimerValid
                stop(self.RestartTimer);
                delete(self.RestartTimer);
            end
        end
        
        function gui_init(self)
            %% Initialize GUI
            set(self.GuiFig, 'HandleVisibility', 'on');
            self.GuiFig.CloseRequestFcn = @(~, ~) self.delete();
            
            %% Initialize properties of UI elements
            set(self.GuiData.buttonTrigOnSong,'Enable','off');
            set(self.GuiData.buttonRecord,'Enable','off');
            set(self.GuiData.buttonTrigOnChan,'Enable','off');
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
            
            %% Initialize and start restart timer
            set(self.GuiData.editStartTime, 'String', num2str(self.startHour));
            set(self.GuiData.editStopTime, 'String', num2str(self.stopHour));
            set(self.GuiData.checkboxAutostart, 'Value', self.restartDaily);
        end
    end
end