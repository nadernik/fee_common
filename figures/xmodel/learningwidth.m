dc_levels = [0, 0.4, 1, 2, 3, 4, 6, Inf];

%% for each run
for ndc = 4:length(dc_levels)
    ndc
    save('temp.mat', 'dc_levels', 'ndc')
    close all
    clear all
    load('temp.mat')
    
    xmodel_parameters;
    xmodel_initialize;
    
    % set noise based on dc level
    dc = dc_levels(ndc);
    for u = 1:lman_units
        lman_noise(u, :, :) = generate_lman_noise_set_dc(motif_steps, total_motifs, dc);
    end
    
    xmodel_run;
    
    savefile = ['c:\stetner\data\figures\xmodel\learningwidth' int2str(ndc)];
    save(savefile)

end


%%
close all
clear all

% plot average of baseline escapes

% plot lman autocorrelation with dc

% plot lman autocorrelation withOUT dc

for nrun = 1:8
    d = load(['c:\stetner\data\figures\xmodel\learningwidth' int2str(nrun)]);
    figure
    
    % LMAN autocorr
%     subplot(1,3,1)
    


    % Average of baseline escapes
    figure(nrun)
    subplot(1,2,1)
    all_baseline_motifs = squeeze(d.ra_output(1, :, 1:d.baseline_motifs));
    baseline_escapes = all_baseline_motifs(:, d.is_escape(1:d.baseline_motifs));
    plot(all_baseline_motifs, 'Color', [.8, .8, .8])
    hold on
    plot(baseline_escapes, 'Color', [1, .8, .8])
    plot(mean(baseline_escapes, 2), 'r', 'LineWidth', 3)
    
    % Compare learning to eligibility trace
    subplot(1,2,2)
    predicted_learning = mean(baseline_escapes, 2) - mean(all_baseline_motifs, 2);
    predicted_learning = predicted_learning ./ max(predicted_learning); % Normalize to 1
    t = (1:length(d.ekernel)) - length(d.ekernel)/2;
    plot(t,d.ekernel, 'k', 'LineWidth', 3)
    hold all
    n = d.ending_motifs; % number of trials to average to get final pitch trajectory
    last_motifs = squeeze(d.ra_output(1, :, end-n:end));
    actual_learning = mean(last_motifs, 2) - mean(all_baseline_motifs, 2);
    actual_learning = actual_learning ./ max(actual_learning); % normalize to 1
    t = (1:length(actual_learning)) - length(actual_learning)/2;
    plot(t,actual_learning, 'g', 'LineWidth', 3)
    plot(t,predicted_learning,'r','LineWidth', 3)

    
    figure(1000)
    plot(predicted_learning)
    hold all
    
    figure(2000)
    plot(actual_learning)    
    hold all
    
    clear d
end