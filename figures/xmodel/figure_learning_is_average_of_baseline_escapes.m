function figure_learning_is_average_of_baseline_escapes(do_simulations)

datafile = 'c:\stetner\data\figures\xmodel\caf3.mat';
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

% example hits
hold on
hitmotif = size(baseline_hits,2) - (0:num_traces-1);%randsample(size(baseline_hits,2), num_traces);
plot(baseline_hits(:,hitmotif), 'Color', c.hit)

% example escapes
escmotif = size(baseline_escapes,2) - (0:num_traces-1);%randsample(size(baseline_escapes,2), num_traces);
plot(baseline_escapes(:,escmotif), 'Color', c.escape)

% average of baseline escapes
avg_of_baseline_escapes = mean(baseline_escapes, 2);
fprintf('There are a total of %g baseline escapes and %g baseline hits.\n', size(baseline_escapes,2), size(baseline_hits, 2))
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
% normalize so that the max of the bias after learning is 1.
Z = max(d.bias(:,end)); % normalization constant
plot(d.bias(:,1)/Z, ':', 'Color', c.bias, 'LineWidth', 3)
hold on
plot(d.bias(:,end)/Z, 'Color', c.bias, 'LineWidth', 3)
set(gca, 'FontSize', 16)
xlabel('Time (ms)')

% Full width at half maximum of bias after learning
[width, xw] = fwhm(d.bias(:,end));
y = [0.5, 0.5];
[fx, fy] = dsxy2figxy(xw, y);
annotation('doublearrow',fx,fy)
str = sprintf('%.1f ms', width);
text(xw(2)+width, 0.5, str);

set(gca, 'YTick', [0 1])
%% Plot bias after learning on top of HVC burst, average of basline
%% escapes, and reward kernel

% bias after learning
figure
t_bias = (1:d.motif_steps) - d.caf_target_time2;
y_bias = d.bias(:,end)./max(d.bias(:,end));
plot(t_bias, y_bias, 'Color', c.bias, 'LineWidth', 3)
hold on
fprintf('Full width at half maximum of bias after learning is %g ms.\n', fwhm(d.bias(:,end)))

% hvc burst
hvc_burst = d.hvc_output(1, 1:9);
t = 1:length(hvc_burst);
t_hvc = t-mean(t);
y_hvc = hvc_burst./max(hvc_burst);
plot(t_hvc, y_hvc, 'Color', c.hvc, 'LineWidth', 3)
fprintf('Full width at half maximum of HVC burst is %g ms.\n', fwhm(hvc_burst))

% average of baseline escapes
t_esc = (1:d.motif_steps) - d.caf_target_time2;
y_esc = avg_of_baseline_escapes./max(avg_of_baseline_escapes);
plot(t_esc, y_esc, 'Color', c.escape, 'LineWidth', 3)
fprintf('Full width at half maximum of average of baseline escapes is %g ms.\n', fwhm(avg_of_baseline_escapes))

% reward kernel
t = 1:length(d.rkernel);
t_rwd = t-mean(t);
y_rwd = d.rkernel./max(d.rkernel);
plot(t_rwd, y_rwd, 'Color', c.vta, 'LineWidth', 3)
fprintf('Full width at half maximum of reward kernel is %g ms.\n', fwhm(d.rkernel))

set(gca, 'FontSize', 16, 'YTick', [0 1])
xlabel('Time from CAF target (ms)')
legend({'Learning', 'HVC burst', 'Baseline escapes', 'Reward kernel'})

save('c:\stetner\data\figures\xmodel\caf_example.mat', ...
    't_bias', 'y_bias', 't_hvc', 'y_hvc', 't_esc', 'y_esc', 't_rwd', 'y_rwd', ...
    'rpe_hit', 'rpe_esc', 'hitmotif', 'escmotif')