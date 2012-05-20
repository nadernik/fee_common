%% Bias

datagen = input('Do you want to run the simulation to generate new data for this figure (Y/N)? (N) ','s');
if strcmpi(datagen, 'y')
    disp('Generating data...')
    clear all

    %%%%%%%%%% Parameters %%%%%%%%%%
    strong_unit = 3;               %
    strength = 7;                  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    xmodel_parameters_bias_figure
    xmodel_initialize

    % make 4th hvc-x synapse strong
    weights_on_msn_from_hvc(strong_unit,strong_unit) = strength;

    xmodel_run
    save c:\stetner\data\xmodel\bias.mat
else
    disp('Skipping simulation...')
end

%%
disp('Making figure...')
clear all
load c:\stetner\data\xmodel\bias.mat
c = load('c:\stetner\code\figures\xmodel\xmodel_color_scheme.mat');

%%%%%%%%%% Parameters %%%%%%%%%%
units_to_plot = 1:2:hvc_units; %
dy = 2;                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
for motif = 1:total_motifs
    hold on
    y0 = 0;

    % hvc activity
    for h = units_to_plot
        plot(hvc_output(h,:) - y0, 'Color', c.hvc, 'LineWidth', 3)
        y0 = y0+dy;
    end
    y0 = y0+2*dy;

    % msn activity for the msns that project to 1st lman unit
    for m = units_to_plot
        if weights_on_msn_from_lman(m,1) > 0
            plot(squeeze(msn_output(m,:,motif))/ ...
                weights_on_msn_from_hvc(strong_unit,strong_unit) - y0, ...
                'Color', c.msn, 'LineWidth', 3)
            y0 = y0+dy;
        end
    end

    % lman activity of 1st lman unit
    y0 = y0+2*dy;
    plot(squeeze((lman_output(1,:,motif)) - lman_offset)/strength*3 - y0, ...
        'Color', c.lman, 'LineWidth', 3)

    set(gca, 'YTick', [-27, -18, -4])
    set(gca, 'YTickLabel', {'LMAN', 'MSN', 'HVC'})
    set(gca, 'FontSize', 16)
    xlabel('Time (ms)')
    fprintf('Motif %03.f of %03.f (Enter for next)\n',motif,total_motifs)
    pause
    clf
end