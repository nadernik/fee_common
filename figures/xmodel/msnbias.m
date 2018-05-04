%% Figure 2: Area X drives bias in LMAN to reduce errors
close all
clear all
load 'c:\stetner\data\figures\xmodel\bias.mat'

%% Show template, which is strictly positive
figure(201)
t = (0:motifsteps-1) * P.dt;
axes('FontSize', 16)
plot(t, P.template(s(1:motifsteps)))
yy = ylim;
yy(1) = 0;
ylim(yy);
ylabel('"Pitch"')
xlabel('Time (ms)')


%% Show LMAN fluctuations before learning
figure(202)
ntrials = 20;
Y = gettrials(L, 1:ntrials, motifsteps);
subplot(2,1,1)
set(gca, 'FontSize', 16)
plot(t, Y(:,1), 'k')
ylim([-0.1 0.8])
xlim([0 0.3])
subplot(2,1,2)
set(gca, 'FontSize', 16)
plot(t, Y, 'Color', [.7 .7 .7])
hold on
plot(t, mean(Y'), 'k', 'LineWidth', 2)
ylim([-0.1 0.8])
xlim([0 0.3])
xlabel('Time (ms)')

figure(207)
axes('FontSize', 16)
plot(t, Y, 'Color', [.7 .7 .7])
hold on
plot(t, mean(Y'), 'k', 'LineWidth', 2)
ylim([-0.1 1.8])
xlim([0 0.3])
xlabel('Time (ms)')
%% Show bias in LMAN after learning (consolidation is off)
figure(203)
axes('FontSize', 16)
Y = gettrials(L, -ntrials:-1, motifsteps);
plot(t, Y, 'Color', [.7 .7 .7])
hold on
plot(t, nanmean(Y, 2), 'k', 'LineWidth', 2)
plot(t, P.template(s(1:motifsteps)), 'b', 'LineWidth', 2)
ylim([-0.1 1.8])
xlim([0 0.3])
xlabel('Time (ms)')
%% Show thalmic drive to LMAN during last motif
figure(204)
axes('FontSize', 16)
Y = gettrials(D, -ntrials:-1, motifsteps);
plot(t, Y, 'Color', [.7 .7 .7])
hold on
plot(t, nanmean(Y, 2), 'k', 'LineWidth', 2)
plot(t, P.template(s(1:motifsteps)), 'b', 'LineWidth', 2)
ylim([-0.1 1.8])
xlim([0 0.3])
xlabel('Time (ms)')
%% Show example MSNs
figure(205)
clf
numneurons = 6;
neurons = floor(linspace(1, P.hvcunits, numneurons + 2));
ymax = 0;
axes('FontSize', 16, 'YDir', 'reverse')
hold on
for ii = 1:numneurons
    ii
    y = gettrials(M(neurons(ii+1), :), -1, motifsteps);
    plot(t, -y + ii)
end
ylim([0 7])
xlim([0 0.3])
xlabel('Time (ms)')

%% hvc
figure(206)
axes('FontSize', 16, 'YDir', 'reverse')
hold on
t = (0:motifsteps-1) * P.dt;
for row = 1:size(H, 1)
    plot(t, -0.6*H(row, 1:motifsteps) + row)
end
xlabel('Time (ms)')
ylabel('HVC Unit')