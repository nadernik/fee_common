classdef (Sealed) AcqGuiViews < handle
    properties
        GuiModel
        GuiFig
        GuiData
        AcqObj
        ExperManager
        SongMonitor
        RestartManager
        
        startNdx = 0;
        endNdx = 0;
    end
    properties (Access = private)
        CurrentExperimentListener
        DisplayedChannelListener
        DaqListener
        RestartListener
        RestartChangedListener
        ExpersChangedListener
        RecordingStatusListener
        DetectChangedListener
        PeekCompleteListener
        SongParamsListener
        StimListener
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
            self.SongParamsListener = addlistener(self.GuiModel, 'SongParametersChanged', @self.song_params);
            self.StimListener = addlistener(self.GuiModel, 'StimAvailable', @self.stim);
            self.CurrentExperimentListener = addlistener(self.GuiModel, 'CurrentExperimentChanged', @self.init_exper);
            self.DisplayedChannelListener = addlistener(self.GuiModel, 'DisplayedChannelsChanged', @self.update_displays);
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
            fields = fieldnames(self.GuiData);
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
            if self.AcqObj.daqRunning
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
        function init_exper(self, ~, ~)
            self.chan_strings();
            self.update_displays();
            self.file_properties();
        end
        function chan_strings(self)
            CurrExper = self.get_current_exper();
            nChan = numel(CurrExper.inChannels);
            chanStrings = cell(nChan, 1);
            chanStrings{1} = sprtintf('%d- audio', CurrExper.songHWChannel);
            chanStrings(2:end) = cellfun(@(x) sprintf('%d- other', x),...
                num2cell(CurrExper.nonSongHWChannels), 'UniformOutput', false);
            set(self.GuiData.popupAudio,'String', chanStrings);
            set(self.GuiData.popupChannel,'String', chanStrings);
            set(self.GuiData.popupChannel2,'String', chanStrings);
            set(self.GuiData.popupChannel3,'String', chanStrings);
        end
        
        function update_displays(self, ~, ExperEventObj)
            dispNos = ExperEventObj.nos;
            if self.GuiModel.recordingDisplayed
                
            else
                self.clear_displays();
            end
            self.display_popup(dispNos);
        end
        function clear_displays(self)
            cla(self.GuiData.axesAudio);
            cla(self.GuiData.axesSignal);
            cla(self.GuiData.axesSignal2);
            cla(self.GuiData.axesSignal3);
        end
        function display_chans(self, dispNos)
            
        end
        function display_popup(self, dispNos)
            for dNo = 1:numel(dispNos)
                thisDisp = dispNos(dNo);
                switch thisDisp
                    case 1
                        set(self.GuiData.popupAudio, 'Value', chanNdxs(1));
                    case 2
                        set(self.GuiData.popupChannel, 'Value', chanNdxs(2));
                    case 3
                        set(self.GuiData.popupChannel2, 'Value', chanNdxs(3));
                    case 4
                        set(self.GuiData.popupChannel3, 'Value', chanNdxs(4));
                    otherwise
                        error('Not a valid display channel');
                end
            end
        end
        
        function no_experiment(self)
            self.GuiModel.currentExperNdx = 0;
            self.GuiModel.experDisplayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
            self.GuiModel.displayRecordingNo = zeros(0, 1);% Nx1 matrix of file number to display
            self.startNdx = 0;
            self.endNdx = 0;
        end
        
        function update_channels(self, ~, ExperEventObj)
            self.chan_string_values();
        end
        
        function exper_strings(self)
            set(self.GuiData.popupExperiments, 'String', self.GuiData.ExperManager.experimentStrings);
        end
        function file_properties(self)
            if self.GuiModel.recordingDisplayed
                propertyNames = self.GuiModel.CurrentRecording.propertyNames;
                propertyValues = self.GuiModel.CurrentRecording.propertyValues;
                nPropName = numel(propertyNames);
                strList = cell(nPropName, 1);
                for propNo = 1:nPropName
                    strList{propNo} = sprtintf('%s: %s', ...
                        propertyNames{propNo}, propertyValues{propNo});
                end
                set(self.GuiData.listboxDatafileProperties, 'String', strList);
            end
        end
        function spectrogram(self)
            % Consider replacing displaySpecgramQuick with
            % updated_specgram_quick
            
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
        
        function request_stim(self, ~, ~)
            if self.GuiModel.recordingDisplayed
                set(self.GuiData.buttonAntidromic, 'String','Click on signal at threshold');
                set(self.GuiData.buttonAntidromic, 'BackgroundColor','red');
                [~, stimThresh] = ginput(1);
                set(self.GuiData.buttonAntidromic, 'String','Show aligned antidromic');
                set(self.GuiData.buttonAntidromic, 'BackgroundColor', [236/255, 233/255, 216/255]);
                self.GuiModel.antidromic(stimThresh);
            end
        end
        function stim(self, ~, ~)
            cla(self.GuiData.axes3);
            title(self.GuiData.axes3, ...
                sprintf('%d stims on chan %d',...
                size(self.GuiModel.stimClips, 2),...
                self.GuiModel.stimHwChan));
            if ~isempty(self.GuiModel.stimClips)
                plot(self.stimTimes, self.stimClips);
                xlim([self.stimTimes(1), self.stimTimes(end)]);
                ylim([-0.5, 0.5]);
                set(self.GuiData.axes3, 'ButtonDownFcn', @zoomboxCallback)
            end
        end
        
        function song_params(self, ~, ~)
            CurrExper = self.get_current_exper();
            set(self.GuiData.editPowerThres, 'String', num2str(CurrExper.ratioThreshold));
            set(self.GuiData.editSongDensity, 'String', num2str(CurrExper.songDensity));
            set(self.GuiData.editSongLength, 'String', num2str(CurrExper.songDuration));
        end
        
        function close_request(self, ~, ~)
            poisonPill = onCleanup(@() closereq());
            delete(self.GuiModel);
        end
        
        function axes_click_cb(self, src, ~)
            if self.GuiModel.recordingDisplayed
                CurrRecording = self.GuiModel.CurrentRecording;
                %If we successfully got the display data
                fs = CurrRecording.fileFs;
                
                mouseMode = get(self.GuiFig, 'SelectionType');
                clickLocation = get(src, 'CurrentPoint');
                
                switch mouseMode
                    case 'extend'
                        %shift click to zoom out
                        self.GuiModel.change_clip_range(1, CurrRecording.numSamples);
                    case 'normal'
                        %left click to zoom in.
                        rbbox();
                        endPoint = get(src, 'CurrentPoint');
                        point1 = clickLocation(1, 1); % extract x
                        point2 = endPoint(1, 1);
                        startTime = min(point1, point2); % calculate location
                        duration = abs(point1 - point2); % and box width
                        if duration / diff(xlim(src)) < .001 % 0.1 percent of the window -- probably just a 'click'
                            quarterWindow = round((self.GuiModel.endNdx - self.GuiModel.startNdx) / 4);
                            clickNdx = floor(startTime * fs) + 1;
                            newStartNdx = max(1, clickNdx - quarterWindow);
                            newEndNdx = min(ddd.lengthFile, clickNdx + quarterWindow);
                        else
                            newStartNdx = max(floor(startTime * fs) + 1, 1);
                            newEndNdx = min(floor((startTime + duration) * fs) + 1, CurrRecording.numSamples);
                        end
                        self.GuiModel.change_clip_range(newStartNdx, newEndNdx);
                end
            end
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
            self.song_params_off();
        end
        function daq_buffering(self)
            set(self.GuiData.buttonTrigOnSong,'Enable', 'off');
            set(self.GuiData.textRecordingStatus, 'String', 'Buffering for song detection but ready to record...');
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'yellow');
            set(self.GuiData.buttonRecord, 'String', 'Start Recording');
            set(self.GuiData.buttonRecord, 'Enable','on');
            self.song_params_ready();
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
            self.song_params_ready();
        end
        function daq_forced(self, fileNo)
            set(self.GuiData.textRecordingStatus, 'String', sprintf('Started forced recording %d.', fileNo));
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'cyan');
            set(self.GuiData.buttonRecord, 'String', 'Stop Recording');
            set(self.GuiData.buttonTrigOnSong, 'Enable','off');
            set(self.GuiData.buttonRecord, 'Enable','on');
            self.song_params_ready();
        end
        function daq_triggered(self, fileNo)
            set(self.GuiData.textRecordingStatus, 'String', sprintf('Started recording %d.', fileNo));
            set(self.GuiData.textRecordingStatus, 'BackgroundColor', 'red');
            set(self.GuiData.buttonRecord, 'String', 'Stop Recording');
            set(self.GuiData.buttonTrigOnSong, 'Enable','on');
            set(self.GuiData.buttonRecord, 'Enable','on');
            self.song_params_ready();
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
        
        function song_params_ready(self)
            set(self.GuiData.editPowerThres, 'Enable', 'on');
            set(self.GuiData.editSongDensity, 'Enable', 'on');
            set(self.GuiData.editSongLength, 'Enable', 'on');
        end
        function song_params_off(self)
            set(self.GuiData.editPowerThres, 'Enable', 'off');
            set(self.GuiData.editSongDensity, 'Enable', 'off');
            set(self.GuiData.editSongLength, 'Enable', 'off');
        end
        %% Set restart timer UI elements
        
    end
end