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

    % make one hvc-x synapse strong
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

% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
units_to_plot = 1:2:hvc_units; % which hvc units to show
num_motifs = 5; % number of motifs to display
dy = 2; % distance between traces on y axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while true
    
    % select motifs to plot
    selected_motifs = randsample(total_motifs, num_motifs);
    
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
            plot(squeeze(msn_output(m,:))/ ...
                weights_on_msn_from_hvc(strong_unit,strong_unit) - y0, ...
                'Color', c.msn, 'LineWidth', 3)
            y0 = y0+dy;
        end
    end

    % lman activity of 1st lman unit (pitch up channel)
    y0 = y0+2*dy;
    for ii = 1:length(selected_motifs)
        motif = selected_motifs(ii);
        L(:,ii) = weights_on_lman_from_dlm(1,:) * dlm_output(:,:,motif) + ...
            lman_noise(1,:,motif);
    end
    
    plot(L/strength*3 - y0, ...
        'Color', c.lman, 'LineWidth', 3)
    
    % pitch
    y0 = y0 + 5*dy;
    plot(squeeze((ra_output(1,:,selected_motifs)))/strength*3 - y0, 'Color', c.template, 'LineWidth', 3)
    

    set(gca, 'YTick', [-38, -27, -18, -4])
    set(gca, 'YTickLabel', {'Pitch', 'LMAN+', 'MSN', 'HVC'})
    set(gca, 'FontSize', 16)
    xlabel('Time (ms)')
    disp(['Motifs: ' num2str(sort(selected_motifs')) '. [Enter] for another random set of motifs.'])
    ylim([-y0-2*dy, dy])
    xlim([0 40])
    
    pause
    clf
end