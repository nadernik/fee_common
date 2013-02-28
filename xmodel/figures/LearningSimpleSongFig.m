classdef LearningSimpleSongFig < Fig
    properties
        % Inherited from Fig:
        %  datadir
        %  filename
        %  h
    end
    
    methods
        function obj = LearningSimpleSongFig
            obj.datadir = 'c:\stetner\data\figures\xmodel\';
            obj.filename = 'learning_simple_song.mat';
            obj.h = figure;
        end
        
        function compute(obj)
            xmodel_parameters_simplesong
            xmodel_initialize
            xmodel_run
            xmodel_calculate_bias
            save(fullfile(obj.datadir, obj.filename));
        end
        
        function draw(obj)
            d = load(fullfile(obj.datadir, obj.filename));
            figure(obj.h)
            subplot(1,2,1)
            msn_examples(d, 5:10:d.hvc_units)
            subplot(1,2,2)
            plotmsebias(d)
        end
    end
end