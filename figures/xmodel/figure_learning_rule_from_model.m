function figure_learning_rule_from_model(do_simulations)
% Like learning_rule.m, but uses actual output from the model!

datafile = 'c:\stetner\data\figures\xmodel\learning_rule_from_model.mat';
colorfile = 'c:\stetner\code\figures\xmodel\xmodel_color_scheme.mat';
dyoffset = 2;
motifs_between_fluctuations = 30;
fluctuation_time = 13; % ms
fluctuation_sd = 2; % ms
fluctuation_amplitude = 5;
chosen_motif = 721;

%% Generate data if requested
% If argument is omitted, skip the simulations. Only do simulations is the
% argument is 1
if exist('do_simulations', 'var') && (do_simulations == 1)
    % Insert large LMAN fluctuations into the noise and use the model code
    % to calculate everything
    
    % Big LMAN fluctuation is shaped like a Gaussian
    tfluct = (-3 * fluctuation_sd : 3 * fluctuation_sd) + fluctuation_time;
    big_fluctuation = normpdf(tfluct, fluctuation_time, fluctuation_sd);
    big_fluctuation = big_fluctuation/max(big_fluctuation) * fluctuation_amplitude;

    xmodel_parameters_learning_rule_figure
    xmodel_initialize

    % Insert a big fluctuation into noise every mo motifs
    for motif = 1:motifs_between_fluctuations:total_motifs
        lman_noise(1,tfluct,motif) = lman_noise(1,tfluct,motif) + big_fluctuation;
    end
    lman_noise(2,:,:) = 0;

    xmodel_run

    save(datafile)
end

%% Make plots

% Load data
d = load(datafile, 'reward', 'expected_reward', 'hvc_output', 'lman_output', 'hvc_units', 'template', 'ekernel', 'total_motifs');
c = load(colorfile);

% Calculate reward prediction error
rpe = d.reward - d.expected_reward(:,1:d.total_motifs);

% If there is a chosen motif, just show that one. Otherwise, plot each of
% the motifs that have a big fluctuation and pause after plotting each one.
if isempty(chosen_motif)
    motifs_to_plot = 1:motifs_between_fluctuations:d.total_motifs;
else
    motifs_to_plot = chosen_motif;
end

figure
for motif = motifs_to_plot
    clf
    hold on
    yoffset = 0; %plot each line offset by this much (will be incremented after plotting each thing)
        
    % plot lman and template
    normalized_template = d.template                 ./ max(d.template);
    normalized_lman     = d.lman_output(1, :, motif) ./ max(d.template);
    plot(normalized_template - yoffset, '--', 'Color', c.template, 'LineWidth', 3)
    plot(normalized_lman     - yoffset,       'Color', c.lman,     'LineWidth', 3)
    ylman = yoffset; % will put a label for LMAN at the current yoffset
    yoffset = yoffset + 2 * dyoffset;
    
    % plot reward
    temp = zscore(rpe(:)) ./ 3;
    normalized_rpe = reshape(temp, size(rpe));
    plot(normalized_rpe(:, motif) - yoffset, 'Color', c.vta, 'LineWidth', 3)
    yrpe = yoffset; % will put a label for RPE at the current yoffset
    yoffset = yoffset + dyoffset;

    % plot every other hvc unit overlayed with its eligibility trace
    yhvc1 = yoffset;
	normalized_hvc = d.hvc_output;
    L = ones(d.hvc_units, 1) * normalized_lman;
    eligibility_trace = conv2(normalized_hvc .* L, d.ekernel);
    eligibility_trace = eligibility_trace ./ globalmax(eligibility_trace);
    for h = 1:2:d.hvc_units
        plot(normalized_hvc(h,:) - yoffset, 'Color', c.hvc, 'LineWidth', 3)
        plot(eligibility_trace(h,:) - yoffset, '--', 'Color', c.etrace, 'LineWidth', 3)
        yhvc2 = yoffset;
        yoffset = yoffset + dyoffset;
    end
    yhvc = (yhvc1 + yhvc2) / 2;
    
    set(gca, 'FontSize', 16)
    xlabel('Time (ms)')
    set(gca, 'YTick', -[yhvc, yrpe, ylman])
    set(gca, 'YTickLabel', {'HVC', 'RPE', 'LMAN'})
    set(gcf, 'OuterPosition', [1 1 600 1000])
    if isempty(chosen_motif)
        title(int2str(motif))
        pause
        clf
    end
end