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
        displayChannels = nan(4, 0); % 4xN matrix of HW channels to display for each of N experiments, -1 for nothing. First channel is audio channel.
        displayNdx = nan(4, 0);
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
    end
    methods
        function self = AcqGuiModel(varargin)
            p = inputParser();
            addParameter(p, 'autoUpdate', true); % determines if the spectrogram is automatically calculated for new recordings
            addParameter(p, 'maxLoadSize', 2000000); % maximum number of samples to load of a recording
            addParameter(p, 'DisplayChannels', {});
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
            self.init_recordings();
        end
        
        %% Buttons / high level actions -- maybe should be in separate controller
        function change_recording(self, recordingNo)
            % change the recording for the current experiment
            if self.currRecNo ~= recordingNo
                lastRecordingNo = self.currRecNo;
                PreviousRecording = self.CurrentRecording;
                try
                    self.currRecNo = recordingNo;
                    self.load_recording();
                catch ME
                    warning('%s : %s', ME.identifier, ME.message);
                    self.currRecNo = lastRecordingNo;
                    self.CurrentRecording = PreviousRecording;
                end
            end
        end
        function change_displayed_channel(self, displayNo, hwChannel)
            assert(displayNo >= 1 && displayNo <= 4, 'Not a valid display number');
            if self.displayChannels(displayNo, self.currentExperNdx) ~= hwChannel
                self.displayChannels(displayNo, self.currentExperNdx) = hwChannel;
                self.displayNdx(displayNo, self.currentExperNdx) = ...
                    find(self.CurrentExper.inChans == hwChannel, 1, 'first');
                self.load_channels(hwChannel);
            end
        end
        function status = load_experiment(self)
            status = self.AcqObj.suspend();
            if status
                [experFilename, experPath] = uigetfile('exper.mat', 'Choose an experiment file:');
                status = status && experFilename ~= 0;
                if status
                    fullPath = fullfile(experPath, experFilename);
                    [loadStatus, Exper] = SongTriggeredExperiment.load_experiment(fullPath, 'currentDir', experPath);
                    status = status && loadStatus;
                    if status
                        self.append_exper(Exper);
                        self.change_current_exper(numel(self.displayRecordingNo)); % most recent one
                    end
                end
                resumed = self.AcqObj.resume();
                assert(resumed, 'Could not resume the experiment!');
            end
        end
        function status = create_experiment(self)
            if self.AcqObj.daqRunning
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
                resumed = self.AcqObj.resume();
                assert(resumed, 'Could not resume the experiment!');
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
            self.stimHwChan = self.displayChannels(Params.dispChanNo, self.currentExperNdx);
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
                tmpRecNos = cellfun(@(E) E.lastFileNo, ...
                    self.AcqObj.ExperManager.Experiments);
                self.change_all_recordings(tmpRecNos);
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
    end
    methods (Access = private)
        function init_recordings(self)
            nExp = numel(self.AcqObj.ExperManager.Experiments);
            if nExp > 0
                self.displayChannels = nan(4, nExp);
                self.displayNdx = zeros(4, nExp);
                self.cLimits = nan(2, nExp);
                self.displayRecordingNo = zeros(nExp, 1);
                self.madeRecordings = false(nExp, 1);
                for expNo = 1:nExp
                    self.init_recording(expNo);
                end
                self.rec_complete_cb([], ExperEvent(1)); % Refresh last recorded file no's
            end
        end
        function init_recording(self, expNo)
            ThisExp = self.AcqObj.ExperManager.Experiments{expNo};
            self.displayChannels(:, expNo) = ThisExp.songHWChannel;
            self.displayRecordingNo(expNo) = ThisExp.lastFileNo;
            nNonSong = numel(ThisExp.nonSongHWChannels);
            nFill = min(nNonSong, 3);
            self.displayChannels(1 + (1:nFill), expNo) = ThisExp.nonSongHWChannels;
            for dispNo = 1:4
                self.displayNdx(dispNo, expNo) = ...
                    find(ThisExp.inChans == self.displayRecordingNo(dispNo, expNo), 1, 'first');
            end
        end
        function change_all_recordings(self, recordingsNos)
            self.change_recording(recordingsNos(self.currentExperNdx));
            self.displayRecordingNo = recordingsNos; % This is a weird way of doing this
        end
        function change_current_exper(self, experNo)
            self.currentExperNdx = experNo;
            self.load_recording(); % creates a CurrentRecordingChanged event
            notify(self, 'CurrentExperimentChanged');
            notify(self, 'DetectChanged');
        end
        function status = append_exper(self, Experiment)
            status = self.AcqObj.append_exper(Experiment);
            if status
                self.displayChannels(:, end + 1) = -1 * ones(4, 1);
                self.displayNdx(:, end + 1) = zeros(4, 1);
                self.cLimits(:, end + 1) = nan(2, 1);
                self.displayRecordingNo(end + 1) = -1;
                self.madeRecordings(end + 1) = false;
                self.init_recording(numel(self.displayRecordingNo));
            end
        end
        function status = remove_exper(self)
            currExperNo = self.currentExperNdx;
            status = self.AcqObj.remove_exper(currExperNo);
            if status
                self.displayChannels(:, currExperNo) = [];
                self.displayNdx(:, currExperNo) = [];
                self.cLimits(:, currExperNo) = [];
                self.displayRecordingNo(currExperNo) = [];
                self.madeRecordings(currExperNo) = [];
            end
        end
        function load_recording(self)
            if self.recordingDisplayed
                self.CurrentRecording = AcqGuiRecording(...
                    self.CurrentExper, ...
                    self.currRecNo, ...
                    'maxLoadSize', self.maxLoadSize);
                self.clip_ndx(1, self.CurrentRecording.numSamples);
                self.load_channels(self.displayChannels(:, self.currentExperNdx));
            else
                self.CurrentRecording = [];
            end
            notify(self, 'CurrentRecordingChanged');
        end
        function load_channels(self, hwChannels)
            self.CurrentRecording.load_channels(hwChannels);
            nChan = numel(hwChannels);
            changedDispChans = nan(nChan, 1);
            for chanNo = 1:nChan
                thisDisp = find(self.displayChannels == hwChannels(chanNo), 1, 'first');
                assert(~isempty(thisDisp), 'HW Channel not part of this experiment');
                changedDispChans(chanNo) = thisDisp;
            end
            notify(self, 'DisplayedChannelsChanged', ExperEvent(changedDispChans));
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