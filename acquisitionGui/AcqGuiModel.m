classdef (Sealed) AcqGuiModel < handle
    properties (SetAccess = private)
        AcqObj
        CurrentRecording
        
        autoSpec
        maxLoadSize
        displayChannels = nan(3, 0); % 3xN matrix of HW channels to display for each of N experiments, -1 for nothing
        displayRecordingNo = nan(0, 1);% Nx1 matrix of file number to display, -1 for nothing
        
        currentExperNdx = 0;
        startNdx = 0;
        endNdx = 0;
    end
    methods
        function self = AcqGuiModel(varargin)
            p = inputParser();
            addParameter(p, 'autoSpec', true); % determines if the spectrogram is automatically calculated for new recordings
            addParameter(p, 'maxLoadSize', 2000000); % maximum number of samples to load of a recording
            addParameter(p, 'DisplayChannels', {});
            parse(p, varargin{:});
            Params = p.Results;
            
            self.AcqObj = AcqMaster(varargin{:}); % Make acquisition session
            self.autoSpec = Params.autoSpec;
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
        
        function append_exper(self, Experiment)
            self.AcqObj.append_exper(Experiment);
        end
        function remove_exper(self)
            self.AcqObj.remove_exper(self.currentExperNdx);
        end
    end
    methods (Access = private)
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
    end
end