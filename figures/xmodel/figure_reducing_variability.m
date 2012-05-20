function figure_reducing_variability(do_simulations)
% reducing_variability shows that xmodel can learn to reduce variability by
% increasing activity in the indirect pathway

datafile = 'C:\stetner\data\figures\xmodel\reducing_variability.mat';
colorfile = 'C:\stetner\code\figures\xmodel\xmodel_color_scheme.mat';
N = 25; % number of pitch traces to show before and after learning
bin_centers = -4.5:1:4.5;

%%
if exist('do_simulations', 'var') && (do_simulations == 1)
    xmodel_parameters_indirect_squish
    xmodel_initialize_indirect
    xmodel_run_indirect
    save(datafile)
end

%% Load data
d = load(datafile);
c = load(colorfile);

%% Plots of pitch traces color coded by hit/escape, before learning
figure
is_before = (1:d.total_motifs) <= N;
a(1) = subplot(4,1,1);
hold on
plot(squeeze(d.ra_output(1,:,is_before & ~d.is_escape)), 'Color', c.hit)
plot(squeeze(d.ra_output(1,:,is_before & d.is_escape)), 'Color', c.escape)

%% Plots of pitch traces color coded by hit/escape, AFTER learning
is_after = (1:d.total_motifs) > d.total_motifs-N;
a(2) = subplot(4,1,2);
hold on
try
    plot(squeeze(d.ra_output(1,:,is_after & ~d.is_escape)), 'Color', c.hit)
catch
    disp('No escape hit trials after learning')
end

plot(squeeze(d.ra_output(1,:,is_after & d.is_escape)), 'Color', c.escape)

%% show direct and indirect pathway activity, pitch up neuron only
up_neurons = d.weights_on_direct_msn_from_lman(:,1) > 0;
direct_pathway_activity   = squeeze(  mean(sum(d.direct_msn_output(  up_neurons, :, end), 1), 3)  );
indirect_pathway_activity = squeeze(  mean(sum(d.indirect_msn_output(up_neurons, :, end), 1), 3)  );
ylo = min(min(direct_pathway_activity), min(indirect_pathway_activity));
yhi = max(max(direct_pathway_activity), max(indirect_pathway_activity));

a(3) = subplot(4,1,3);
plot(direct_pathway_activity, 'LineWidth', 3, 'Color', c.bias)
ylim([ylo yhi])

a(4) = subplot(4,1,4);
plot(indirect_pathway_activity, 'LineWidth', 3, 'Color', c.bias)
ylim([ylo yhi])

linkaxes(a, 'x')
xlim([0 d.motif_steps])

%% Histogram of pitch at target time before and after learning
figure
is_baseline = (1:d.total_motifs) <= d.baseline_motifs;
is_ending = (d.total_motifs:-1:1) <= d.ending_motifs;
pitch_before = squeeze(d.ra_output(1,d.caf_target_time2,is_baseline));
counts = hist(pitch_before, bin_centers);
stairs(bin_centers, counts/sum(counts),'LineWidth', 3, 'Color', [.7 .7 .7])
hold on
pitch_after = squeeze(d.ra_output(1,d.caf_target_time2,is_ending));
counts = hist(pitch_after,bin_centers);
stairs(bin_centers, counts/sum(counts),'LineWidth', 3, 'Color', [0 0 0])
xlabel('Pitch')
ylabel('Probability')

fprintf('Standard deviation of pitch is %g before and %g after learning.\n', std(pitch_before), std(pitch_after))