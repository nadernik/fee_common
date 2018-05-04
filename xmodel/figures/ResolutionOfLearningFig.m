classdef ResolutionOfLearningFig < Fig
    properties
        % Inherited from Fig:
        %  datadir
        %  filename
        %  h
    end
    
    methods
        function obj = ResolutionOfLearningFig
            obj.datadir = 'c:\stetner\data\figures\xmodel\';
            obj.filename.lman = 'stretching_lman.mat';
            obj.filename.widthreward = 'learning_width_vs_reward.mat';
            obj.filename.widthlman = 'learning_width_vs_lman.mat';
            obj.filename.example1 = 'caf_example1.mat';
            obj.filename.example2 = 'caf_example2.mat';
        end
        
        function compute(obj)
            % FIXME
        end
        
        function draw(obj)
            dlman = load(fullfile(obj.datadir, obj.filename.lman));
            %% (a) song examples
            subplot(4,2,1)
            ResolutionOfLearningFig.plot_hits_escapes(dlman.lman_normal, dlman.target_time, dlman.threshold)
            set(gca, 'YTick', [])
            
            %% (b) reward prediction error examples
            subplot(4,2,2)
            d = load(fullfile(obj.datadir, obj.filename.example1));
            plot(d.rpe_hit(:,d.hitmotif), 'Color', [0.5 0 0])
            hold on
            plot(d.rpe_esc(:,d.escmotif), 'Color', [0 0 0])
            xlim([1 size(d.rpe_hit,1)])
            xlabel('Time (ms)')
            ylabel('RPE')
            hold off
            
            %% (c) width of learning
            subplot(4,2,3)
            plot(d.y_bias, 'Color', [0 0 1], 'LineWidth', 3)
            ylim([-.2, 1.2])
            hold on
            plot(xlim, [0 0], 'k')
            [width, xw] = fwhm(d.y_bias);
            y = [0.5, 0.5];
            [fx, fy] = dsxy2figxy(xw, y);
            annotation('doublearrow',fx,fy)
            str = sprintf('%.1f ms', width);
            text(xw(2)+width, 0.5, str);
            hold off
            
            %% (d) compare width of learning to hvc burst, reward, and baseline escapes
            subplot(4,2,4)
            plot(d.t_bias, d.y_bias, 'Color', [0 0 1],   'LineWidth', 3)
            ylim([-.2, 1.2])
            hold on
            plot(d.t_hvc,  d.y_hvc,  'Color', [0 .5 .5], 'LineWidth', 3)
            plot(d.t_esc,  d.y_esc,  'Color', [0 0 0],   'LineWidth', 3)
            plot(d.t_rwd,  d.y_rwd,  'Color', [0 .5 0],  'LineWidth', 3)
            hold off
            %% (e) width of learning with wider LMAN fluctuations
            subplot(4,2,5)
            d = load(fullfile(obj.datadir, obj.filename.example2));
            plot(d.y_bias, 'Color', [0 0 1], 'LineWidth', 3)
            ylim([-.2, 1.2])
            hold on
            plot(xlim, [0 0], 'k')
            [width, xw] = fwhm(d.y_bias);
            y = [0.5, 0.5];
            [fx, fy] = dsxy2figxy(xw, y);
            annotation('doublearrow',fx,fy)
            str = sprintf('%.1f ms', width);
            text(xw(2)+width, 0.5, str);
            
            %% (f) comparison of learning vs. other time scales with wider lman
            subplot(4,2,6)
            plot(d.t_bias, d.y_bias, 'Color', [0 0 1],   'LineWidth', 3)
            ylim([-.2, 1.2])
            hold on
            plot(d.t_hvc,  d.y_hvc,  'Color', [0 .5 .5], 'LineWidth', 3)
            plot(d.t_esc,  d.y_esc,  'Color', [0 0 0],   'LineWidth', 3)
            plot(d.t_rwd,  d.y_rwd,  'Color', [0 .5 0],  'LineWidth', 3)
            hold off
            
            %% (g) width of learning vs. width of LMAN autocorrelation
            subplot(4,2,7)
            dL = load(fullfile(obj.datadir, obj.filename.widthlman));
            scatter(dL.width_lman, dL.width_learning, 500, [0 0 0], '.')
            xlabel('LMAN width')
            ylabel('Learning width')
            hold on
            plot(xlim, ones(2,1) * fwhm(dL.rkernel), 'k')
            line([0 100], [0 100], 'color', 'black')
            setticklimx([0, 100])
            setticklimy([0, 60])
            
            %% (h) width of learning vs. width of reward kernel
            subplot(4,2,8)
            dr = load(fullfile(obj.datadir, obj.filename.widthreward));
            scatter(dr.width_reward, dr.width_learning, 500, [0 0 0], '.')
            hold on
            plot(xlim, mean(dr.width_lman)*ones(2,1),'-k')
            xlabel('Reward width (ms)')
            ylabel('Learning width (ms)')
            line([0 100], [0 100], 'color', 'black')
            setticklimx([0,40])
            setticklimy([0, 20])
        end
    end
    
    methods(Static)
        function plot_hits_escapes(y, t0, thresh)
            escape_trials = find(y(t0, :) > thresh);
            hit_trials = find(y(t0, :) < thresh);
            n = randsample(length(hit_trials), 5);
            plot(y(:,hit_trials(n)), 'Color', [0.5 0 0], 'LineWidth', 2)
            hold on
            n = randsample(length(escape_trials), 5);
            plot(y(:,escape_trials(n)), 'Color', [0 0 0], 'LineWidth', 2)
            hold off
        end
    end
end