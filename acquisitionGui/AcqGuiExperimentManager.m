classdef (Sealed) AcqGuiExperimentManager < handle
    properties
        Experiments % N x 1 cell array of SongTriggeredExperiment objects
        experimentStrings % strings used to describe experiments
    end
    properties (Access = private)
        rememberedDetect
        GuiModel
    end
    methods
        function self = AcqGuiExperimentManager(GuiModel, varargin)
            self.GuiModel = GuiModel;
        end
         %% Methods to add or remove experiments
        function append_experiment(self, Experiment)
            assert(~self.DaqObj.isRunning, 'Cannot add experiment when DAQ is running');
            self.Experiments{end + 1} = Experiment;
            self.experDisplayChannels(:, end + 1) = -1 * ones(1, 3);
            self.displayRecordingNo(end + 1) = 0;
            experNo = numel(self.Experiments);
            self.default_exper_display(experNo);
            self.update_exper_strings();
        end
        function remove_experiment(self, experNo)
            % Must be called when daq is stopped, and init_daq should be
            % called after all modifications to experiment list are made
            nExper = numel(self.Experiments);
            assert(nExper >= experNo, 'Cannot remove experiment as it does not exist');
            assert(~self.DaqObj.isRunning, 'Cannot remove experiments when DAQ is running');
            
            %% Remove data related to this experiment
            self.Experiments(experNo) = [];
            self.experDisplayChannels(:, experNo) = [];
            self.displayRecordingNo(experNo) = [];
            
            %% Update current experiment, if necessary
            if experNo == self.currentExperNdx
                if nExper > experNo
                    self.switch_experiment(experNo);
                elseif nExper > 1
                    self.switch_experiment(experNo - 1);
                else
                    self.no_experiment()
                end
            elseif experNo < self.currentExperNdx
                self.switch_experiment(self.currentExperNdx - 1); % Because the current experiment has moved in the now shortened list
            end
        end
        function no_experiment(self)
            self.currentExperNdx = 0;
            self.experDisplayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
            self.displayRecordingNo = zeros(0, 1);% Nx1 matrix of file number to display
            self.startNdx = 0;
            self.endNdx = 0;
            self.update_exper_strings();
        end
        
        function reset_experiments(self)
            ClonedExperiments = cellfun(@SongTriggeredExperiment.clone_experiment, self.Experiments);
            cellfun(@delete, self.Experiments);
            self.Experiments = ClonedExperiments;
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
            end
        end

        function update_exper_strings(self)
            if isempty(self.Experiments)
                self.experimentStrings = {''};
            else
                formatFun = @(E) sprintf('%s: %s', E.birdName, E.experName);
                self.experimentStrings = cellfun(formatFun, self.Experiments, 'UniformOutput', false);
            end
        end
    end
end