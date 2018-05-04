function figure_covert_learning(do_simulations)
% Figure showing my model doing the "covert learning" of Charlesworth et
% al. 2012. Noise generated in RA and transmitted through DLM and LMAN to
% Area X drives learning even when LMAN->RA connection is blocked. Learning
% is only revealed when LMAN-> connection is restored.

%% Filenames and parameters
data_path = 'c:\stetner\data\xmodel\covert';
filename_normal = @(n) fullfile(data_path, sprintf('normal%02.f.mat', n));
filename_cut = @(n) fullfile(data_path, sprintf('cut%02.f.mat', n));
filename_inactivated = @(n) fullfile(data_path, sprintf('inactivated%02.f.mat', n));
p.ra_noise_amplitude = 0.65; % between 0 and 1
p.ra_dlm_strength = 0.25; % between 0 and 1 (must be less than 1)
runs = 10; % number of simulations to run for each group
% After each simulation, all of the variables will be cleared except for
% these:
%% Simulations
if exist('do_simulations', 'var') && do_simulations == 1
    for nrun = 1:runs
        fprintf('Starting run %g\n', nrun)
        simulate_normal(filename_normal(nrun), p)
        simulate_cut(filename_cut(nrun), p)
        simulate_inactivated(filename_inactivated(nrun), p)
    end
end

%% (A) Pitch variability bar graph
% Compare the standard deviation of the pitch at the target time
% before CAF starts. Cut and inactivation conditions have about 65% of the
% standard deviation of the normal condition.
for nrun = 1:runs
    stdnorm(nrun)  = get_pitch_std_baseline(filename_normal(nrun));
    stdcut(nrun)   = get_pitch_std_baseline(filename_cut(nrun));
    stdinact(nrun) = get_pitch_std_baseline(filename_inactivated(nrun));
end

% Normalize to normal case
stdinact = stdinact ./ mean(stdnorm);
stdcut   = stdcut   ./ mean(stdnorm);
stdnorm  = stdnorm  ./ mean(stdnorm);

figure
X = 1:3;
Y = [mean(stdnorm), mean(stdcut), mean(stdinact)];
E = [sem(stdnorm), sem(stdcut), sem(stdinact)]; % error bars are standard error of the mean
bar(X, Y)
hold on
errorbar(X, Y, E, '.')
ylim([0, 1+max(E)*2])
set(gca, 'XTick', 1:3)
set(gca, 'XTickLabel', {'Normal', 'LMAN-RA cut', 'LMAN inactivated'})
ylabel('Standard deviation of output at target time')
title('Variability reduction from LMAN-RA cut and LMAN inactivation')

%% (B) Pitch over time plot
figure
axh(1) = subplot(1,3,1);
plot_average_pitch(filename_normal(1))
title('Normal')
axh(2) = subplot(1,3,2);
plot_average_pitch(filename_cut(1), true)
title('LMAN-RA cut')
axh(3) = subplot(1,3,3);
plot_average_pitch(filename_inactivated(1), true)
title('LMAN inactivated')
linkaxes(axh)

%% (C) Pitch bar graph
figure
for nrun = 1:runs
    [L1norm(nrun), L2norm(nrun)] = get_learning(filename_normal(nrun));
    [L1cut(nrun), L2cut(nrun)] = get_learning(filename_cut(nrun));
    [L1inact(nrun), L2inact(nrun)] = get_learning(filename_inactivated(nrun));
end
X = [1, 2, 4, 5, 7, 8];
Y = [mean(L1norm), mean(L2norm), mean(L1cut), mean(L2cut), mean(L1inact), mean(L2inact)];
E = [sem(L1norm), sem(L2norm), sem(L1cut), sem(L2cut), sem(L1inact), sem(L2inact)];
bar(X, Y)
hold on
errorbar(X, Y, E, '.')
set(gca, 'XTick', X)
set(gca, 'XTickLabel', {'Normal 1', 'Normal 2', 'LMAN-RA block 1', ...
    'LMAN-RA block 2', 'LMAN inactivation 1', 'LMAN inactivation 2'})
ylabel('Change in pitch')

%% Bias over time

for nrun = 1:runs
    Bnorm(:,nrun) = get_bias(filename_normal(nrun));
    Bcut(:,nrun) = get_bias(filename_cut(nrun));
    Binact(:,nrun) = get_bias(filename_inactivated(nrun));
end

figure
subplot(1,3,1)
plot(Bnorm)
xlabel('Motifs')
ylabel('Bias')
title('Normal')
subplot(1,3,2)
plot(Bcut)
xlabel('Motifs')
title('LMAN-RA cut')
subplot(1,3,3)
plot(Binact)
xlabel('Motifs')
% title('LMAN inactivated')

%% Supplemental (A) Pitch traces

% figure
% nplot = 5; % number of motifs to plot
% ymin = -8;
% ymax =  8;
% % first nplot trials of baseline
% assert(baseline_motifs >= nplot)
% subplot(3,3,1)
% plot(dnorm.pitch(:,1:nplot))
% title('Baseline, normal')
% ylabel('Pitch')
% ylim([ymin, ymax])
% subplot(3,3,2)
% plot(dcut.pitch(:,1:nplot))
% title('Baseline, LMAN-RA cut')
% ylim([ymin, ymax])
% subplot(3,3,3)
% plot(dinact.pitch(:,1:nplot))
% title('Baseline, LMAN inactivated')
% ylim([ymin, ymax])
% % last 10 trials of learning period (block or inactivation still in effect)
% last_learning_trials = (-nplot:-1) + 1 + baseline_motifs + learning_motifs;
% subplot(3,3,4)
% plot(dnorm.pitch(:,last_learning_trials))
% title('End of learning, normal')
% ylabel('Pitch')
% ylim([ymin, ymax])
% subplot(3,3,5)
% plot(dcut.pitch(:,last_learning_trials))
% title('End of learning, LMAN-RA cut')
% ylim([ymin, ymax])
% subplot(3,3,6)
% plot(dinact.pitch(:,last_learning_trials))
% title('End of learning, LMAN inactivated')
% ylim([ymin, ymax])
% % first 10 trials after learning, block or inactivation removed
% first_post_learning_trials = (1:nplot) + baseline_motifs + learning_motifs;
% subplot(3,3,7)
% plot(dnorm.pitch(:,first_post_learning_trials))
% title('After learning, normal')
% xlabel('Time (ms)')
% ylim([ymin, ymax])
% ylabel('Pitch')
% subplot(3,3,8)
% plot(dcut.pitch(:,first_post_learning_trials))
% title('After learning, LMAN-RA restored')
% xlabel('Time (ms)')
% ylim([ymin, ymax])
% subplot(3,3,9)
% plot(dinact.pitch(:,first_post_learning_trials))
% title('After learning, LMAN reactivated')
% xlabel('Time (ms)')
% ylim([ymin, ymax])
end

function simulate_normal(filename, p)
xmodel_parameters_caf
ra_noise_amplitude = p.ra_noise_amplitude;
ra_dlm_strength = p.ra_dlm_strength;
xmodel_initialize_ra_to_dlm
xmodel_run_ra_to_dlm_slow
save(filename)
end

function simulate_cut(filename, p)
xmodel_parameters_caf
ra_noise_amplitude = p.ra_noise_amplitude;
ra_dlm_strength = p.ra_dlm_strength;
xmodel_initialize_ra_to_dlm
lman_ra_cut = true;
xmodel_run_ra_to_dlm_slow
save(filename)
end

function simulate_inactivated(filename, p)
xmodel_parameters_caf
ra_noise_amplitude = p.ra_noise_amplitude;
ra_dlm_strength = p.ra_dlm_strength;
xmodel_initialize_ra_to_dlm
lman_inactivated = true;
weights_on_lman_from_dlm = zeros(size(weights_on_lman_from_dlm));
xmodel_run_ra_to_dlm_slow
save(filename)
end

function pstd = get_pitch_std_baseline(filename)
% Standard deviation of pitch at the time targed by caf, baseline motifs
% only
load(filename, 'baseline_motifs', 'pitch', 'caf_target_time2')
pstd = std(pitch(caf_target_time2, 1:baseline_motifs));
end

function plot_average_pitch(filename, showbar)
% Plotting parameters
nsmooth = 50;
plinespec = 'k';
blinespec = '-';
bcolor = [.8 1 .8];
linewidth = 2;
ymin = -3;
ymax = 5;
ybar = 4.5; % vertical position of bar showing when block is active
hbar = 0.15; % height of bar showing when block is active
cbar = [1 0 0]; % color of bar showing when block is active


load(filename, 'total_motifs', 'baseline_motifs', 'learning_motifs', 'total_motifs', 'ending_motifs', 'pitch', 'caf_target_time2', 'caf_pitch_threshold2', 'bias')
b = bias(caf_target_time2, :);
plot(1:total_motifs, b, blinespec, 'LineWidth', linewidth, 'Color', bcolor)
hold on
% during block (baseline and learning)
motifs = 1:(baseline_motifs + learning_motifs);
p = pitch(caf_target_time2, motifs);
psmooth = smoothma(p, nsmooth);
plot(motifs, psmooth, plinespec, 'LineWidth', linewidth)
% after block removed (ending)
motifs = (1:ending_motifs) + baseline_motifs + learning_motifs;
p = pitch(caf_target_time2, motifs);
psmooth = smoothma(p, nsmooth);
plot(motifs, psmooth, plinespec, 'LineWidth', linewidth)
% transparent box showing caf
x = baseline_motifs;
y = ymin;
w = learning_motifs;
h = caf_pitch_threshold2 - ymin;
rectangle('Position', [x y w h])
if exist('showbar', 'var') && showbar == true
    X = baseline_motifs + [1, learning_motifs, learning_motifs, 1];
    Y = [0 0 hbar hbar] + ybar;
    fill(X, Y, cbar, 'LineStyle', 'none')
end
ylim([ymin, ymax])
xlim([0 total_motifs])
hold off
xlabel('Motifs')
ylabel('Pitch at target time')
end

function [L1, L2] = get_learning(filename)
load(filename, 'pitch', 'ending_motifs', 'caf_target_time2')
L1 = mean(pitch(caf_target_time2, end-ending_motifs-50:end-ending_motifs));
L2 = mean(pitch(caf_target_time2, end-ending_motifs:end-ending_motifs+50));
end

function b = get_bias(filename)
load(filename, 'bias', 'caf_target_time2')
b = bias(caf_target_time2, :);
end