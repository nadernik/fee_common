% reducing_variability shows that xmodel can learn to reduce variability by
% increasing activity in the indirect pathway

%%
close all
clear all
for run = 1:10
    run
    xmodel_parameters_indirect_squish
    xmodel_initialize_indirect
    xmodel_run_indirect
    save(['C:\stetner\data\figures\xmodel\reducing_variability' int2str(run)])
    save temp run
    clear all
    load temp
end
%%
example_run_file = 'C:\stetner\data\figures\xmodel\reducing_variability2.mat';
N = 100; % number of pitch traces to show before and after learning
histogram_bin_edges = -10:0.5:10;
%% (a) Song before learning
% Overlayed traces of N renditions of the song before learning. Successful
% (unpunished) trials in red.
figure(801)
clf
clear d
d = load(example_run_file);
yhi = max(max(max(d.ra_output)));
ylo = min(min(min(d.ra_output)));
is_successful = 1:d.total_motifs <= N &  d.is_escape;
is_punished   = 1:d.total_motifs <= N & ~d.is_escape;
plot(squeeze(d.ra_output(1,:,is_punished)), 'Color', [.8, .8, .8])
hold on
plot(squeeze(d.ra_output(1,:,is_successful)), 'Color', 'r')
xlabel('Time (ms)')
ylabel('"Pitch"')


%% (b) Distribution of pitches at target time
% Values that will be punished are shaded
figure(802)
clf
clear d
d = load(example_run_file);
counts = histc(squeeze(d.ra_output(1,d.caf_target_time1,1:N)), histogram_bin_edges);
[x, y] = stairs(histogram_bin_edges, counts);
plot(x, y)
hold on 
toohi = x >= d.caf_pitch_threshold1;
toolo = x <= d.caf_pitch_threshold2;
fill([x(toohi); d.caf_pitch_threshold1], [y(toohi); 0],'b')
fill([x(toolo); d.caf_pitch_threshold2], [y(toolo); 0],'b')
%% (c) Song after learning
% N overlayed traces
figure(803)
clf
clear d
d = load(example_run_file);
yhi = max(max(max(d.ra_output)));
ylo = min(min(min(d.ra_output)));
is_successful = 1:d.total_motifs >= d.total_motifs-N &  d.is_escape;
is_punished   = 1:d.total_motifs >= d.total_motifs-N & ~d.is_escape;
if sum(is_punished) > 0
    plot(squeeze(d.ra_output(1,:,is_punished)), 'Color', [.8, .8, .8])
end
hold on
plot(squeeze(d.ra_output(1,:,is_successful)), 'Color', 'r')
xlabel('Time (ms)')
ylabel('"Pitch"')

%% (d) Distribution of pitches at target time after learning
% punished values are shaded
figure(804)
clf
clear d
d = load(example_run_file);
counts = histc(squeeze(d.ra_output(1,d.caf_target_time1,end-N:end)), histogram_bin_edges);
[x, y] = stairs(histogram_bin_edges, counts);
plot(x, y)
hold on 
toohi = x >= d.caf_pitch_threshold1;
toolo = x <= d.caf_pitch_threshold2;
fill([x(toohi); d.caf_pitch_threshold1], [y(toohi); 0],'b')
fill([x(toolo); d.caf_pitch_threshold2], [y(toolo); 0],'b')

%% (e) Learning reduces variability
% Variability is measured as the sample standard deviation of the
% histograms shown in (b) and (d).
figure(805)
clf
total_runs = 10;
variability_pre = zeros(total_runs, 1);
variability_post = zeros(total_runs, 1);
for run = 1:total_runs
    d = load(['C:\stetner\data\figures\xmodel\reducing_variability' int2str(run)]);
    pre  = squeeze(d.ra_output(1, d.caf_target_time1, 1:N));
    post = squeeze(d.ra_output(1, d.caf_target_time1, end-N:end));
    variability_pre(run) = std(pre);
    variability_post(run) = std(post);
end
scatter(zeros(1, total_runs), variability_pre)
hold on
scatter(ones(1, total_runs), variability_post)
X = [zeros(total_runs, 1), ones(total_runs, 1)];
Y = [variability_pre, variability_post];
line(X', Y')
%% (f) Activity in the indirect pathway reduces variability.
% A reduction in variability can be caused by a decrease in LMAN activity. 
figure(806)
clf
d = load(example_run_file);
direct = squeeze(sum(d.direct_msn_output(:, :, end-N:end)));
indirect = squeeze(sum(d.indirect_msn_output(:, :, end-N:end)));
plot(mean(direct, 2),'g')
hold on
plot(mean(-indirect, 2),'r')
plot(mean(direct-indirect, 2), 'k')