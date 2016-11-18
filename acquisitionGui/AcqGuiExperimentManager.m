classdef (Sealed) AcqGuiExperimentManager < handle
    properties (SetAccess = private)
        Experiments % N x 1 cell array of SongTriggeredExperiment objects
        experimentStrings % strings used to describe experiments
        songHWChannels = [];
        nonSongHWChannels = {};
        inChannels = [];
        commonFs
    end
    properties (SetAccess = private, Dependent = true)
        isEmpty
        daqValid
        anyRecording
        suspended
    end
    properties (Access = private)
        rememberedDetect
        DaqObj
        DetectionListeners
        RecStartedListeners
        RecCompleteListeners
        SongParametersListeners
        FilePropertyListeners
    end
    methods
        function self = AcqGuiExperimentManager(varargin)
            %% Parse inputs
            p = inputParser();
            p.KeepUnmatched = true;
            addParameter(p, 'Experiments', {});
            parse(p, varargin{:});
            Params = p.Results;
            
            %% Set parameters
            self.Experiments = Params.Experiments;
            
            %% Setup
            self.init();
        end
        
        function set_daq_params(self, DaqObj)
            self.DaqObj = DaqObj;
            cellfun(@(E) E.set_daq_params(DaqObj), self.Experiments);
        end
        function clear_daq(self)
            cellfun(@(E) E.clear_daq_params(), self.Experiments);
        end
        
         %% Methods to add or remove experiments
        function append_experiment(self, Experiment)
            assert(self.daqValid && ~self.DaqObj.isRunning, 'Cannot add experiment when DAQ is running');
            self.Experiments{end + 1} = Experiment;
            nExper = numel(self.Experiments);
            if ~isempty(self.rememberedDetect) && nExper > numel(self.rememberedDetect)
                self.rememberedDetect(end + 1) = false;
            end
            nIn = 1 + numel(Experiment.nonSongHWChannels); % Always have one song channel
            self.inChannels((end + 1):(end + nIn)) = Experiment.inChannels;
            self.check_consistency();
            self.songHWChannels(end + 1) = Experiment.songHWChannel;
            self.nonSongHWChannels{end + 1} = Experiment.nonSongHWChannels;
            self.DetectionListeners{end + 1} = addlistener(Experiment, 'DetectionChanged', @self.detection_changed_cb);
            self.RecCompleteListeners{end + 1} = addlistener(Experiment, 'RecordingComplete', @self.recording_complete_cb);
            self.RecStartedListeners{end + 1} = addlistener(Experiment, 'RecordingStarted', @self.recording_started_cb);
            self.SongParametersListeners{end + 1} = addlistener(Experiment, 'SongParametersChanged', @self.parameters_changed_cb);
            self.FilePropertyListeners{end + 1} = addlistener(Experiment, 'FilePropertiesChanged', @self.file_parameters_changed_cb);
            self.update_exper_strings();
            notify(self, 'ExperimentsChanged');
        end
        function remove_experiment(self, experNo)
            % Must be called when daq is stopped, and init_daq should be
            % called after all modifications to experiment list are made
            nExper = numel(self.Experiments);
            assert(nExper >= experNo && experNo >= 1, 'Cannot remove experiment as it does not exist');
            assert(self.daqValid && ~self.DaqObj.isRunning, 'Cannot remove experiments when DAQ is running');
            %% Remove data related to this experiment
            self.Experiments(experNo) = [];
            self.songHWChannels(experNo) = [];
            self.nonSongHWChannels(experNo) = [];
            delete(self.RecCompleteListeners{experNo});
            self.RecCompleteListeners(experNo) = [];
            delete(self.RecStartedListeners{experNo});
            self.RecStartedListeners(experNo) = [];
            delete(self.DetectionListeners{experNo});
            self.DetectionListeners(experNo) = [];
            delete(self.SongParametersListeners{experNo});
            self.SongParametersListeners(experNo) = [];
            if ~isempty(self.rememberedDetect) && nExper > numel(self.rememberedDetect)
                self.rememberedDetect(experNo) = [];
            end
            self.get_inchannels();
            self.update_exper_strings();
            notify(self, 'ExperimentsChanged');
        end
        
        %% Methods used by reset timer
        function reset_experiments(self)
            CachedDaqObj = self.DaqObj;
            self.clear_daq();
            ClonedExperiments = cellfun(@SongTriggeredExperiment.clone_experiment, self.Experiments);
            cellfun(@delete, self.Experiments);
            self.Experiments = ClonedExperiments;
            self.init();
            self.set_daq_params(CachedDaqObj);
            notify(self, 'ExperimentsReset');
            notify(self, 'ExperimentsChanged');
            % Should I check that they're all the same?
        end
        
        function suspend_experiments(self)
            maxTries = 100;
            if isempty(self.rememberedDetect)
                nExper = numel(self.Experiments);
                self.rememberedDetect = false(nExper, 1);
                for experNo = 1:nExper
                    self.rememberedDetect(experNo) = self.Experiments{experNo}.detectingSong;
                    status = false;
                    tryNo = 1;
                    while ~status && tryNo <= maxTries
                        status = self.Experiments{experNo}.change_detectingSong(false);
                        tryNo = tryNo + 1;
                    end
                    if ~status
                        error('Could not suspend experiments');
                    end
                end
            else
                warning('Experiments already suspended');
            end
        end
        function resume_experiments(self)
            maxTries = 100;
            if isempty(self.rememberedDetect)
                error('Cannot resume experiments: no remembered state');
            else
                for expNo = 1:numel(self.Experiments)
                    status = false;
                    tryNo = 1;
                    while ~status && tryNo <= maxTries
                        status = self.Experiments{expNo}.change_detectingSong(self.rememberedDetect(expNo));
                        tryNo = tryNo + 1;
                    end
                    if ~status
                        error('Could not resume experiments');
                    end
                end
                self.rememberedDetect = [];
            end
        end

        %% callbacks -- do not use externally
        function detection_changed_cb(self, SourceExper, ~)
            experNo = find_event_exper(self, SourceExper);
            notify(self, 'DetectionChanged', ExperEvent(experNo));
        end
        function recording_started_cb(self, SourceExper, ~)
            experNo = find_event_exper(self, SourceExper);
            notify(self, 'RecordingStarted', ExperEvent(experNo));
        end
        function recording_complete_cb(self, SourceExper, ~)
            experNo = find_event_exper(self, SourceExper);
            notify(self, 'RecordingComplete', ExperEvent(experNo));
        end
        function parameters_changed_cb(self, SourceExper, ~)
            experNo = find_event_exper(self, SourceExper);
            notify(self, 'SongParametersChanged', ExperEvent(experNo));
        end
        function file_parameters_changed_cb(self, SourceExper, ~)
            experNo = find_event_exper(self, SourceExper);
            notify(self, 'SongParametersChanged', ExperEvent(experNo));
        end
        
        %% Dependent getters
        function val = get.isEmpty(self)
            val = isempty(self.Experiments);
        end
        function val = get.daqValid(self)
            val = ~isempty(self.DaqObj);
        end
        function val = get.anyRecording(self)
            val = ~self.isEmpty && any(cellfun(@(E) E.isRecording, self.Experiments));
        end
        function val = get.suspended(self)
            val = ~self.isEmpty && ~isempty(self.rememberedDetect);
        end
    end
    methods (Access = private)
        function init(self)
            %% Check that these experiments have compatible Fs
            self.get_inchannels();
            self.check_consistency();
            self.songHWChannels = cellfun(@(E) E.songHWChannel, self.Experiments);
            self.nonSongHWChannels = cellfun(@(E) E.nonSongHWChannels, self.Experiments, 'UniformOutput', false);
            self.update_exper_strings();
            self.DetectionListeners = cellfun( ...
                @(E) addlistener(E, 'DetectionChanged', @self.detection_changed_cb), ...
                self.Experiments, ...
                'UniformOutput', false);
            self.RecStartedListeners = cellfun( ...
                @(E) addlistener(E, 'RecordingStarted', @self.recording_started_cb), ...
                self.Experiments, ...
                'UniformOutput', false);
            self.RecCompleteListeners = cellfun( ...
                @(E) addlistener(E, 'RecordingComplete', @self.recording_complete_cb), ...
                self.Experiments, ...
                'UniformOutput', false);
            self.SongParametersListeners = cellfun( ...
                @(E) addlistener(E, 'FilePropertiesChanged', @self.parameters_changed_cb), ...
                self.Experiments, ...
                'UniformOutput', false);
        end
        function get_inchannels(self)
            if ~self.isEmpty
                inChannels = cellfun(@(E) E.inChannels, self.Experiments, 'UniformOutput', false); %#ok<PROP>
                self.inChannels = vertcat(inChannels{:}); %#ok<PROP>
            else
                self.inChannels = [];
            end
        end
        function check_consistency(self)
            if ~isempty(self.Experiments)
                desiredFs = cellfun(@(E) E.desiredFs, self.Experiments);
                assert(all(desiredFs == desiredFs(1)), 'All experiments must have the same sampling rate');
                self.commonFs = desiredFs(1);
                assert(numel(self.inChannels) == numel(unique(self.inChannels)), 'Overlapping channels!');
            end
        end
        function update_exper_strings(self)
            if self.isEmpty
                self.experimentStrings = {''};
            else
                formatFun = @(E) sprintf('%s: %s', E.birdName, E.experName);
                self.experimentStrings = cellfun(formatFun, self.Experiments, 'UniformOutput', false);
            end
        end
        function experNo = find_event_exper(self, EventSource)
            experNo = find(self.Experiments == EventSource, 1, 'first');
        end
    end
    events (NotifyAccess = private)
        RecordingStarted
        RecordingComplete
        DetectionChanged
        ExperimentsChanged
        ExperimentsReset
        ExperStringsChanged
        SongParametersChanged
        FilePropertiesChanged
    end
end