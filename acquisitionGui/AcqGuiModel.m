classdef (Sealed) AcqGuiModel < handle
    properties
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
        displayRecordingNo = nan(0, 1);% Nx1 matrix of file number to display, -1 for nothing
        madeRecordings = false(0, 1);
        RecordingListener
        
        currentExperNdx = 0;
        startNdx = 0;
        endNdx = 0;
        
        %% Listeners
        RecStartedListener
        RecCompleteListener
        DetectChangedListener
        PeekCompleteListener
        SongParametersListener
        
        output = {};% Not sure I need this?
    end
    properties (SetAccess = private, Dependent = true)
        recordingDisplayed
        CurrentExper
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
            self.autoUpdate = Params.autoUpdate;
            self.maxLoadSize = Params.maxLoadSize;
            self.init_recordings();
        end
        
        %% Buttons / high level actions -- maybe should be in separate controller
        function change_recording(self, recordingNo)
            if self.displayRecordingNo(self.currentExperNdx) ~= recordingNo
                self.displayRecordingNo(self.currentExperNdx) = recordingNo;
                self.load_recording();
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
        function load_experiment(self)
            [experFilename, experPath] = uigetfile('exper.mat', 'Choose an experiment file:');
            if experFilename ~= 0
                fullPath = fullfile(experPath, experFilename);
                Exper = SongTriggeredExperiment.load_experiment(fullPath, 'currentDir', experPath);
                self.append_exper(Exper);
            end
        end
        function status = create_experiment(self)
            [status, Exper] = SongTriggeredExperiment.create_experiment_prompt();
            if status
                self.append_exper(Exper);
                self.change_current_exper(numel(self.displayRecordingNo)); % most recent one
            end
        end
        function close_experiment(self)
            self.remove_exper();
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
        
        %% Callbacks -- do not use externally
        function rec_complete_cb(self, ~, ExperEventObj)
            if ExperEventObj.nos == self.currentExperNdx
                    notify(self, 'RecordingStatusChanged');
            end
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
            if ExperEventObj.nos == sulf.currentExperNdx
                notify(self, 'SongParametersChanged');
            end
        end
        
        %% Dependent getters
        function val = get.CurrentExper(self)
            val = self.AcqObj.ExperManager.Experiments{self.currentExperNdx};
        end
        function val = get.recordingDisplayed(self)
            val = ~isempty(self.AcqObj.Experiments) && ...
                self.displayRecordingNo(self.currentExperNdx) > 0;
        end
    end
    methods (Access = private)
        function init_recordings(self)
            nExp = numel(self.AcqObj.ExperManager.Experiments);
            if nExp > 0
                self.displayChannels = nan(4, nExp);
                self.displayNdx = zeros(4, nExp);
                self.displayRecordingNo = nan(nExp, 1);
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
            self.load_recording();
            notify(self, 'CurrentExperimentChanged');
            notify(self, 'DetectChanged');
        end
        function append_exper(self, Experiment)
            self.AcqObj.append_exper(Experiment);
            self.displayChannels(:, end + 1) = -1 * ones(4, 1);
            self.displayNdx(:, end + 1) = zeros(4, 1);
            self.displayRecordingNo(end + 1) = -1;
            self.madeRecordings(end + 1) = false;
            self.init_recording(numel(self.displayRecordingNo));
            % Update display state
        end
        function remove_exper(self)
            self.AcqObj.remove_exper(self.currentExperNdx);
            % Update display state
        end
        function load_recording(self)
            self.CurrentRecording = AcqGuiRecording(...
                self.CurrentExper, ...
                self.displayRecordingNo(self.currentExperNdx), ...
                'maxLoadSize', self.maxLoadSize);
            self.clip_ndx(1, self.CurrentRecording.numSamples);
            notify(self, 'CurrentRecordingChanged');
            self.load_channels(self.displayChannels(:, self.currentExperNdx));
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
    end
end