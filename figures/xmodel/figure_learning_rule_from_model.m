function figure_learning_rule_from_model(do_simulations)
% Like learning_rule.m, but uses actual output from the model!

datafile = 'c:\stetner\data\figures\xmodel\learning_rule_from_model.mat';
colorfile = 'c:\stetner\code\figures\xmodel\xmodel_color_scheme.mat';
dyoffset = 2;
motifs_between_fluctuations = 30;
fluctuation_time = 13; % ms
fluctuation_sd = 2; % ms
fluctuation_amplitude = 5;
chosen_motif = 91;

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

    xmodel_run

    save(datafile)
end

%% Make plots

% Load data
d = load(datafile);
c = load(colorfile);

% Calculate reward prediction error
rpe = d.reward - d.expected_reward(:,1:d.total_motifs);

% calculate LMAN output from its inputs, since LMAN output itself is not
% saved for each motif
for motif = 1:d.total_motifs
    lman_input = d.lman_noise(:,:,motif) + d.weights_on_lman_from_dlm * d.dlm_output(:,:,motif);
    lman_output(:,:,motif) = max(lman_input + d.lman_offset, 0);
end


% If there is a chosen motif, just show that one. Otherwise, plot each of
% the motifs that have a big fluctuation and pause after plotting each one.
if isempty(chosen_motif)
    motifs_to_plot = motifs_between_fluctuations+1:motifs_between_fluctuations:d.total_motifs;
else
    motifs_to_plot = chosen_motif;
end

figure
for motif = motifs_to_plot
    yticks = [];
    yticklabels = {};
    clf
    hold on
    yoffset = 0; %plot each line offset by this much (will be incremented after plotting each thing)
    
    % plot vocal output and template
    normalized_template      = d.template               ./ max(d.template);
    average_song = mean(d.ra_output(1,:,:), 3);
    normalized_good_song     = squeeze(d.ra_output(1, :, motif)) ./ max(d.template);
    plot(normalized_template - yoffset, '--', 'Color', c.template, 'LineWidth', 3)
    plot(average_song- - yoffset, 'Color', colorv(colorsat(c.template, 0.1), 0.9), 'LineWidth', 3)
    plot(normalized_good_song - yoffset, 'Color', c.template, 'LineWidth', 3)
    y1(1) = max(normalized_good_song) - yoffset; % used to make dotted line marking the time of the good pitch fluctuation
    yticks = [yticks, -yoffset];
    yticklabels = [yticklabels, 'Song'];
    yoffset = yoffset + 2 * dyoffset;
    
    % plot lman (pitch up channel)

    normalized_good_lman     = squeeze(lman_output(1, :, motif)) ./ max(d.template);
%     normalized_other_lman = squeeze(d.lman_output(1, :, motif - (1:4))) ./ max(d.template);
%     plot(normalized_other_lman - yoffset, 'Color', colorv(colorsat(c.lman, 0.1), 0.9), 'LineWidth', 3)
    plot(normalized_good_lman     - yoffset,       'Color', c.lman,     'LineWidth', 3)
    yticks = [yticks, -yoffset];
    yticklabels = [yticklabels, 'LMAN+'];
    yoffset = yoffset + 2 * dyoffset;
    
    % plot reward
    temp = zscore(rpe(:)) ./ 3;
    normalized_rpe = reshape(temp, size(rpe));
    plot(normalized_rpe(:, motif) - yoffset, 'Color', c.vta, 'LineWidth', 3)
    yticks = [yticks, -yoffset];
    yticklabels = [yticklabels, 'Reinforcement Signal'];
    [y2(1), x2(1)] = max(normalized_rpe(:, motif) - yoffset); % used to make dotted line marking peak reinforcement
    yoffset = yoffset + dyoffset;
    
    % plot hvc
	normalized_hvc = d.hvc_output;
    for h = 1:2:d.hvc_units
        plot(normalized_hvc(h,:) - yoffset, 'Color', c.hvc, 'LineWidth', 3)
        yticks = [yticks, -yoffset];
        yticklabels = [yticklabels, int2str(h)];
        [hmax, imax] = max(normalized_hvc(h, :) - yoffset);
        if imax == fluctuation_time
            target_hvc_unit = h;
            y1(2) = hmax;
        end
        yoffset = yoffset + dyoffset;
    end
    
    % plot eligibility traces
    L = ones(d.hvc_units, 1) * normalized_good_lman;
    eligibility_trace = conv2(normalized_hvc .* L, d.ekernel);
    eligibility_trace = eligibility_trace ./ globalmax(eligibility_trace);
    for h = 1:2:d.hvc_units
        plot(eligibility_trace(h,:) - yoffset, 'Color', c.etrace, 'LineWidth', 3)
        if h == target_hvc_unit
            [y2(2), x2(2)] = max(eligibility_trace(h,:) - yoffset);
        end
        yticks = [yticks, -yoffset];
        yticklabels = [yticklabels, int2str(h)];
        yoffset = yoffset + dyoffset;
    end
    
    % dotted line from peak of song to peak of lman activity
    x1 = ones(2,1) * fluctuation_time;
    LH1 = line(x1, y1);
    set(LH1, 'LineStyle', ':', 'Color', [0 0 0])
    
    % dotted line from peak of reward to peak of eligibility trace
    x2 = ones(2,1) * x2(1);
    LH2 = line(x2, y2);
    set(LH2, 'LineStyle', ':', 'Color', [0 0 0])
    
    set(gca, 'FontSize', 16)
    xlabel('Time (ms)')
    set(gca, 'YTick', wrev(yticks))
    set(gca, 'YTickLabel', wrev(yticklabels))
    set(gcf, 'OuterPosition', [1 1 600 1000])
    if isempty(chosen_motif)
        title(int2str(motif))
        pause
        clf
    end
end