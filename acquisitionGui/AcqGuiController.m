classdef (Sealed) AcqGuiController < handle
    properties (Access = private)
        %% Gui
        GuiHandle
        
        %% Experiment related properties
        Experiments
        
        %% Display data
        currentExperNdx
        experDisplayChannels % 3xN matrix of HW channels to display for each of N experiments, nan for nothing
        displayRecordingNo % Nx1 matrix of file number to display
        
        
        %% Daq related properties
        DaqObj
        
        restartDaily
        startHour
        stopHour
        
        TimerHandle
    end
    methods
        function self = AcqGuiController()
            
        end
    end
end