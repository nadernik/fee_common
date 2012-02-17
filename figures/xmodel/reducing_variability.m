% reducing_variability shows that xmodel can learn to reduce variability by
% increasing activity in the indirect pathway

%%
close all
clear all
for run = 1:1
    run
    xmodel_parameters_indirect_squish
    xmodel_initialize_indirect
    xmodel_run_indirect
    save(['C:\stetner\data\figures\xmodel\reducing_variability_redo_' int2str(run)])
    save temp run
    clear all
    load temp
end
%%
example_run_file = 'C:\stetner\data\figures\xmodel\reducing_variability5.mat';
N = 100; % number of pitch traces to show before and after learning
histogram_bin_edges = -10:0.5:10;
% load(example_run_file)
colors.hits = [1 .8 .8]; % light red
colors.escapes = [.8 .8 .8]; % light gray
colors.before = 'k';
colors.after = 'm';

is_before = (1:total_motifs) <= N;
is_after = (1:total_motifs) > total_motifs-N;

% pitch traces before learning
figure
a(1) = subplot(4,1,1);
hold on
plot(squeeze(ra_output(1,:,is_before & ~is_escape)), 'Color', colors.hits)
plot(squeeze(ra_output(1,:,is_before & is_escape)), 'Color', colors.escapes)
plot(mean(ra_output(1,:,is_before & is_escape), 3), ':', 'Color', colors.before,'LineWidth', 3)

% pitch traces after learning
a(2) = subplot(4,1,2);
hold on
plot(squeeze(ra_output(1,:,is_after & ~is_escape)), 'Color', colors.hits)
plot(squeeze(ra_output(1,:,is_after & is_escape)), 'Color', colors.escapes)
plot(mean(ra_output(1,:,is_after), 3), ':', 'Color', colors.after,'LineWidth', 3)

% show direct and indirect pathway activity, pitch up neuron only
direct_pathway_activity = squeeze(  mean(sum(direct_msn_output(:, :, end-N+1:end), 1), 3)  );
indirect_pathway_activity = squeeze(  mean(sum(indirect_msn_output(:, :, end-N+1:end), 1), 3)  );
ylo = min(min(direct_pathway_activity), min(indirect_pathway_activity));
yhi = max(max(direct_pathway_activity), max(indirect_pathway_activity));

a(3) = subplot(4,1,3);
plot(direct_pathway_activity)
ylim([ylo yhi])

a(4) = subplot(4,1,4);
plot(indirect_pathway_activity)
ylim([ylo yhi])

linkaxes(a, 'x')
xlim([0 motif_steps])

% histograms before/after
bin_centers = -19.5:1:19.5;
figure
counts = hist(squeeze(ra_output(1,caf_target_time2,is_before)),bin_centers);
stairs(bin_centers, counts, 'Color', colors.before,'LineWidth', 3)
hold on
counts = hist(squeeze(ra_output(1,caf_target_time2,is_after)),bin_centers);
stairs(bin_centers, counts, 'Color', colors.after,'LineWidth', 3)

%% 

