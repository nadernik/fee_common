classdef SparseNetMultipleRunsFig < Fig
    % This figure shows the results from several runs of SparseModel on the
    % same plot. It shows the bias on the last motif plotted with the
    % template. In a separate panel it shows the mean squared error between
    % bias and template as a function of trial number. 
    properties
        filepattern
    end
    
    methods
        function obj = SparseNetMultipleRunsFig()
            obj.h(1) = figure;
            obj.h(2) = figure;
            obj.datadir = 'c:\stetner\data\sparsenet';
            obj.filepattern = 'SparseNetFigureCandidate_slow_*.mat';
            obj.filename = 'SparseNetMultipleRuns.mat';
        end
        
        function compute(obj)
            % All files in datadir that match filepattern
            files = dir(fullfile(obj.datadir, obj.filepattern));
            for k = 1:length(files)
                fprintf('Loading file: %s\n', files(k).name)
                load(fullfile(obj.datadir, files(k).name), 'sn')
                
                % Initialize variables after loading the first file
                if k == 1
                    shared_template = sn.template;
                    final_bias = zeros(sn.nhvc, length(files));
                    final_weights = zeros(sn.nmsn, sn.nhvc, length(files));
                    mse = zeros(sn.niter, length(files));
                end
                
                % Make sure that each file uses the same template as the
                % first file.
                if sn.template ~= shared_template
                    warning('This file does not use the same template as the others. Skipping...')
                    continue
                end
                
                % Bias on the last trial
                final_bias(:,k) = sn.bias(sn.niter);
                
                % Weight matrix on the last trial
                final_weights(:,:,k) = sn.wH(:,:,sn.niter);
                
                % Calculate mean squared error between bias and template on
                % each iteration
                for iter = 1:sn.niter
                    mse(iter,k) = mean((sn.bias(iter) - sn.template).^2);
                end
            end
            
            fname = fullfile(obj.datadir, obj.filename);
            save(fname, 'shared_template', 'files', 'final_bias', 'final_weights', 'mse')
        end
        
        function draw(obj)
            clf(obj.h(1))
            clf(obj.h(2))
            
            d = load(fullfile(obj.datadir, obj.filename));
            npanels = length(d.files) + 2;
            nrows = floor(sqrt(npanels));
            ncols = ceil(sqrt(npanels));
            
            % Find Y-axis limits
            ymin = min(globalmin(d.final_bias), globalmin(d.shared_template));
            ymax = max(globalmax(d.final_bias), globalmax(d.shared_template));
            yrange = ymax - ymin;
            ymin = ymin - 0.2 * yrange;
            ymax = ymax + 0.2 * yrange;
            
            figure(obj.h(1))
            subplot(nrows, ncols, 1)
            plot(d.shared_template, 'Color', [0.5 0.5 0.5], 'LineWidth', 3)
            hold on
            plot(d.final_bias, 'LineWidth', 2)
            ylim([ymin ymax])
            hold off
            
            subplot(nrows, ncols, 2)
            plot(d.mse, 'LineWidth', 2)
            
            for k = 1:length(d.files)
                figure(obj.h(1))
                subplot(nrows, ncols, 2+k)
                plot(d.shared_template, 'Color', [0.5 0.5 0.5], 'LineWidth', 3)
                hold on
                plot(d.final_bias(:,k), 'Color', [1 0 0], 'LineWidth', 2)
                ylim([ymin ymax])
                hold off
                
                % Image of weights 
                figure(obj.h(2))
                subplot(nrows, ncols, 2+k)
                tmax = nan(size(d.final_weights,1), 1);
                for i = 1:size(d.final_weights,1)
                    [~, tmax(i)] = max(d.final_weights(i,:,k));
                end
                [~, ord] = sort(tmax);
                imagesc(d.final_weights(ord,:,k))
                axis off
            end
        end
    end
end
