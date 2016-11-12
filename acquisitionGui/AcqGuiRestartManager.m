classdef (Sealed) AcqGuiRestartManager < handle
    properties
        restartDaily
        startHour
        stopHour
    end
    properties (SetAccess = private, Dependent = true)
        isDaytime
        restartTimerValid
    end
    properties (Access = private)
        GuiModel
        RestartTimer
        rememberedDetect
    end
    methods
        function self = AcqGuiReset(GuiModel, restartDaily, startHour, stopHour)
            self.GuiModel = GuiModel;
            self.restartDaily = restartDaily;
            self.startHour = startHour;
            self.stopHour = stopHour;
            if self.restartDaily
                self.set_restart();
            end
        end
        
        %% Methods to start and stop daily restarts
        function set_restart(self)
            if self.isDaytime
                self.queue_night_timer()
            else
                self.suspend_experiments();
                self.queue_morning_timer();
            end
        end
        
        function clear_restart(self)
            if self.restartTimerValid
                stop(self.RestartTimer);
                delete(self.RestartTimer);
            end
        end
        
        %% Methods for callbacks -- do not use externally
        function restart_night_callback(self, ~, ~)
            if ~self.restartTimerValid
                error('Error with night restart timer');
            end
            delete(self.RestartTimer);
            self.suspend_experiments();
            self.queue_morning_timer();
        end
        function restart_morning_callback(self, ~, ~)
            if ~self.restartTimerValid
                error('Error with morning restart timer');
            end
            delete(self.RestartTimer);
            self.reset_experiments(); % Creates new experiments for the new day
            self.resume_experiments(); % Restores whatever triggering state they had before the night timer
            self.queue_night_timer(); % Start the night timer for later in the day
        end
        
        %% Dependent property getters
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
        function reset_experiments(self)
            ClonedExperiments = cellfun(@SongTriggeredExperiment.clone_experiment, self.GuiModel.Experiments);
            cellfun(@delete, self.GuiModel.Experiments);
            self.GuiModel.Experiments = ClonedExperiments;
        end
        
        function suspend_experiments(self)
            maxTries = 100;
            if isempty(self.rememberedDetect)
                nExper = numel(self.GuiModel.Experiments);
                self.rememberedDetect = false(nExper, 1);
                for experNo = 1:nExper
                    self.rememberedDetect(experNo) = self.GuiModel.Experiments{experNo}.detectingSong;
                    status = false;
                    tryNo = 1;
                    while ~status && tryNo <= maxTries
                        status = self.GuiModel.Experiments{experNo}.change_detectingSong(false);
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
                for expNo = 1:numel(self.GuiModel.Experiments)
                    status = false;
                    tryNo = 1;
                    while ~status && tryNo <= maxTries
                        status = self.GuiModel.Experiments{expNo}.change_detectingSong(self.rememberedDetect(expNo));
                        tryNo = tryNo + 1;
                    end
                    if ~status
                        error('Could not resume experiments');
                    end
                end
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
    end
end