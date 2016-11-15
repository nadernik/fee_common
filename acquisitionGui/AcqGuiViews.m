classdef (Sealed) AcqGuiViews < handle
    properties
        GuiModel
        GuiFig
        GuiData
        AcqObj
        ExperManager
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
        RecordingStatusListener
        DetectChangedListener
        PeekCompleteListener
    end
    methods
        function self = AcqGuiViews(GuiModel, GuiFig, varargin)
            p = inputParser();
            parse(p, varargin{:});
            
            %% Set properties
            self.GuiModel = GuiModel;
            self.AcqObj = self.GuiModel.AcqObj;
            self.GuiFig = GuiFig;
            self.GuiData = guidata(GuiFig);
            
            self.ExperManager = self.AcqObj.ExperManager;
            self.SongMonitor = self.AcqObj.SongMonitor;
            self.RestartManager = self.AcqObj.RestartManager;
            
            %% Set up
            self.GuiFig.CloseRequestFcn = @self.close_request;
            self.DaqListener = addlistener(self.AcqObj, 'DaqChanged', @self.daq);
            self.RestartChangedListener = addlistener(self.RestartManager, ...
                'RestartChanged', @self.restart_changed);
            self.ExpersChangedListener = addlistener(self.ExperManager, 'ExperimentsChanged', @self.experiments);
            self.RecordingStatusListener = addlistener(self.GuiModel, 'RecordingStatusChanged', @self.recording);
            self.DetectChangedListener = addlistener(self.GuiModel, 'DetectChanged', @self.detect);
            self.PeekCompleteListener = addlistener(self.GuiModel, 'PeekComplete', @self.peek);
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
            self.restart_changed([], []);
        end
        
        function daq(self, ~, ~) % Call back for DaqChanged events
            if self.GuiModel.daqRunning
                if self.GuiModel.AcqObj.isBuffering
                    self.daq_buffering();
                elseif self.GuiModel.madeRecording(self.GuiModel.currentExperNdx)
                    currExper = self.ExperManager.Experiments{self.GuiModel.currentExperNdx};
                    self.daq_ready(currExper.lastFileNo);
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
            self.GuiModel.experDisplayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
            self.GuiModel.displayRecordingNo = zeros(0, 1);% Nx1 matrix of file number to display
            self.startNdx = 0;
            self.endNdx = 0;
        end
        
        
        function exper_strings(self)
            set(self.GuiData.popupExperiments, 'String', self.GuiData.ExperManager.experimentStrings);
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
        function recording(self, ~, ~)
            currExper = self.get_current_exper();
            if currExper.isRecording
                recNo = currExper.lastFileNo + 1;
                if currExper.forcedRecording
                    self.daq_forced(recNo);
                else
                    self.daq_triggered(recNo);
                end
            else
                self.daq([], []);
            end
        end
        function detect(self, ~, ~)
            currExper = self.get_current_exper();
            if currExper.detectingSong
                self.detect_running();
            else
                self.detect_off();
            end
        end
        function peek(self, ~, ~)
            currExper = self.get_current_exper();
            if currExper.detectingSong
                %% Heart beat
                if isequal(get(self.GuiData.textSongScore,'BackgroundColor'), [1, 1, 1])
                    set(self.GuiData.textSongScore,'BackgroundColor', [1, 1, 0.5]);
                else
                    set(self.GuiData.textSongScore,'BackgroundColor', [1, 1, 1]);
                end
                %% Display score
                if isnan(currExper.songScore)
                    scoreStr = '--';
                else
                    scoreStr = num2str(currExper.songScore);
                end
                set(self.GuiData.textSongScore, 'String', sprintf('Song Score: %s', scoreStr));
            end
        end
        function close_request(self, ~, ~)
            poisonPill = onCleanup(@() closereq());
            delete(self.GuiModel);
        end
    end
    methods (Access = private)
        %% private utilities
        function Exper = get_current_exper(self)
            Exper = self.ExperManager.Experiments{self.GuiModel.currentExperNdx};
        end
        %% Change display states
        function daq_stopped(self)
            set(self.GuiData.buttonRecord, 'Enable', 'off');
            set(self.GuiData.buttonTrigOnSong, 'Enable', 'off');
            set(self.GuiData.textRecordingStatus, 'String', 'Daq stopped');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'yellow');
        end
        function daq_buffering(self)
            set(self.GuiData.buttonTrigOnSong,'Enable', 'off');
            set(self.GuiData.textRecordingStatus, 'String', 'Buffering for song detection but ready to record...');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'yellow');
            set(self.GuiData.buttonRecord, 'String', 'Start Recording');
            set(self.GuiData.buttonRecord, 'Enable','on');
        end
        function daq_ready(self, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
                addOptional(p, 'fileNo', 0);
            end
            parse(p, varargin{:});
            fileNo = p.Results.fileNo;
            
            if fileNo > 0
                recString = sprtintf('Finished recording %d. ', fileNo);
            else
                recString = '';
            end
            
            set(self.GuiData.textRecordingStatus, 'String', sprintf('%sReady to record and detect song', recString));
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'green');
            set(self.GuiData.buttonRecord, 'String', 'Start Recording');
            set(self.GuiData.buttonTrigOnSong, 'Enable','on');
            set(self.GuiData.buttonRecord, 'Enable','on');
        end
        function daq_forced(self, fileNo)
            set(self.GuiData.textRecordingStatus, 'String', sprintf('Started forced recording %d.', fileNo));
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'cyan');
            set(self.GuiData.buttonRecord, 'String', 'Stop Recording');
            set(self.GuiData.buttonTrigOnSong, 'Enable','off');
            set(self.GuiData.buttonRecord, 'Enable','on');
        end
        function daq_triggered(self, fileNo)
            set(self.GuiData.textRecordingStatus, 'String', sprintf('Started recording %d.', fileNo));
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'red');
            set(self.GuiData.buttonRecord, 'String', 'Stop Recording');
            set(self.GuiData.buttonTrigOnSong, 'Enable','on');
            set(self.GuiData.buttonRecord, 'Enable','on');
        end
        
        function detect_off(self)
            set(self.GuiData.buttonTrigOnSong, 'Enable','on');
            set(self.GuiData.buttonTrigOnSong, 'String', 'Start Triggering on Song');
            set(self.GuiData.textSongScore, 'BackgroundColor', [1, 1, 0.5]);
            set(self.GuiData.textSongScore, 'String', 'Not Triggering on Song');
        end
        function detect_running(self)
            set(self.GuiData.buttonTrigOnSong, 'Enable','on');
            set(self.GuiData.buttonTrigOnSong, 'String', 'Stop Triggering on Song');
            set(self.GuiData.textSongScore, 'String', 'Waiting for data...');
        end
        %% Set restart timer UI elements
        
    end
end