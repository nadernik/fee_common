classdef (Sealed) AcqGuiViews < handle
    properties
        GuiModel
        GuiFig
        GuiData
        AcqObj
        ExperimentManager
        SongMonitor
        RestartManager
        CurrentRecording
        
        startNdx = 0;
        endNdx = 0;
    end
    properties (Access = private)
        DaqListener
        RestartListener
        RestartChangedListener
        ExpersChangedListener
    end
    methods
        function self = AcqGuiViews(GuiModel, GuiFig)
            %% Set properties
            self.GuiModel = GuiModel;
            self.AcqObj = self.GuiModel.AcqObj;
            self.GuiFig = GuiFig;
            self.GuiData = guidata(GuiFig);
            self.ExperimentManager = self.AcqObj.ExperimentManager;
            self.SongMonitor = self.AcqObj.SongMonitor;
            self.RestartManager = self.AcqObj.RestartManager;
            
            
            self.DaqListener = addlistener(self.AcqObj, 'DaqChanged', @self.daq);
            self.RestartChangedListener = addlistener(self.RestartManager, ...
                'RestartChanged', @self.restart_changed);
            self.ExpersChangedListener = addlistener(self.ExperimentManager, 'ExperimentsChanged', @self.experiments);
            self.init();
            self.daq();
        end
        
        function init(self)
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
             
        end
        
        function daq(self, ~, ~) % Call back for DaqChanged events
            if self.GuiModel.daqRunning
                if self.GuiModel.AcqObj.isBuffering
                    self.daq_buffering();
                else
                    self.daq_ready();
                end
            else
                self.daq_stopped();
            end
        end
        function restart_changed(self, ~, ~)
            set(self.GuiData.editStartTime, 'String', num2str(self.RestartManager.startHour));
            set(self.GuiData.editStopTime, 'String', num2str(self.RestartManager.stopHour));
            set(self.GuiData.checkboxAutostart, 'Value', self.RestartManager.restartDaily);
        end
        function experiments(self, ~, ~)
            self.exper_strings();
        end
        function init_exper_view()
            self.experDisplayChannels(:, end + 1) = -1 * ones(1, 3);
            self.displayRecordingNo(end + 1) = 0;
            experNo = numel(self.Experiments);
            self.default_exper_display(experNo);
        end
        function no_experiment(self)
            self.GuiModel.currentExperNdx = 0;
            self.experDisplayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
            self.displayRecordingNo = zeros(0, 1);% Nx1 matrix of file number to display
            self.startNdx = 0;
            self.endNdx = 0;
        end
        
        
        function exper_strings(self)
            set(self.GuiData.popupExperiments, 'String', self.GuiData.ExperimentManager.experimentStrings);
        end
        function file_properties(self)
            nPropName = numel(self.propertyNames);
            strList = cell(nPropName, 1);
            for propNo = 1:nPropName
                strList{propNo} = sprtintf('%s: %s', ...
                    self.propertyNames{propNo}, self.propertyValues{propNo});
            end
            set(self.GuiData.listboxDatafileProperties, 'String', strList);
        end
        function spectrogram(self)
            % Consider replacing displaySpecgramQuick with
            % updated_specgram_quick
            if self.autoSpec
                
            end
        end
        function gui_signals(self)
        end
    end
    methods (Access = private)
        function daq_stopped(self)
            set(self.GuiData.buttonRecord, 'Enable', 'off');
            set(self.GuiData.textRecordingStatus, 'String', 'Daq stopped');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'yellow');
        end
        function daq_buffering(self)
            set(self.GuiData.buttonTrigOnSong,'Enable','off');
            set(self.GuiData.textRecordingStatus, 'String', 'Buffering for song detection but ready to record...');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'yellow');
        end
        function daq_ready(self)
            set(self.GuiData.textRecordingStatus, 'String', 'Ready to record and detect song');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'green');
            set(self.GuiData.buttonTrigOnSong,'Enable','on');
        end
        %% Set restart timer UI elements
        
    end
end