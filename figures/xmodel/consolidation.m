%% Figure 3: Learned changes are consolidated from AFP into motor pathway
close all
clear all
load 'consolidation.mat'
motorpathway = R - W_RL * L(:, 1:maxsteps); % assumes W_RL is constant

%% (a) Error is reduced over time
figure(301)
t = 1:motifsteps;
for ii = 1:P.motifs - 49
    trials = ii + (0:49);
    err(ii) = sum((P.template(s(t))' - nanmean(gettrials(R, trials, motifsteps), 2)).^2);
    err_mp(ii) = sum((P.template(s(t))' - nanmean(gettrials(motorpathway, trials, motifsteps), 2)).^2);
end
plot(err, 'k')
hold on
plot(err_mp, 'r')
yy = ylim;
ylim([0 yy(2)])
ylabel('Error')
xlabel('Trials')

%% (b) Output gradually approaches template in motor pathway and AFP
figure(302)
trials = [1, 150, 300, P.motifs-49];
cols = length(trials);
t = 1:motifsteps;

for ii = 1:cols
    ax(ii) = subplot(1, cols, ii);
    % template
    plot(P.template(s(t)), 'b', 'LineWidth', 2)
    hold on
    % total output
    Y = gettrials(R, trials(ii) + (0:49), motifsteps); 
    plot(nanmean(Y, 2), 'k', 'LineWidth', 2);
    % motor pathway
    Y = gettrials(motorpathway, trials(ii) + (0:49), motifsteps);
    plot(nanmean(Y, 2), 'r', 'LineWidth', 2)
end

yy = ylim(ax(end));
for ii = 1:cols
    ylim(ax(ii), [0, yy(2)])
end

%% (c) Bias over time
figure(303)
t = nan(P.motifs - 49, 1);
bias = nan(P.motifs - 49, 1);
for ii = 1:P.motifs - 49
    trials = ii + (0:49);
    t(ii) = mean(trials); 
    % Bias is the effect of the DLM signal on motor output. Assumes W_RL
    % and W_LD are constant through learning.
    bias(ii) = sum(nanmean(W_RL * W_LD * gettrials(D, trials, motifsteps), 2));
end
plot(t, bias)
yy = ylim;
ylim([0 yy(2)])