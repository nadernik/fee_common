%% Figure 2: Area X drives bias in LMAN to reduce errors
close all
clear all
load 'msnbias.mat'

% Show template, which is strictly positive
figure(201)
plot(P.template)
yy = ylim;
yy(1) = 0;
ylim(yy);

% Show LMAN fluctuations before learning
figure(202)
ntrials = 20;
Y = gettrials(L, 1:ntrials, motifsteps);
plot(Y, 'Color', [.7 .7 .7])
hold on
plot(mean(Y'), 'k', 'LineWidth', 2)

% Show bias in LMAN after learning (consolidation is off)
figure(203)
Y = gettrials(L, -ntrials:-1, motifsteps);
plot(Y, 'Color', [.7 .7 .7])
hold on
plot(nanmean(Y, 2), 'k', 'LineWidth', 2)
t = 1:motifsteps;
plot(P.template(s(t)), 'b', 'LineWidth', 2)

% Show thalmic drive to LMAN during last motif
figure(204)
Y = gettrials(D, -ntrials:-1, motifsteps);
plot(Y, 'Color', [.7 .7 .7])
hold on
plot(nanmean(Y, 2), 'k', 'LineWidth', 2)
t = 1:motifsteps;
plot(P.template(s(t)), 'b', 'LineWidth', 2)

% Show example MSNs
figure(205)
numneurons = 6;
neurons = floor(linspace(1, P.hvcunits, numneurons + 2));
ymax = 0;
ax = nan(1, numneurons);
for ii = 1:numneurons
    ax(ii) = subplot(numneurons,1,ii);
    y = gettrials(M(neurons(ii+1), :), -1, motifsteps);
    plot(y)
    ymax = max(ymax, max(y));
end
for ii = 1:numneurons
    ylim(ax(ii), [0 ymax])
    axis(ax(ii), 'off')
end