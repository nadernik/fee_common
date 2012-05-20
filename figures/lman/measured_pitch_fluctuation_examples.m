num_traces = 10; % number of traces to plot
% bird_names = {'mes010', 'mes003', '1772'};
bird_names = {'mes003', 'black401', 'blue298'};
% bird_names = {'mes011', 'black401', 'blue298'};
base_filename = 'C:\\stetner\\data\\pitchfluctuations\\40ms_stacks_for_figure\\%s_yesdc.mat';
randseed = 2891;
my_ylim = [-9 9];

%%
rand('twister', randseed) %set the seed of the random number generator
total_birds = length(bird_names);
figure
for nbird = 1:total_birds
    subplot(total_birds,1,nbird)
    filename = sprintf(base_filename, bird_names{nbird});
    load(filename, 'pitches')
    selected = randsample(size(pitches, 2), num_traces);
    plot(pitches(:,selected), 'k', 'LineWidth', 2)
    ylim(my_ylim)
    clear pitches
    axis off
end

% Draw scale bars
patch([0, 0, .2, .2], [-9, -4, -4, -9], 'k') % 5 percent pitch change for y axis
patch([40, 40, 30, 30], [-9, -8.8, -8.8, -9], 'k') % 10 milliseconds for x axis