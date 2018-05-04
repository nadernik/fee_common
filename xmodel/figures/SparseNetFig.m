classdef SparseNetFig < Fig
    properties
        % Inherited from Fig:
        %  datadir
        %  filename
        %  h
        
        nruns = 10; % number of simulations for each sparse condition
        example_yesinhib % run number to use as example 
        example_noinhib % run number to use as example 
        colors % colors of lines for each condition
    end
    
    methods
        function obj = SparseNetFig()
            obj.datadir = 'c:\stetner\data\sparsenet';
            obj.filename.aggregated = 'sparsenet-figure.mat';
            obj.filename.template = 'figure-%s-%02.f.mat';
            obj.example_yesinhib = 6;
            obj.example_noinhib = 7;
            obj.h = figure;
            obj.colors.notsparse = [0 0   0]; % black
            obj.colors.noinhib   = [0 0.5 0]; % green 
            obj.colors.yesinhib  = [0 0   1]; % blue
            
            assert(ismember(obj.example_yesinhib, 1:obj.nruns))
            assert(ismember(obj.example_noinhib, 1:obj.nruns))
        end
        
        function compute(obj)
            %% Run simulations (WARNING: this takes about 10 hours total)
            
            % One simulation of not sparse case
            sn = NotSparseNet;
            sn = SparseNetFig.SetParameters(sn);
            sn.winit    = 0;
            sn.LTPrate  = 0.002;
            sn.init
            sn.simulate
            save(obj.simfile('notsparse', 1), 'sn')
            
            % nruns simulations of sparse case WITHOUT inhibition
            for n = 1:obj.nruns
                sn = SparseNet2;
                sn = SparseNetFig.SetParameters(sn);
                sn.LTDrate  = 1e-6;
                sn.init
                sn.simulate
                save(obj.simfile('noinhib', n), 'sn')
                clear sn
            end
                
            % nruns simulations of sparse case WITH inhibition
            for n = 1:obj.nruns
                sn = SparseNet;
                sn = SparseNetFig.SetParameters(sn);
                sn.LTDrate  = 2e-6;
                sn.latinhib = 5e-4;
                sn.pinhib = .75;
                sn.init
                sn.simulate
                save(obj.simfile('yesinhib', n), 'sn')
                clear sn
            end
            
            %% Aggregate data from the simulations into one small file that has only the data we need to make the plot
            obj.aggregate()
        end
        
        function draw(obj)
            d = load(fullfile(obj.datadir, obj.filename.aggregated));
            
            %% Example -- Not sparse
            subplot(4,2,1)
            SparseNetFig.DrawExampleBias(d.bias.notsparse, d.template, obj.colors.notsparse)
            subplot(4,2,2)
            SparseNetFig.DrawExampleWeights(d.weights.notsparse)
            
            %% Example -- Sparse but no inhibition
            subplot(4,2,3)
            song = d.bias.noinhib(:,obj.example_noinhib);
            SparseNetFig.DrawExampleBias(song, d.template, obj.colors.noinhib)
            subplot(4,2,4)
            weights = d.weights.noinhib(:,:,obj.example_noinhib);
            SparseNetFig.DrawExampleWeights(weights)
            
            %% Example -- Sparse and with inhibition
            subplot(4,2,5)
            song = d.bias.yesinhib(:,obj.example_yesinhib);
            SparseNetFig.DrawExampleBias(song, d.template, obj.colors.yesinhib)
            subplot(4,2,6)
            weights = d.weights.yesinhib(:,:,obj.example_yesinhib);
            SparseNetFig.DrawExampleWeights(weights)
            
            %% MSN density 
            ntimebins = size(d.weights.noinhib,2);
            timebins = 1:ntimebins;
            n_noinhib  = zeros(ntimebins, obj.nruns);
            n_yesinhib = zeros(ntimebins, obj.nruns);
            for n = 1:obj.nruns
                w = d.weights.noinhib(:,:,n);
                [~, centers_noinhib] = max(w');
                n_noinhib(:,n) = hist(centers_noinhib, timebins);
                
                w = d.weights.yesinhib(:,:,n);
                [~, centers_yesinhib] = max(w');
                n_yesinhib(:,n) = hist(centers_yesinhib, timebins);
            end
            
            % MSN density for the example sparse runs in earlier panels
            subplot(4,2,7)
            plot(n_noinhib(:,obj.example_noinhib), 'Color', obj.colors.noinhib, 'LineWidth', 1)
            hold on
            plot(n_yesinhib(:,obj.example_yesinhib), 'Color', obj.colors.yesinhib, 'LineWidth', 1)
            legend({'No inhibition', 'Inhibition'}, 'Location', 'NorthWest')
            xlabel('Time (ms)')
            ylabel('MSN density')
            
            % Bar graph showing standard deviation of MSN density. Error
            % bars are the standard error of the mean.
            subplot(4,2,8)
            Y = std(n_noinhib);
            bar(1, mean(Y), 'FaceColor', obj.colors.noinhib)
            hold on
            errorbar(1, mean(Y), std(Y)/length(Y), 'Color', 'k')
            Y = std(n_yesinhib);
            bar(2, mean(Y), 'FaceColor', obj.colors.yesinhib)
            errorbar(2, mean(Y), std(Y)/length(Y), 'Color', 'k')
            set(gca, 'XTick', [1 2], 'XTickLabel', {'No inhibition', 'Inhibition'})
            ylabel('Standard deviation of MSN density')            
        end
        
        function aggregate(obj)
            % Aggregates data from all the simulations into a small data
            % file, keeping only the info we need to make the plots.
            % Save these things:
            %  Final bias
            %  Final weight matrix
            %  Final MSN output
            %  Template (this should be the same for all runs!)
            
            
            %% Not sparse, and the template
            disp('Aggregating data from not sparse simulation...')
            load(obj.simfile('notsparse', 1), 'sn')
            bias.notsparse = sn.bias(sn.niter); % Final bias
            weights.notsparse = sn.wH(:,:,sn.niter); % Final weight matrix
            msnout.notsparse = sn.msnout(:,:,sn.niter); % Final MSN output
            template = sn.template; % Template
            clear sn
            
            %% Sparse without inhibition
            for n = 1:obj.nruns
                fprintf('Aggregating data from sparse (no inhibition) simulation %g of %g...\n', n, obj.nruns)
                load(obj.simfile('noinhib', n), 'sn')
                bias.noinhib(:,n) = sn.bias(sn.niter); % Final bias
                weights.noinhib(:,:,n) = sn.wH(:,:,sn.niter); % Final weight matrix
                msnout.noinhib(:,:,n) = sn.msnout(:,:,sn.niter); % Final MSN output
                clear sn
            end
            
            %% Sparse with inhibition
            for n = 1:obj.nruns
                fprintf('Aggregating data from sparse (yes inhibition) simulation %g of %g...\n', n, obj.nruns)
                load(obj.simfile('yesinhib', n), 'sn')
                bias.yesinhib(:,n) = sn.bias(sn.niter); % Final bias
                weights.yesinhib(:,:,n) = sn.wH(:,:,sn.niter); % Final weight matrix
                msnout.yesinhib(:,:,n) = sn.msnout(:,:,sn.niter); % Final MSN output
                clear sn
            end
            
            %%
            save(obj.filename.aggregated, 'bias', 'weights', 'msnout', 'template')
        end
        
        function fullname = simfile(obj, str, n)
            file = sprintf(obj.filename.template, str, n);
            fullname = fullfile(obj.datadir, file);
        end
    end
    
    
    methods(Static)
        function sn = SetParameters(sn)
            sn.nhvc  =  100;
            sn.nmsn  =  300;
            sn.niter = 10000;
            
            sn.hvcburstlen = 11; % Width of HVC burst
            sn.kernelstd   = 12; % Standard deviation of Gaussian dopamine kernel
            
            maxtemplate   = 1;   % maximum template value (this is arbitrary)
            
            % Derived parameters
            sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
            sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise
            sn.winit      = 0.1  * sn.lmanstd;  % Maximum initial HVC-MSN weight
            sn.msnthresh  = 1    * sn.winit;    % Threshold for MSN output
            
            sn.LTPrate  = 0.05;   % FIXME how does this scale?
            sn.LTDrate  = 1e-6;   % FIXME how does this scale?
            
            a = (maxtemplate - sn.lmanoffset);
            t1 = linspace(0, 2*pi, sn.nhvc);
            t2 = linspace(0, 4*pi, sn.nhvc);
            y = -cos(t1) - cos(t2);
            y = y - min(y);
            y = y / max(y) * a + sn.lmanoffset;
            sn.template = y;
        end
        
        function DrawExampleBias(bias, template, clr)
            plot(template, 'LineWidth', 3, 'Color', [0.8, 0.8, 0.8])
            hold on
            plot(bias, '.', 'LineWidth', 3, 'Color', clr)
            hold off
            ylim([0, 1.2])
            xlabel('Time (ms)')
            ylabel('Vocal output')
        end
        
        function DrawExampleWeights(w)
            tmax = nan(size(w,1), 1);
            for i = 1:size(w,1)
                [~, tmax(i)] = max(w(i,:));
            end
            [~, ord] = sort(tmax);
            imagesc(w(ord,:))
            xlabel('HVC unit')
            ylabel('MSN unit')
        end
    end            
end
