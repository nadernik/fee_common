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
            obj.filename = 'learning_simple_song2.mat';
            obj.h = figure;
        end
        
        function compute(obj)
            sn = SparseNetChanneled;
            
            sn.nhvc = 200;
            sn.niter = 1e3;
            sn.nvocal = 1;
            sn.LTPrate = 1e-3;
            sn.kernelstd = 12;
            
            maxtemplate = 1;
            sn.rperate     =  0.2;
            sn.lmanstd     =  0.05 * maxtemplate;
            sn.lmanoffset  =  2    * sn.lmanstd;
            sn.winit       =  0.1  * sn.lmanstd;
            sn.hvcburstlen = 11;
            
            % This makes a template that looks like the letter M. It is the
            % sum of two cosines, one with period equal to the length of
            % the song and the other with half that period. The whole thing
            % is shifted up so that the minimum is equal to the LMAN
            % offset.
            a = (maxtemplate - sn.lmanoffset);
            t1 = linspace(0, 2*pi, sn.nhvc);
            t2 = linspace(0, 4*pi, sn.nhvc);
            y = -cos(t1) - cos(t2);
            y = y - min(y);
            y = y / max(y) * a + sn.lmanoffset;
            sn.template = y;
            
            sn.init
            sn.simulate
            
            save(fullfile(obj.datadir, obj.filename));
            keyboard
        end
        
        function draw(obj)
            load(fullfile(obj.datadir, obj.filename), 'sn');
            figure(obj.h)
            subplot(1,2,1)
            sn.plotbiasvstemplate(sn.niter)
            subplot(1,2,2)
            whos
            sn.reward(1)
%             e = -sn.foralliter(@sn.reward);
keyboard
            mse = mean(e.^2, 1);
            semilogy(mse)
            xlabel('Trial')
            ylabel('MSE')
        end
    end
end