classdef (Sealed) AcqGuiRestartManager < handle
    properties
        restartDaily
        StartTime % DateTime
        StopTime % DateTime
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
            addParameter(p, 'StartTime', datetime('today') + hours(7));
            addParameter(p, 'StopTime', datetime('today') + hours(23));
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.ExperimentManager = ExperimentManager;
            self.restartDaily = Params.restartDaily;
            self.StartTime = Params.StartTime;
            self.StopTime = Params.StopTime;
            
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
            NewStartTime = datetime('today') + hours(startHour);
            NewStopTime = datetime('today') + hours(stopHour);
            self.change_restart_time(NewStartTime, NewStopTime);
        end
        
        function change_restart_time(self, StartTime, StopTime)
            oldRestart = self.restartDaily;
            self.private_clear_restart();
            self.StartTime = StartTime;
            self.StopTime = StopTime;
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
        function val = get.isDaytime(self)
            CurrentTime = datetime('now');
            val = CurrentTime >= self.StartTime && ...
                CurrentTime <= self.StopTime;
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
            NewStopTime = datetime('today');
            NewStopTime.Hour = self.StopTime.Hour;
            NewStopTime.Minute = self.StopTime.Minute;
            NewStopTime.Second = self.StopTime.Second;
            self.RestartTimer = timer('Name', 'acqguiNightRestart', ...
                'TimerFcn', @self.restart_morning_callback, ...
                'ExecutionMode', 'singleShot', ...
                'BusyMode', 'queue');
            startat(self.RestartTimer, NewStopTime);
        end
        function queue_morning_timer(self)
            if self.restartTimerValid
                error('Restart timer already exists');
            end
            if self.isDaytime
                error('Should be queueing night timer instead');
            end
            if datetime('now') >= self.StartTime % restart happens tomorrow
                NewStartTime = datetime('tomorrow');
            else
                NewStartTime = datetime('today');
            end
            NewStartTime.Hour = self.StartTime.Hour;
            NewStartTime.Minute = self.StartTime.Minute;
            NewStartTime.Second = self.StartTime.Second;
            self.RestartTimer = timer('Name', 'acqguiMorningRestart', ...
                'TimerFcn', @self.restart_morning_callback, ...
                'ExecutionMode', 'singleShot', ...
                'BusyMode', 'queue');
            startat(self.RestartTimer, NewStartTime);
        end
    end
    events (NotifyAccess = private)
        RestartChanged
    end
end