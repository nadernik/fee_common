close all


%% Show example MSNs
clear all
load 'c:\stetner\data\figures\xmodel\withcomp.mat'
figure(501)
clf
t = (1:motifsteps) * P.dt;
numneurons = 6;
neurons = floor(linspace(1, P.hvcunits, numneurons + 2));
ymax = 0;
axes('FontSize', 16, 'YDir', 'reverse')
hold on
for ii = 1:numneurons
    y = gettrials(M(neurons(ii+1), :), -1, motifsteps);
    plot(t, -y + ii)
end
ylim([0 7])
xlim([0 0.3])
xlabel('Time (ms)')

%%
clear all
load 'c:\stetner\data\figures\xmodel\nocomp.mat'
figure(502)
clf
t = (1:motifsteps) * P.dt;
numneurons = 6;
neurons = floor(linspace(1, P.hvcunits, numneurons + 2));
ymax = 0;
axes('FontSize', 16, 'YDir', 'reverse')
hold on
for ii = 1:numneurons
    y = gettrials(M(neurons(ii+1), :), -1, motifsteps);
    plot(t, -y + ii)
end
ylim([0 7])
xlim([0 0.3])
xlabel('Time (ms)')

%% 
figure(503)
clf
axes('FontSize', 16)
plot(t, P.template(s(1:motifsteps)))
xlim([0 0.3])
xlabel('Time (ms)')
ylabel('"Pitch"')