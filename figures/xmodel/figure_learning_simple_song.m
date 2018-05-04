function figure_learning_simple_song(do_simulations)

filename = 'c:\stetner\data\figures\xmodel\learning_simple_song.mat';

%% Run simulation
if exist('do_simulations', 'var') && do_simulations
    xmodel_parameters_simplesong
    xmodel_initialize
    xmodel_run
    xmodel_calculate_bias
    save(filename);
end

%% Load data
d = load(filename);

%% Plot template with song at the end of learning and example MSNs
figure
msn_examples(d, 5:10:45)


%% Plot mean squared error
figure
plotmsebias(d)

%% Plot image of activity in all UP channel MSNs
figure
imagesc(d.msn_output(1:d.hvc_units,:,end))
colorbar
xlabel('Time (ms)')
ylabel('MSN')
set(gca, 'YTick', 5:10:d.hvc_units)