classdef (Sealed) AcqGuiController < handle
    properties (Access = private)
        %% Gui
        GuiFig
        GuiData
        
        %% Experiment related properties
        Experiments
        
        %% Display data
        currentExperNdx
        experDisplayChannels % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
        displayRecordingNo % Nx1 matrix of file number to display
        startNdx
        endNdx
        
        %% Daq related properties
        DaqObj
        
        restartDaily
        startHour
        stopHour
        
        RestartTimer
        
        SongMonitoringTimer
    end
    methods
        function self = AcqGuiController(GuiFig, varargin)
            %% Parse inputs
            p = inputParser();
            addParameter(p, 'restartDaily', false);
            addParameter(p, 'startHour', 7);
            addParameter(p, 'stopHour', 22);
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set properties
            self.GuiFig = GuiFig;
            self.GuiData = guidata(self.GuiFig);
            self.Experiments = {};
            self.currentExperNdx = nan;
            self.experDisplayChannels = nan(3, 0);
            self.displayRecordingNo = nan(0, 1);
            self.startNdx = 0;
            self.endNdx = 0;
            self.restartDaily = Params.restartDaily;
            self.startHour = Params.startHour;
            self.stopHour = Params.stopHour;
            
            %% Initialize GUI
            set(GuiFig, 'HandleVisibility', 'on');
            GuiFig.CloseRequestFcn = @(~, ~) self.delete();
            
            %% Initialize properties of UI elements
            set(self.GuiData.buttonTrigOnSong,'Enable','off');
            set(self.GuiData.buttonRecord,'Enable','off');
            set(self.GuiData.buttonTrigOnChan,'Enable','off');
            fields = fieldnames(handles);
            for fieldNo = 1:numel(fields)
                UIControl = self.GuiData.(fields{fieldNo});
                if(isprop(UIControl,'BusyAction'))
                    set(UIControl,'BusyAction','cancel');
                end
                if(isprop(UIControl,'Interruptible'))
                    set(UIControl,'Interruptible','off');
                end
            end
            
            %% Initialize and start restart timer
            set(self.GuiData.editStartTime, 'String', num2str(self.startHour));
            set(self.GuiData.editStopTime, 'String', num2str(self.stopHour));
            set(self.GuiData.checkboxAutostart, 'Value', self.restartDaily);
            if self.restartDaily
                setMorningRestartTimer(GuiFig);
            end
        end
        
        function delete(self)
            % Clean up code
        end
    end
    methods (Access = private)
        function set_restart(self)
            %clear restart timer just in case.
            clearMorningRestartTimer();
            %build a timer that calls the restart function.
            self.RestartTimer = timer('Name', 'acqguiRestartInMorning', ...
                );
            set(self.RestartTimer,'TimerFcn','acqgui_restartGUI(timerfind(''Name'', ''acqguiRestartInMorning''), [], findobj(''Name'', ''acquisitionGui''))');
            set(self.RestartTimer,'Period',5);
            set(self.RestartTimer,'ExecutionMode','fixedDelay');
            set(self.RestartTimer,'BusyMode', 'queue');
            
            strStopHour = get(handles.editStopTime, 'String');
            stopHour = str2double(strStopHour);
            if(isempty(stopHour))
                uiwarn('Stop hour is invalid, Using 11pm');
                stopHour = 23;
            end
            stopTime = floor(now) + stopHour/24;
            if(stopTime < now)
                stopTime = stopTime + 1;
            end
            startat(RestartTimer, stopTime);
        end
        function clear_restart(self)
            %delete restart timer if there is one.
            if(~isempty(timerfind('Name','acqguiRestartInMorning')))
                stop(timerfind('Name','acqguiRestartInMorning'));
                delete(timerfind('Name','acqguiRestartInMorning'));
            end
        end
    end
end