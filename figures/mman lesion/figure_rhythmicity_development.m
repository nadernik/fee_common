
figure
axes_amp_control = axes;
axes_amp_lesion = axes_amp_control;

figure
axes_freq_control = axes;
axes_freq_lesion = axes_freq_control;

% Lesioned
birdList = {'2296', '2303', '2423', '2428'};
datadir = 'c:\stetner\data\mman lesion\rhythmicity development';
rhythmicity_development_population_avg2(birdList, datadir, ...
    'AxesAmp', axes_amp_lesion, ...
    'AxesFreq', axes_freq_lesion, ...
    'Color', 'r')

% Control
birdList = {'to2223','to2241','to2253','to2313','to2352','to2403'};
datadir = 'c:\stetner\data\rhythmicity development (TO)';
rhythmicity_development_population_avg2(birdList, datadir, ...
    'AxesAmp', axes_amp_control, ...
    'AxesFreq', axes_freq_control, ...
    'Color', 'k')