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
        ExperimentManager
        RestartTimer
    end
    methods
        function self = AcqGuiRestartManager(ExperimentManager, varargin)
            %% Parse inputs
            p = inputParser();
            p.KeepUnmatched = true;
            addParameter(p, 'restartDaily', false);
            addParameter(p, 'startHour', 7);
            addParameter(p, 'stopHour', 23);
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.ExperimentManager = ExperimentManager;
            self.restartDaily = Params.restartDaily;
            self.startHour = Params.startHour;
            self.stopHour = Params.stopHour;
            
            %% Setup
            if self.restartDaily
                self.set_restart();
            end
        end
        
        %% Methods to start and stop daily restarts
        function set_restart(self)
            self.private_set_restart();
            notify(self, 'RestartChanged');
        end
        
        function clear_restart(self)
            self.private_clear_restart();
            notify(self, 'RestartChanged');
        end
        
        function change_restart(self)
            if self.restartDaily
                self.clear_restart();
            else
                self.set_restart();
            end
        end
        
        function change_restart_hours(self, startHour, stopHour)
            oldRestart = self.restartDaily;
            self.private_clear_restart();
            self.startHour = startHour;
            self.stopHour = stopHour;
            if oldRestart
                self.private_set_restart();
            end
            notify(self, 'RestartChanged');
        end
        
        %% Methods for callbacks -- do not use externally
        function restart_night_callback(self, ~, ~)
            if ~self.restartTimerValid
                error('Error with night restart timer');
            end
            delete(self.RestartTimer);
            self.ExperimentManager.suspend_experiments();
            self.queue_morning_timer();
        end
        function restart_morning_callback(self, ~, ~)
            if ~self.restartTimerValid
                error('Error with morning restart timer');
            end
            delete(self.RestartTimer);
            self.ExperimentManager.reset_experiments(); % Creates new experiments for the new day
            self.ExperimentManager.resume_experiments(); % Restores whatever triggering state they had before the night timer
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
        function private_set_restart(self)
            self.restartDaily = true;
            if self.isDaytime
                self.queue_night_timer()
            else
                self.ExperimentManager.suspend_experiments();
                self.queue_morning_timer();
            end
        end
        function private_clear_restart(self)
            self.restartDaily = false;
            if self.restartTimerValid
                stop(self.RestartTimer);
                delete(self.RestartTimer);
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
    events (NotifyAccess = private)
        RestartChanged
    end
end