function curse_of_dimensionality_nonlazy(do_simulations)
%%
% At lab meeting on 2012-06-06, Emily took issue with the way I showed the
% effect of increasing numbers of dimensions on the learning rate. Instead
% of actually simulating all the degrees of freedom, I just added
% increasing numbers of noise sources to the error signal. I don't know how
% to prove that these things are equivalent, so here I simulate models with
% 1, 2, and 4 degrees of freedom and compare their performance to models that
% only had the corresponding adjustments to the noise signal. Each DOF has
% a "UP" and a "DOWN" LMAN channel.

dof_list = [1, 2, 4, 8, 12, 16];
total_runs = 10;
fit_trials = 1:500;

%%
if exist('do_simulations', 'var') && do_simulations == 1
    for ir = 1:total_runs
        for id = 1:length(dof_list)
            simulate_with_dof(dof_list(id), ir);
        end
    end
end

%% Plot mean squared error over time
figure
set(gca, 'YScale', 'log')
hold all
c = get(gca, 'ColorOrder');
for id = 1:length(dof_list)
    dof = dof_list(id);
    % plot all runs with the same number of degrees of freedom in the same
    % color
    for ir = 1:total_runs
        filename = ['c:\stetner\data\xmodel\curse_of_dimensionality_nonlazy_' int2str(dof) '_' int2str(ir) '.mat']
        d = load(filename, 'bias', 'template', 'baseline_motifs');
        % note that baseline trials are removed
        mse(ir, id, :) = xmodel_calculate_mse(...
            d.bias(:,:,d.baseline_motifs+1:end),...
            d.template);

        clear d
        h = plot(squeeze(mse(ir, id, :)), 'Color', c(id,:));
        drawnow
    end
    % make a legend that labels each color with the number of degrees of
    % freedom
    legendh(id) = h;
    legendstr{id} = [num2str(dof) ' dimensions'];
end

xlabel('Trials')
ylabel('Mean Squared Error')
legend(legendh, legendstr)

%% Calculate time to learn based on how long it takes for MSE to reach a
%% set threshold

figure
hold all
thresh_list = 5:5:45; % try many different thresholds
for ith = 1:length(thresh_list)
    threshold = thresh_list(ith);
    for id = 1:length(dof_list)
        for ir = 1:total_runs
            temp = find(mse(ir, id, :) < threshold, 1, 'first'); % first time MSE falls below the threshold
            if isempty(temp)
                ttl(ir, id) = size(mse,3); % if MSE never falls below the threshold, say that the time to learn is equal to the length of the simulation
            else
                ttl(ir, id) = temp;
            end
        end
    end
    errorbar(dof_list, mean(ttl), std(ttl))
    text(dof_list(end)+0.5, mean(ttl(:,end)), ['MSE = ' num2str(threshold)])
end
title('Time to reach a set MSE')
xlabel('Degrees of Freedom')
ylabel('Trials to reach threshold MSE')

%% Calculate time to learn based on the time constant of an exponential fit
%% to the early phase of learning

figure
set(gca, 'YScale', 'log')
hold on
c = get(gca, 'ColorOrder');
for id = 1:length(dof_list)
    mse_mean = mean(mse(:,id,:), 1);

    % Fit an exponential to each run separately so we can have error bars
    % on our mesaurement of the time constant
    for ir = 1:total_runs
        % fit an exponential by fitting a line to log(y)
        y = squeeze(mse(ir,id,:));
        plot(y, 'Color', c(id, :))

        x = fit_trials;
        X = [x; ones(size(x))];
        [b,bint,r,rint,stats] = regress(log(y(x)) ,X');
        yfit = exp(b' * X);
        plot(yfit, 'Color', 'k')
        slopes(ir,id) = b(1);
    end
end
ylabel('Mean squared error')
xlabel('Trials')
set(gca, 'XTick', [0 2500 5000 7500 10000])

figure
taus = -1 ./ slopes;
errorbar(dof_list, mean(taus,1), std(taus,1))
xlabel('Dimensions in vocal output')
ylabel('Learning time constant (trials)')
set(gca, 'XTick', 0:4:16, 'YTick', 0:500:2000)
%%
save('c:\stetner\data\xmodel\curse_of_dimensionality_nonlazy_aggregated.mat')

end
%%

function simulate_with_dof(dof, irun)

xmodel_parameters
ra_units = dof;

baseline_motifs = 100;
learning_motifs = 10000;
ending_motifs = 0;

% Templates should be orthogonal, so they are sines and cosines with
% different frequecies. The period of the fundamental frequency is the
% motif duration.
t = 1:motif_steps;
for d = 1:dof
    harmonic = 1;
%     if mod(d, 2) == 0 % even
%         template(d, :) = 10*cos(2 * pi * harmonic / motif_steps * t);
%     else % odd
        template(d, :) = 10*sin(2 * pi * harmonic / motif_steps * t);
%     end
end

xmodel_initialize
xmodel_run
xmodel_calculate_bias
filename = ['c:\stetner\data\xmodel\curse_of_dimensionality_nonlazy_' int2str(dof) '_' int2str(irun) '.mat'];
save(filename)

end