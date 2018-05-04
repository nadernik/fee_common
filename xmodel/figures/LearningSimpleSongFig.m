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
            obj.filename = 'learning_simple_song3.mat';
            obj.h = figure;
        end
        
        function compute(obj)
            sn = SparseNetChanneled;
            
            sn.nhvc = 200;
            sn.niter = 2e4;
            sn.nvocal = 1;
            sn.LTPrate = 5e-1;
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
            bias = zeros(sn.nvocal,sn.nhvc,sn.niter);
            for iter = 1:sn.niter
                bias(:,:,iter) = sn.bias(iter);
            end
            template = sn.template;
            save learning_simple_song_medium_learning_rate_long bias template
            %%
            niter = 10000;
            exampleiter = [1, 800, 10000];
            subplot(2,1,1)
            plot(template, 'Color', [.3 .3 .3], 'LineWidth', 3)
            hold on
            rgb = flipud(autumn(length(exampleiter)));
            legendstr = {'Template'};
            for ii = 1:length(exampleiter)
                iter = exampleiter(ii);
                legendstr{ii+1} = ['Trial ' int2str(iter)];
                plot(bias(1,:,iter), ':', 'Color', rgb(ii,:), 'LineWidth', 3)
            end
            hold off
            set(gca, 'YTick', [0 1], 'FontSize', 14)
            legend(legendstr)
            xlabel('Time (ms)')
            ylabel('Vocal Output')
            ylim([-0.1, 1.6])
            subplot(2,1,2)
            mse = zeros(niter,1);
            for iter = 1:niter
                mse(iter) = mean(abs(sum(bias(:,:,iter) - template, 1)).^2);
            end
            plot(mse)
            ylim([0,0.6])
            set(gca, 'YTick', 0:0.2:0.6, 'FontSize', 14)
            xlabel('Trial')
            ylabel('Mean Squared Error')
            %%
            %save(fullfile(obj.datadir, obj.filename));
        end
        
        function draw(obj)
            %load(fullfile(obj.datadir, obj.filename), 'sn');
            figure(obj.h)
            subplot(1,2,1)
            sn.plotbiasvstemplate(sn.niter)
            subplot(1,2,2)
            mse = zeros(sn.niter,1);
            for iter = 1:sn.niter
                mse(iter) = mean(abs(sum(sn.bias(iter) - sn.template, 1)).^2);
            end
            plot(mse)
            xlabel('Trial')
            ylabel('MSE')
        end
    end
end