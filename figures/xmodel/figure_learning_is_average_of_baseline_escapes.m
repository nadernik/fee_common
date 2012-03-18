function figure_learning_is_average_of_baseline_escapes(do_simulations)

datafile = 'c:\stetner\data\figures\xmodel\caf2.mat';
colorscheme = 'C:\stetner\code\figures\xmodel\xmodel_color_scheme.mat';
num_traces = 10;

%% Simulate data if requested
% If function is called without an argument or with an argument that is not
% 1, this step is skipped!
if exist('do_simulations', 'var') && (do_simulations == 1)
    xmodel_parameters_caf
    baseline_motifs = 1000;
    learning_motifs = 600;
    total_motifs = baseline_motifs + learning_motifs + ending_motifs;
    xmodel_initialize
    xmodel_run
    xmodel_calculate_bias
    save(datafile)
end

%% Load stuff

d = load(datafile); % Load data
c = load(colorscheme);


%% Average of baseline escapes

figure
a1 = subplot(2,1,1); 
is_baseline = (1:d.total_motifs) <= d.baseline_motifs;
baseline_escapes = squeeze(d.ra_output(1,:,is_baseline &  d.is_escape));
baseline_hits    = squeeze(d.ra_output(1,:,is_baseline & ~d.is_escape));

% example escapes
escmotif = randsample(size(baseline_escapes,2), num_traces);
plot(baseline_escapes(:,escmotif), 'Color', c.escape)

% example hits
hold on
hitmotif = randsample(size(baseline_hits,2), num_traces);
plot(baseline_hits(:,hitmotif), 'Color', c.hit)

% average of baseline escapes
avg_of_baseline_escapes = mean(baseline_escapes, 2);
plot(avg_of_baseline_escapes, 'Color', c.escape, 'LineWidth', 3)
xlim([1 (d.motif_steps + d.extra_steps)])
set(gca, 'XTick', [])
set(gca, 'FontSize', 16)
ylabel('Song (% \Delta pitch)')


%% Reward prediction error examples
rpe = d.reward - d.expected_reward(:,1:d.total_motifs);
rpe_hit = rpe(:,is_baseline & ~d.is_escape);
rpe_esc = rpe(:,is_baseline &  d.is_escape);

subplot(2,1,2)
plot(rpe_hit(:,hitmotif), 'Color', c.hit)
hold on
plot(rpe_esc(:,escmotif), 'Color', c.escape)
xlim([1 (d.motif_steps + d.extra_steps)])
set(gca, 'FontSize', 16)
xlabel('Time (ms)')
ylabel('RPE')

%% Bias before and after learning
figure
plot(d.bias(:,1), '--', 'Color', c.bias, 'LineWidth', 3)
hold on
plot(d.bias(:,end), 'Color', c.bias, 'LineWidth', 3)
set(gca, 'FontSize', 16)
xlabel('Time (ms)')

%% Plot bias after learning on top of HVC burst, average of basline
%% escapes, and reward kernel

% bias after learning
figure
t = (1:d.motif_steps) - d.caf_target_time2;
plot(t, d.bias(:,end)./max(d.bias(:,end)), 'Color', c.bias, 'LineWidth', 3)
hold on

% hvc burst
hvc_burst = d.hvc_output(1, 1:9);
t = 1:length(hvc_burst);
t = t-mean(t);
plot(t, hvc_burst./max(hvc_burst), 'Color', c.hvc, 'LineWidth', 3)

% average of baseline escapes
t = (1:d.motif_steps) - d.caf_target_time2;
plot(t, avg_of_baseline_escapes./max(avg_of_baseline_escapes), 'Color', c.escape, 'LineWidth', 3)

% reward kernel
t = 1:length(d.rkernel);
t = t-mean(t);
plot(t, d.rkernel./max(d.rkernel), 'Color', c.vta, 'LineWidth', 3)
set(gca, 'FontSize', 16)
xlabel('Time from CAF target (ms)')
legend({'Learning', 'HVC burst', 'Baseline escapes', 'Reward kernel'})