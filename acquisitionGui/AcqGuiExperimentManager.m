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
            p = inputParser();
            p.keepUnmatched = true;
            addParameter(p, 'Experiments', {});
            parse(p, varargin{:});
            Params = p.Results;
            
            self.GuiModel = GuiModel;
            self.Experiments = Params.Experiments;
        end
        
         %% Methods to add or remove experiments
        function append_experiment(self, Experiment)
            assert(~self.DaqObj.isRunning, 'Cannot add experiment when DAQ is running');
            self.Experiments{end + 1} = Experiment;
            self.update_exper_strings();
            notify(self, 'ExperimentsChanged');
        end
        function remove_experiment(self, experNo)
            % Must be called when daq is stopped, and init_daq should be
            % called after all modifications to experiment list are made
            nExper = numel(self.Experiments);
            assert(nExper >= experNo, 'Cannot remove experiment as it does not exist');
            assert(~self.DaqObj.isRunning, 'Cannot remove experiments when DAQ is running');
            
            %% Remove data related to this experiment
            self.Experiments(experNo) = [];
            
            self.update_exper_strings();
            %% Update current experiment, if necessary
            if experNo == self.currentExperNdx
                if nExper > experNo
                    self.switch_experiment(experNo);
                elseif nExper > 1
                    self.switch_experiment(experNo - 1);
                else
                    self.no_experiment()
                end
                notify(self, 'ExerimentsChanged');
            elseif experNo < self.currentExperNdx
                self.switch_experiment(self.currentExperNdx - 1); % Because the current experiment has moved in the now shortened list
                notify(self, 'ExperimentsChanged');
            end
        end
        
        function switch_experiment(self, experNo)
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
    events (NotifyAccess = private)
        ExperimentsChanged
        ExperStringsChanged
    end
end