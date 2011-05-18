%% Figure 3: Learned changes are consolidated from AFP into motor pathway
close all
clear all
load 'consolidation.mat'

%% (a) Error is reduced over time
figure(301)
t = 1:motifsteps;
for ii = 1:P.motifs - 49
    trials = ii + (0:49);
    err(ii) = sum(P.template(s(t))' - nanmean(gettrials(R, trials, motifsteps), 2));
end
plot(err)
ylabel('Error')
xlabel('Trials')

%% (b) Output gradually approaches template
figure(302)
trials = [1, 150, 300, P.motifs-49];
cols = length(trials);
t = 1:motifsteps;
for ii = 1:cols
    ax(ii) = subplot(1, cols, ii);
    plot(P.template(s(t)), 'b', 'LineWidth', 2)
    hold on
    Y = gettrials(R, trials(ii) + (0:49), motifsteps);
    plot(nanmean(Y, 2), 'k', 'LineWidth', 2);
    ylim([0, 1.2])
end

%% (c) Can see bias by inactivating LMAN
figure(303)
R_nolman = R - W_RL * L(:,1:maxsteps); % works because W_RL is constant
for ii = 1:cols
    ax(ii) = subplot(1, cols, ii);
    yeslman = gettrials(R, trials(ii) + (0:49), motifsteps);
    plot(nanmean(yeslman, 2), 'k', 'LineWidth', 2)
    hold on
    nolman = gettrials(R_nolman, trials(ii) + (0:49), motifsteps);
    plot(nanmean(nolman, 2), 'r', 'LineWidth', 2)
    ylim([0, 1.2])
end

%% (d) Bias over time
figure(304)
t = nan(P.motifs - 49, 1);
bias = nan(P.motifs - 49, 1);
for ii = 1:P.motifs - 49
    trials = ii + (0:49);
    t(ii) = mean(trials); 
    bias(ii) = sum(nanmean(W_RL * gettrials(L, trials, motifsteps), 2));
end
plot(t, bias)