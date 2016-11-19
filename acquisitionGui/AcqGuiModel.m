classdef (Sealed) AcqGuiModel < handle
    properties (SetObservable)
        autoUpdate
    end
    properties (SetAccess = private)
        AcqObj
        CurrentRecording
        
        stimClips
        stimTimes
        stimHwChan
        
        maxLoadSize
        displayHwChannels = nan(4, 0); % 4xN matrix of HW channels to display for each of N experiments, -1 for nothing. First channel is audio channel.
        displayChanNdx = nan(4, 0);
        displayRecordingNo = nan(0, 1);% Nx1 matrix of file number to display, 0 for nothing
        madeRecordings = false(0, 1);
        cLimits = nan(2, 0);
        
        currentExperNdx = 0;
        startNdx = 0;
        endNdx = 0;
        
        %% Listeners
        RecStartedListener
        RecCompleteListener
        DetectChangedListener
        PeekCompleteListener
        SongParametersListener
        RestartListener
        FilePropertiesListener
        
        output = {};% Not sure I need this?
    end
    properties (SetAccess = private, Dependent = true)
        recordingDisplayed
        CurrentExper
        currRecNo
        nExper
    end
    methods
        function self = AcqGuiModel(varargin)
            p = inputParser();
            addParameter(p, 'autoUpdate', true); % determines if the spectrogram is automatically calculated for new recordings
            addParameter(p, 'maxLoadSize', 2000000); % maximum number of samples to load of a recording
            addParameter(p, 'displayHwChannels', {});
            parse(p, varargin{:});
            Params = p.Results;
            
            self.AcqObj = AcqMaster(varargin{:}); % Make acquisition session
            self.RecStartedListener = addlistener(self.AcqObj.ExperManager, 'RecordingStarted', @self.rec_started_cb);
            self.RecCompleteListener = addlistener(self.AcqObj.ExperManager, 'RecordingComplete', @self.rec_complete_cb);
            self.DetectChangedListener = addlistener(self.AcqObj.ExperManager, 'DetectionChanged', @self.detect_changed_cb);
            self.PeekCompleteListener = addlistener(self.AcqObj.SongMonitor, 'PeekComplete', @self.peek_complete_cb);
            self.SongParametersListener = addlistener(self.AcqObj.ExperManager, 'SongParametersChanged', @self.song_parameters_cb);
            self.RestartListener = addlistener(self.AcqObj.ExperManager, 'ExperimentsReset', @self.restart_cb);
            self.FilePropertiesListener = addlistener(self.AcqObj.ExperManager, 'FilePropertiesChanged', @self.file_properties_cb);
            self.autoUpdate = Params.autoUpdate;
            self.maxLoadSize = Params.maxLoadSize;
            self.init_expers();
        end
        
        %% Buttons / high level actions -- maybe should be in separate controller
        function status = change_recording(self, recordingNo)
            % change the recording for the current experiment
            if self.currRecNo ~= recordingNo
                lastRecordingNo = self.currRecNo;
                self.displayRecordingNo(self.currentExperNdx) = ...
                    recordingNo;
                status = self.load_recording();
                if ~status
                    self.displayRecordingNo(self.currentExperNdx) = ...
                        lastRecordingNo;
                end
            else
                status = true;
            end
            if status
                notify(self, 'CurrentRecordingChanged');
            end
        end
        function change_displayed_channel(self, displayNo, hwChannel)
            if self.displayHwChannels(displayNo, self.currentExperNdx) ~= hwChannel
                self.set_displayed_channels(displayNo, hwChannel);
                self.load_channels();
                notify(self, 'DisplayedChannelsChanged', ExperEvent(displayNo));
            end
        end
        function allOk = load_experiment(self)
            wasRunning = self.AcqObj.daqRunning;
            if wasRunning
                allOk = self.AcqObj.suspend();
            else
                allOk = true;
            end
            if allOk
                [experFilename, experPath] = uigetfile('exper.mat', 'Choose an experiment file:');
                pathEntered = ~isequal(experFilename, 0);
                if pathEntered
                    fullPath = fullfile(experPath, experFilename);
                    [successfulLoad, Exper] = SongTriggeredExperiment.load_experiment(fullPath, 'currentDir', experPath);
                    if successfulLoad
                        self.append_exper(Exper);
                        self.change_current_exper(numel(self.displayRecordingNo)); % most recent one
                    else
                        allOk = false;
                    end
                end
                if wasRunning
                    resumed = self.AcqObj.resume();
                    assert(resumed, 'Could not resume the experiment!');
                end
            end
        end
        function status = create_experiment(self)
            wasRunning = self.AcqObj.daqRunning;
            if wasRunning
                status = self.AcqObj.suspend();
            else
                status = true;
            end
            if status
                dirname = uigetdir('', 'Select the root directory');
                if dirname == 0
                    status = false;
                else
                    [createStatus, Exper] = SongTriggeredExperiment.create_experiment_prompt();
                    if createStatus
                        self.append_exper(Exper);
                        self.change_current_exper(numel(self.displayRecordingNo)); % most recent one
                    else
                        status = false;
                    end
                end
                if wasRunning
                    resumed = self.AcqObj.resume();
                    assert(resumed, 'Could not resume the experiment!');
                end
            end
        end
        function status = close_experiment(self)
            if self.currentExperNdx > 0
                status = self.AcqObj.suspend();
                removed = self.remove_exper();
                if removed
                    nextExperNdx = self.currentExperNdx - 1;
                    assert(nextExperNdx >= 0, 'invalid experiment'); % Zero indicates no experiment
                    self.change_current_exper(nextExperNdx);
                else
                    status = false;
                end
                resumed = self.AcqObj.resume();
                assert(resumed, 'Could not resume the experiment!');
            else
                status = false;
            end
        end
        function record_button(self)
            currExper = self.CurrentExper;
            if currExper.isRecording
                currExper.force_stop_recording();
            else
                currExper.force_recording();
            end
        end
        function detect_button(self)
            currExper = self.CurrentExper;
            if currExper.detectingSong
                currExper.change_detectingSong(false);
            else
                currExper.change_detectingSong(true);
            end
        end
        function change_song_parameters(self, paramName, paramValue)
            self.CurrentExper.update_song_parameters(paramName, paramValue);
        end
        function antidromic(self, stimThresh, varargin)
            persistent p;
            if isempty(p)
                p = inputParser();
                addParameter(p, 'dispChanNo', 2);
                addParameter(p, 'preStimMs', 10);
                addParameter(p, 'postStimMs', 50);
                addParameter(p, 'maxStimPeakWidthMs', 1);
                addParameter(p, 'minStimSpacingSecs', .7);
            end
            parse(p, varargin{:});
            Params = p.Results;
            self.stimHwChan = self.displayHwChannels(Params.dispChanNo, self.currentExperNdx);
            sigNdx = find(self.CurrentRecording.signalChannels == self.stimHwChan, 1, 'first');
            self.stimClips = clipStimFromSignal(...
                self.CurrentRecording.signal(sigNdx), ...
                self.CurrrentRecording.fileFs, ...
                stimThresh, ...
                Params.preStimMs, ...
                Params.postStimMs, ...
                Params.maxStimPeakWidthMs, ...
                Params.minStimSpacingSecs);
            self.stimTimes = linspace(-Params.preStimMs, ...
                Params.postStimMs, size(self.stimClips, 1))';
            notify(self, 'StimAvailable');
        end
        
        function change_clip_range(self, startNdx, endNdx)
            self.clip_ndx(startNdx, endNdx); % Use private version for error checking
            notify(self, 'ClipRangeChanged'); % All displays affected
        end
        
        function change_climits(self, cLimits)
            self.cLimits(:, self.currentExperNdx) = cLimits;
            notify(self, 'CLimitsChanged');
        end
        
        %% Callbacks -- do not use externally
        function rec_complete_cb(self, ~, ExperEventObj)
            if ExperEventObj.nos == self.currentExperNdx
                    notify(self, 'RecordingStatusChanged');
            end
            self.madeRecordings(ExperEventObj.nos) = true;
            if self.autoUpdate
                self.refresh_last_recordings();
            end
        end
        function rec_started_cb(self, ~, ExperEventObj)
            if ExperEventObj.nos == self.currentExperNdx
                notify(self, 'RecordingStatusChanged');
            end
        end
        function detect_changed_cb(self, ~, ExperEventObj)
            if ExperEventObj.nos == self.currentExperNdx
                notify(self, 'DetectChanged');
            end
        end
        function peek_complete_cb(self, ~, ExperEventObj)
            if any(ExperEventObj.nos == self.CurrentExper.songHWChannel)
                notify(self, 'PeekComplete');
            end
        end
        function song_parameters_cb(self, ~, ExperEventObj)
            if ExperEventObj.nos == self.currentExperNdx
                notify(self, 'SongParametersChanged');
            end
        end
        function restart_cb(self, ~, ~)
            if ~self.AcqObj.ExperManager.isEmpty
                self.madeRecordings(:) = false;
                self.displayRecordingNo(:) = 0;
                notify(self, 'CurrentRecordingChanged');
            end
        end
        function file_properties_cb(self, ~, ExperEventObj)
            if ExperEventObj.nos == self.currentExperNdx
                notify(self, 'FilePropertiesChanged');
            end
        end
        
        %% Dependent getters
        function val = get.CurrentExper(self)
            val = self.AcqObj.ExperManager.Experiments{self.currentExperNdx};
        end
        function val = get.recordingDisplayed(self)
            val = ~self.AcqObj.ExperManager.isEmpty && ...
                self.currRecNo > 0;
        end
        function val = get.currRecNo(self)
            val = self.displayRecordingNo(self.currentExperNdx);
        end
        function val = get.nExper(self)
            val = numel(self.AcqObj.ExperManager.Experiments);
        end
    end
    methods (Access = private)
        function init_expers(self)
            nExp = numel(self.AcqObj.ExperManager.Experiments);
            if nExp > 0
                %% Allocate experiment variables
                self.displayHwChannels = nan(4, nExp);
                self.displayChanNdx = zeros(4, nExp);
                self.cLimits = nan(2, nExp);
                self.displayRecordingNo = zeros(nExp, 1);
                self.madeRecordings = false(nExp, 1);
                
                %% Initialize experiment variables
                for expNo = 1:nExp
                    self.init_exper(expNo);
                end
                self.change_current_exper(1);
            end
        end
        function init_exper(self, expNo)
            ThisExp = self.AcqObj.ExperManager.Experiments{expNo};
            self.displayRecordingNo(expNo) = ThisExp.lastFileNo;
            self.displayHwChannels(:, expNo) = ThisExp.songHWChannel;
            self.displayChanNdx(:, expNo) = 1;
            nNonSong = numel(ThisExp.nonSongHWChannels);
            nFill = min(nNonSong, 3);
            self.displayHwChannels(1 + (1:nFill), expNo) = ThisExp.nonSongHWChannels(1:nFill);
            self.displayChanNdx(1 + (1:nFill), expNo) = 1 + (1:nFill);
        end
        function refresh_last_recordings(self)
            tmpRecNos = cellfun(@(E) E.lastFileNo, ...
                    self.AcqObj.ExperManager.Experiments);
                self.change_all_recordings(tmpRecNos);
        end
        function change_all_recordings(self, recordingsNos)
            status = self.change_recording(recordingsNos(self.currentExperNdx));
            assert(status, 'Files do not exist');
            self.displayRecordingNo = recordingsNos; % This is a weird way of doing this
        end
        function change_current_exper(self, experNo)
            self.currentExperNdx = experNo;
            status = self.load_recording();
            assert(status, 'files do not exist');
            notify(self, 'CurrentExperimentChanged');
        end
        function status = append_exper(self, Experiment)
            status = self.AcqObj.append_exper(Experiment);
            if status
                self.displayHwChannels(:, end + 1) = -1 * ones(4, 1);
                self.displayChanNdx(:, end + 1) = zeros(4, 1);
                self.cLimits(:, end + 1) = nan(2, 1);
                self.displayRecordingNo(end + 1) = -1;
                self.madeRecordings(end + 1) = false;
                self.init_exper(self.nExper);
            end
        end
        function status = remove_exper(self)
            currExperNo = self.currentExperNdx;
            status = self.AcqObj.remove_exper(currExperNo);
            if status
                self.displayHwChannels(:, currExperNo) = [];
                self.displayChanNdx(:, currExperNo) = [];
                self.cLimits(:, currExperNo) = [];
                self.displayRecordingNo(currExperNo) = [];
                self.madeRecordings(currExperNo) = [];
            end
        end
        function status = load_recording(self)
            if self.recordingDisplayed
                NewRecording = AcqGuiRecording(...
                    self.CurrentExper, ...
                    self.currRecNo, ...
                    'maxLoadSize', self.maxLoadSize);
                if NewRecording.filesExist
                    status = true;
                    self.CurrentRecording = NewRecording;
                    self.clip_ndx(1, self.CurrentRecording.numSamples);
                    self.load_channels();
                else
                    status = false;
                end
            else
                status = true;
                self.CurrentRecording = [];
            end
        end
        function set_displayed_channels(self, displayNos, hwChannels)
            assert(all(displayNos >= 1) && all(displayNos <= 4), 'Not a valid display number');
            nDisp = numel(displayNos);
            inChans = self.CurrentExper.inChans;
            for dispInNo = 1:nDisp
                thisDisp = displayNos(dispInNo);
                if self.displayHwChannels(thisDisp, self.currentExperNdx) ~= hwChannel
                    hwNdx = find(inChans == hwChannels(dispInNo), 1, 'first');
                    assert(~isempty(hwNdx), 'Specified HW channel is not in experiment');
                    self.displayChanNdx(thisDisp, self.currentExperNdx) = hwNdx;
                    self.displayHwChannels(thisDisp, self.currentExperNdx) = hwChannels(dispInNo);
                end
            end
        end
        function load_channels(self)
            hwChannels = self.displayHwChannels(:, self.currentExperNdx);
            uniqueHwChans = unique(hwChannels);
            self.CurrentRecording.load_channels(uniqueHwChans);
        end
        function clip_ndx(self, startNdx, endNdx)
            if self.recordingDisplayed
                assert(startNdx > 0 && ...
                    startNdx <= endNdx && ...
                    endNdx <= self.CurrentRecording.numSamples, ...
                    'Clipping range is not valid');
                self.startNdx = startNdx;
                self.endNdx = endNdx;
            end
        end
    end
    events (NotifyAccess = private)
        CurrentExperimentChanged
        CurrentRecordingChanged
        DisplayedChannelsChanged
        RecordingStatusChanged
        DetectChanged
        PeekComplete
        SongParametersChanged
        StimAvailable
        ClipRangeChanged
        CLimitsChanged
        FilePropertiesChanged
    end
end