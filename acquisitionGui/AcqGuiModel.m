classdef (Sealed) AcqGuiModel < handle
    properties
        autoUpdate
    end
    properties (SetAccess = private)
        AcqObj
        CurrentRecording
        
        maxLoadSize
        displayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, -1 for nothing
        displayRecordingNo = nan(0, 1);% Nx1 matrix of file number to display, -1 for nothing
        RecordingListener
        
        currentExperNdx = 0;
        startNdx = 0;
        endNdx = 0;
        
        %% Listeners
        RecStartedListener
        RecCompleteListener
        DetectChangedListener
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
            self.RecStartedListener = addlistener(self.AcqObj.ExperManager, 'RecordingStarted', @self.rec_started_callback);
            self.RecCompleteListener = addlistener(self.AcqObj.ExperManager, 'RecordingComplete', @self.rec_complete_callback);
            self.DetectChangedListener = addlistener(self.AcqObj.ExperManager, 'DetectionChanged', @self.detect_changed_callback);
            self.autoUpdate = Params.autoUpdate;
            self.maxLoadSize = Params.maxLoadSize;
        end
        
        function change_recording(self, recordingNo)
            if self.displayRecordingNo(self.currentExperNdx) ~= recordingNo
                self.displayRecordingNo(self.currentExperNdx) = recordingNo;
                self.load_recording();
            end
        end
        
        function change_displayed_channel(self, displayNo, hwChannel)
            assert(displayNo >= 1 && displayNo <= 3, 'Not a valid display number');
            if self.displayChannels(displayNo, self.currentExperNdx) ~= hwChannel
                self.displayChannels(displayNo, self.currentExperNdx) = hwChannel;
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
        function create_experiment(self)
            [status, Exper] = SongTriggeredExperiment.create_experiment_prompt();
            if status
                self.append_exper(Exper);
            end
        end
        function close_experiment(self)
            self.remove_exper();
        end
        function record_button(self)
            currExper = self.AcqObj.ExperManager.Experiments{self.currentExperNdx};
            if currExper.isRecording
                currExper.force_stop_recording();
            else
                currExper.force_stop_recording();
            end
        end
        
        function rec_complete_callback(self, ~, ExperEventObj)
            if ExperEventObj.experNo == self.currentExperNdx
                    notify(self, 'RecordingChanged');
            end
            if self.autoUpdate
                tmpRecNos = cellfun(@(E) E.lastFileNo, ...
                    self.AcqObj.ExperManager.Experiments);
                self.change_all_recordings(tmpRecNos);
                
            end
        end
        function rec_started_callback(self, ~, ExperEventObj)
            if ExperEventObj.experNo == self.currentExperNdx
                notify(self, 'RecordingChanged');
            end
        end
        function detect_changed_callback(self, ~, ExperEventObj)
            if ExperEventObj.experNo == self.currentExperNdx
                notify(self, 'DetectChanged');
            end
        end
    end
    methods (Access = private)
        function change_all_recordings(self, recordingsNos)
            self.change_recording(recordingsNos(self.currentExperNdx));
            self.displayRecordingNo = recordingsNos; % This is a weird way of doing this
        end
        function change_current_exper(self, experNo)
            self.currentExperNdx = experNo;
            self.load_recording();
        end
        function append_exper(self, Experiment)
            self.AcqObj.append_exper(Experiment);
            self.displayChannels(:, end + 1) = nan(3, 1);
            self.displayRecordingNo(end + 1) = Experiment.lastFileNo;
            % Update display state
        end
        function remove_exper(self)
            self.AcqObj.remove_exper(self.currentExperNdx);
            % Update display state
        end
        function load_recording(self)
            self.CurrentRecording = AcqGuiRecording(...
                self.AcqObj.ExperManager.Experiments{self.currentExperNdx}, ...
                self.displayRecordingNo(self.currentExperNdx), ...
                'maxLoadSize', self.maxLoadSize);
            notify(self, 'CurrentRecordingChanged');
            self.load_channels(self.displayChannels(:, self.currentExperNdx));
        end
        function load_channels(self, hwChannels)
            self.CurrentRecording.load_channels(hwChannels);
            notify(self, 'DisplayedChannelsChanged');
        end
    end
    events (NotifyAccess = private)
        CurrentRecordingChanged
        DisplayedChannelsChanged
        RecordingChanged
        DetectChanged
    end
end