%% Learning from successes
% Charlesworth et al. 2011 showed that . Here we replicate that finding.

close all

%%
clear all
xmodel_parameters_caf;
xmodel_initialize;
xmodel_run;
save c:\stetner\data\figures\xmodel\caf.mat

%%
clear all
for n = 1:50
    n
    xmodel_parameters_random_caf;
    xmodel_initialize;
    xmodel_run;
    save(['c:\stetner\data\figures\xmodel\random_caf' int2str(n)])
    save temp n
    clear all
    load temp
end

%%
clear all
load c:\stetner\data\figures\xmodel\caf.mat

% Vocal output (pitch) before learning. Successful trials in red.
figure(4011)
clf
is_baseline = 1:total_motifs <= baseline_motifs;
baseline_escapes = squeeze(ra_output(1,:, is_escape & is_baseline));
baseline_hits  = squeeze(ra_output(1,:,~is_escape & is_baseline));
plot(baseline_hits, 'b')
hold on
plot(baseline_escapes, 'r')
xlabel('Time (ms)')
ylabel('"Pitch"')

% Vocal output after learning
figure(4012)
clf
is_after_learning = 1:total_motifs >= total_motifs - baseline_motifs;
after_learning = squeeze(ra_output(1, :, is_after_learning));
plot(after_learning,'k')
xlabel('Time (ms)')
ylabel('"Pitch"')

% histogram before
bins = -10:2:25;
figure(4013)
clf
y_escape = histc(baseline_escapes(caf_target_time2,:), bins);
y_hit = histc(baseline_hits(caf_target_time2,:), bins);
stairs(bins, y_escape+y_hit, 'k')

% histogram after
hold on
y_after = histc(after_learning(caf_target_time2, :),bins);
stairs(bins, y_after, 'g')

h = line(caf_pitch_threshold2*ones(2,1), ylim);
set(h, 'LineWidth', 3)
set(h, 'Color', [0 0 1])
%% (c) Random CAF
clear all
load c:\stetner\data\figures\xmodel\random_caf.mat
N = 50; % number of trials to average at the end of learning

% escapes
figure(4031)
clf
escapes = squeeze(ra_output(1, :, is_escape));
plot(escapes, 'Color', [1 .8 .8])
hold on
plot(mean(escapes, 2), 'LineWidth', 3, 'Color', [1 0 0])

% random hits
figure(4032)
clf
random_hits = squeeze(ra_output(1, :, is_random_hit));
plot(random_hits, 'Color', [.8 .8 1])
hold on
plot(mean(random_hits, 2), 'LineWidth', 3, 'Color', [0 0 1])

% show average of escapes, random hits, and actual learning
figure(4033)
clf
after_learning = squeeze(ra_output(1, :, end-N:end));
plot(mean(after_learning, 2), 'LineWidth', 3, 'Color', [0 0 0])
hold on
plot(mean(escapes, 2), 'LineWidth', 3, 'Color', [1 0 0])
plot(mean(random_hits, 2), 'LineWidth', 3, 'Color', [0 0 1])
plot(squeeze(mean(ra_output, 3)))


%% (d) Comparison of successes vs. failures
figure(404)
