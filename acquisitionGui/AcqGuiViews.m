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
        DisplayedRecordingListener
        DaqListener
        RestartListener
        RestartChangedListener
        ExpersChangedListener
        RecordingStatusListener
        DetectChangedListener
        PeekCompleteListener
        SongParamsListener
        StimListener
        RangeListener
        AutoUpdateListener
        FilePropertiesListener
        CLimitsListener
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
            self.ExpersChangedListener = addlistener(self.ExperManager, 'ExperimentsChanged', @self.experiments_changed);
            self.RecordingStatusListener = addlistener(self.GuiModel, 'RecordingStatusChanged', @self.recording_status);
            self.DetectChangedListener = addlistener(self.GuiModel, 'DetectChanged', @self.detect_changed);
            self.PeekCompleteListener = addlistener(self.GuiModel, 'PeekComplete', @self.peek);
            self.SongParamsListener = addlistener(self.GuiModel, 'SongParametersChanged', @self.song_params);
            self.StimListener = addlistener(self.GuiModel, 'StimAvailable', @self.stim);
            self.CurrentExperimentListener = addlistener(self.GuiModel, 'CurrentExperimentChanged', @self.init_exper);
            self.DisplayedChannelListener = addlistener(self.GuiModel, 'DisplayedChannelsChanged', @self.displayed_channel_changed);
            self.RangeListener = addlistener(self.GuiModel, 'ClipRangeChanged', @self.clip_range);
            self.DisplayedRecordingListener = addlistener(self.GuiModel, 'CurrentRecordingChanged', @self.displayed_recording);
            self.AutoUpdateListener = addlistener(self.GuiModel, 'autoUpdate', 'PostSet', @self.auto_update);
            self.FilePropertiesListener = addlistener(self.GuiModel, 'FilePropertiesChanged', @self.file_properties);
            self.CLimitsListener = addlistener(self.GuiModel, 'CLimitsChanged', @self.clim);
            self.init();
            self.daq();
        end
        
        function init(self)
            %% Initialize GUI
            set(self.GuiFig, 'HandleVisibility', 'on');
            
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
            self.restart_changed();
        end
        
        %% Button click views
        function display_filesperhour(self)
            CurrExper = self.GuiModel.CurrentExper;
            [~, ~, chanNumbers, creationTimes] = CurrExper.find_all_files();
            audMask = chanNumbers == CurrExper.songHWChannel;
            audCreationTimes = creationTimes(audMask);
            hours = [audCreationTimes.Hour] + [audCreationTimes.Minute] ./ 60;
            Ax = handles.GuiData.axes3;
            cla(Ax)
            histogram(Ax, hours);
            xlabel(Ax, 'hours');
            ylabel(Ax, 'files');
        end
        function play_audio(self, dispNo)
            if self.GuiModel.recordingDisplayed
                Ax = get_display_axes(self, dispNo);
                CurrRec = self.GuiModel.CurrentRecording;
                signal = CurrRec.signals{self.GuiModel.displayChanNdx(dispNo, self.currentExperNdx)};
                range = max(max(signal), abs(min(signal)));
                normedSig = signal / (range * 3);
                
                player = audioplayer(normedSig, CurrRec.fileFs);
                hold(Ax, 'on');
                xBnds= xlim(Ax);
                yBnds = ylim(Ax);
                LHandle = line(xBnds(1) * ones(2, 1), yBnds, 'Color', 'yellow');
                
                play(player);
                while isplaying(player)
                    currTime = xBnds(1) + get(player, 'CurrentSample') / CurrRec.fileFs;
                    set(LHandle, 'XData', currTime * ones(2, 1));
                    drawnow();
                end
                delete(LHandle);
                hold(Ax, 'off');
            end
        end
        function running_song_score(self)
            if self.GuiModel.recordingDisplayed
                CurrRec = self.GuiModel.CurrentRecording;
                CurrExper = self.GuiModel.CurrentExper;
                [~, ~, ~, songRatio, songDetect] = songDetector5(...
                    CurrRec.signal{1}, CurrRec.fileFs,...
                    CurrExper.songDuration,...
                    CurrExper.songDensity,...
                    CurrExper.ratioThreshold,...
                    CurrExper.minFreq,...
                    CurrExper.maxFreq, false);
                Ax = self.GuiData.axes3;
                cla(Ax);
                hold(Ax, 'on');
                plot(Ax, songRatio, 'r');
                plot(Ax, songDetect * 10, 'b');
                axis(Ax, 'tight');
                ylim(Ax, [0, 10]);
                xBnds = xlim(Ax);
                line(Ax, xBnds, CurrExper.ratioThreshold * ones(1, 2), 'Color', 'red');
                line(Ax, xBnds, 10 * CurrExper.songDensity * ones(1, 2), 'Color', 'blue');
                legend(Ax, 'powerRatio', 'score');
                hold(Ax, 'off');
            end
        end
        
        %% Input dialogs / functions
        function make_comment(self)
            currRecNo = self.GuiModel.currRecNo;
            commentStr = get(self.GuiData.editDatafileComment, 'String');
            if ~isempty(commentStr) && any(~isspace(commentStr)) && currRecNo > 0
                status = self.GuiModel.CurrentExper.append_file_property(currRecNo, 'Comment', commentStr);
                if status
                    set(self.GuiData.editDatafileComment, 'String', '');
                end
            end
        end
        function set_spectrogram_clim(self)
            cLim = self.GuiModel.cLimits(:, self.GuiModel.currentExperNdx);
            prompt = {'Enter floor:', 'Enter ceiling:'};
            dlg_title = 'Input audio axis color range';
            num_lines = 1;
            if any(isnan(cLim))
                defaults = {'', ''};
            else
                defaults = {num2str(cLim(1)), num2str(cLim(2))};
            end
            answer = inputdlg(prompt, dlg_title, num_lines, defaults);
            if ~isempty(answer) && all(~cellfun(@isempty, answer))
                newCLim = cellfun(@str2double, answer); 
                if all(~isnan(newCLim))
                    self.GuiModel.change_climits(newCLim);
                end
            end
        end
        function change_recording_params(self)
            if ~self.ExperManager.isEmpty
                CurrExper = self.GuiModel.CurrentExper;
                promptStr = {'Pre Trigger Secs:', 'Post Trigger Secs:', 'Max File Length:'};
                dlgTitle = 'Input Recording Parameters:';
                num_lines = 1;
                defaultVals = {num2str(CurrExper.preSongSeconds),...
                    num2str(CurrExper.postSongSeconds),...
                    num2str(CurrExper.maxFileDuration)};
                answerCell = inputdlg(promptStr,dlgTitle,num_lines,defaultVals);
               
                if ~isempty(answerCell)
                    preSecs = str2double(answerCell{1});
                    postSecs = str2double(answerCell{2});
                    maxDuration = str2double(answerCell{3});
                    if ~isnan(preSecs) && ~isnan(preSecs) && ~isnan(maxDuration)
                        CurrExper.preSongSeconds = preSecs;
                        CurrExper.postSongSeconds = postSecs;
                        CurrExper.maxFileDuration = maxDuration;
                    else
                        warning('Invalid input');
                    end
                end
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
        
        %% Model event callbacks
        function experiments_changed(self, ~, ~)
            self.exper_strings();
            if self.GuiModel.nExper == 0
                self.clear_displays();
            end
        end
        function init_exper(self, ~, ~)
            self.exper_val();
            self.chan_strings();
            self.recording_status();
            self.detect_changed();
            self.displayed_recording();
        end
        function detect_changed(self, ~, ~)
            currExper = self.get_current_exper();
            if ~isempty(currExper) && currExper.detectingSong
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
        function recording_status(self, ~, ~)
            currExper = self.get_current_exper();
            if ~isempty(currExper) && currExper.isRecording
                recNo = currExper.lastFileNo + 1;
                if currExper.forcedRecording
                    self.daq_forced(recNo);
                else
                    self.daq_triggered(recNo);
                end
            else
                self.daq();
            end
        end
        function daq(self, ~, ~) % Call back for DaqChanged events
            if self.AcqObj.daqRunning
                if self.GuiModel.AcqObj.isBuffering
                    self.daq_buffering();
                elseif self.GuiModel.currentExperNdx > 0 && self.GuiModel.madeRecordings(self.GuiModel.currentExperNdx)
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
            set(self.GuiData.editStartTime, 'String', num2str(self.RestartManager.startTime.Hour));
            set(self.GuiData.editStopTime, 'String', num2str(self.RestartManager.stopTime.Hour));
            set(self.GuiData.checkboxAutostart, 'Value', self.RestartManager.restartDaily);
        end
        function displayed_recording(self, ~, ~)
            self.recno_string();
            self.update_displays(1:4);
            self.file_properties();
        end
        function displayed_channel_changed(self, ~, ExperEventObj)
            dispNos = ExperEventObj.nos;
            self.update_displays(dispNos);
        end
        function clim(self, ~, ~)
            if self.GuiModel.recordingDisplayed
                startTime = self.get_current_starttime();
                self.display_spec(startTime);
            end
        end
        function song_params(self, ~, ~)
            CurrExper = self.get_current_exper();
            set(self.GuiData.editPowerThres, 'String', num2str(CurrExper.ratioThreshold));
            set(self.GuiData.editSongDensity, 'String', num2str(CurrExper.songDensity));
            set(self.GuiData.editSongLength, 'String', num2str(CurrExper.songDuration));
        end
        function auto_update(self, ~, ~)
            self.GuiData.checkboxAutoDisplay.Value = self.GuiModel.autoUpdate;
        end
        function clip_range(self, ~, ~)
            if self.GuiModel.recordingDisplayed
                self.display_chans(1:4);
            end
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
        
        %% View callbacks
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
                            newEndNdx = min(CurrRecording.numSamples, clickNdx + quarterWindow);
                        else
                            newStartNdx = max(floor(startTime * fs) + 1, 1);
                            newEndNdx = min(floor((startTime + duration) * fs) + 1, CurrRecording.numSamples);
                        end
                        self.GuiModel.change_clip_range(newStartNdx, newEndNdx);
                end
            end
        end
        function close_request(self, src, ~)
            poisonPill = onCleanup(@() delete(src));
            delete(self.GuiModel);
        end
    end
    methods (Access = private)
        %% private utilities
        function Ax = get_display_axes(self, dispNo)
            switch dispNo
                case 1
                    Ax = self.GuiData.axesAudio;
                case 2
                    Ax = self.GuiData.axesSignal;
                case 3
                    Ax = self.GuiData.axesSignal2;
                case 4
                    Ax = self.GuiData.axesSignal3;
                otherwise
                    error('Not a valid display channel');
            end
        end
        function Exper = get_current_exper(self)
            currExperNo = self.GuiModel.currentExperNdx;
            if currExperNo > 0
                Exper = self.ExperManager.Experiments{self.GuiModel.currentExperNdx};
            else
                Exper = [];
            end
        end
        function startTime = get_current_starttime(self)
            startTime = (self.GuiModel.startNdx - 1) ...
                ./ self.GuiModel.CurrentRecording.fileFs;
        end
        function val = get_popup_handle(self, dispNo)
            switch dispNo
                case 1
                    val = self.GuiData.popupAudio;
                case 2
                    val = self.GuiData.popupChannel;
                case 3
                    val = self.GuiData.popupChannel2;
                case 4
                    val = self.GuiData.popupChannel3;
            end
        end
        %% Change display states
        function exper_strings(self)
            currVal = self.GuiData.popupExperiments.Value;
            experStr = self.ExperManager.experimentStrings;
            nExperStr = numel(experStr);
            if currVal > nExperStr
                self.GuiData.popupExperiments.Value = nExperStr;
            end
            self.GuiData.popupExperiments.String = experStr;
        end
        function exper_val(self)
            if ~self.ExperManager.isEmpty
                set(self.GuiData.popupExperiments, 'Value', self.GuiModel.currentExperNdx);
            else
                set(self.GuiData.popupExperiments, 'Value', 1);
            end
        end
        function recno_string(self)
            if self.GuiModel.currentExperNdx > 0
                thisRecNo = self.GuiModel.currRecNo;
                recNoStr = num2str(thisRecNo); 
            else
                recNoStr = '--';
            end
            set(self.GuiData.editFilenum, 'String', recNoStr); 
        end
        function update_displays(self, dispNos)
            self.selected_channels(dispNos);
            if self.GuiModel.recordingDisplayed
                self.display_chans(dispNos);
            else
                self.clear_displays();
            end
        end
        function display_chans(self, dispNos)
            CurrRec = self.GuiModel.CurrentRecording;
            startTime = self.get_current_starttime();
            for dNo = 1:numel(dispNos)
                thisDisp = dispNos(dNo);
                if thisDisp == 1
                    self.display_spec(startTime);
                elseif thisDisp > 1 && thisDisp <= 4
                    Ax = self.get_display_axes(thisDisp);
                    sigNo = self.GuiModel.displayChanNdx(thisDisp, self.GuiModel.currentExperNdx);
                    signal = CurrRec.signals{sigNo}(self.GuiModel.startNdx:self.GuiModel.endNdx);
                    self.display_signal(Ax, signal, startTime);
                else
                    error('%d is not a valid display channel', thisDisp);
                end
            end
        end
        function clear_displays(self)
            cla(self.GuiData.axesAudio);
            cla(self.GuiData.axesSignal);
            cla(self.GuiData.axesSignal2);
            cla(self.GuiData.axesSignal3);
        end
        function selected_channels(self, dispNos)
            experNo = self.GuiModel.currentExperNdx;
            haveExper = experNo > 0;
            for dNo = 1:numel(dispNos)
                thisDisp = dispNos(dNo);
                PopupHandle = self.get_popup_handle(thisDisp);
                if haveExper
                    PopupHandle.Value = self.GuiModel.displayChanNdx(thisDisp, experNo);
                else
                    PopupHandle.Value = 1;
                end
            end
        end
        function display_spec(self, startTime)
            Ax = self.GuiData.axesAudio;
            delete(Ax.UserData);
            cla(Ax);
            CurrRec = self.GuiModel.CurrentRecording;
            CurrExper = self.GuiModel.CurrentExper;
            CurrExperNo = self.GuiModel.currentExperNdx;
            sigNo = self.GuiModel.displayChanNdx(1, CurrExperNo);
            rawSig = CurrRec.signals{sigNo}(self.GuiModel.startNdx:self.GuiModel.endNdx);
            normedSig = rawSig - mean(rawSig); % Necessary?
            cLim = self.GuiModel.cLimits(:, CurrExperNo);
            if any(isnan(cLim))
                cLim = [];
            end
            SpectrogramDisplay(Ax, normedSig, CurrRec.fileFs, 'cLimits', cLim, 'startTime', startTime);
            title(Ax, sprintf('%s %s %d %s', CurrExper.birdName,...
                CurrExper.experName, ...
                self.GuiModel.currRecNo, ...
                datestr(CurrRec.fileCreationTime)));
            set(Ax, 'ButtonDownFcn', @self.axes_click_cb);
            set(self.GuiFig, 'SizeChangedFcn', '');
        end
        function display_signal(self, Ax, signal, startTime)
            cla(Ax);
            fileFs = self.GuiModel.CurrentRecording.fileFs;
            SignalBoundsDisplay(Ax, signal, fileFs, 'startTime', startTime);
            axis(Ax, 'tight');
            set(Ax,'ButtonDownFcn', @self.axes_click_cb);
            set(Ax, 'XTickLabel', []);
        end
        function chan_strings(self)
            if ~self.ExperManager.isEmpty
                CurrExper = self.get_current_exper();
                nChan = numel(CurrExper.inChannels);
                chanStrings = cell(nChan, 1);
                chanStrings{1} = sprintf('%d- audio', CurrExper.songHWChannel);
                chanStrings(2:end) = cellfun(@(x) sprintf('%d- other', x),...
                    num2cell(CurrExper.nonSongHWChannels), 'UniformOutput', false);
            else
                chanStrings = {''};
            end
            set(self.GuiData.popupAudio,'String', chanStrings);
            set(self.GuiData.popupChannel,'String', chanStrings);
            set(self.GuiData.popupChannel2,'String', chanStrings);
            set(self.GuiData.popupChannel3,'String', chanStrings);
        end
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
                recString = sprintf('Finished recording %d. ', fileNo);
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
        
    end
end