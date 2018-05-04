function stim_traces_over_time(datadir, varargin)
P.chan = 1;
P.window = [-10 30]; %milliseconds
P.use_file = [];
P.time_zero = 0;
P.threshold_frac = 0.25;
P.bDebug = 0;
P.ylim = [-0.25 0.25];
P = parseargs(P, varargin{:});

ftemplate = ['ds_*_chan' int2str(P.chan) '.mat'];
files = dir([datadir filesep ftemplate]);
if isempty(P.use_file)
    P.use_file = {1:length(files)};
end

total_cols = length(P.use_file);
[total_rows col_longest] = max(cellfun(@length,P.use_file));
row_times = zeros(1,total_rows);
for row = 1:total_rows
    n_file = P.use_file{col_longest}(row);
    load([datadir filesep files(n_file).name])
    [t Y] = helper_extract_traces(rec,P);
    p = helper_which_subplot(row, col_longest, total_rows, total_cols);
    subplot(total_rows, total_cols, p)
    plot(t,Y,'k')
    ylim(P.ylim)
    row_times(row) = rec.Time;
end

for col = 1:total_cols
    if col == col_longest
        continue % we already plotted this one!
    end
    for n_file = P.use_file{col}(:)'
        load([datadir filesep files(n_file).name])
        [junk row] = min(abs(row_times - rec.Time));
        [t Y] = helper_extract_traces(rec,P);
        p = helper_which_subplot(row, col, total_rows, total_cols);
        subplot(total_rows, total_cols, p)
        plot(t,Y,'k')
        ylim(P.ylim)
    end
end

function [t Y] = helper_extract_traces(rec,P)
threshold = max(rec.Data) * P.threshold_frac;
index_stim = find(diff(rec.Data >= threshold) == 1)+1; % upward crossings
if P.bDebug
    figure(5001)
    plot(rec.Data)
    hold on
    scatter(index_stim,rec.Data(index_stim),200,'.k')
    hold off
    title('Threshold crossings')
end
total_trials = length(index_stim);
window_samples = round(P.window(1)/1000*rec.Fs):round(P.window(2)/1000*rec.Fs);
t = window_samples / rec.Fs;
Y = nan(length(window_samples),total_trials);
for trial = 1:total_trials
    index = index_stim(trial) + window_samples;
    if index(1) > 0 && index(end) < length(rec.Data)
        Y(:,trial) = rec.Data(index_stim(trial) + window_samples);
    end
end

function p = helper_which_subplot(row, col, total_rows, total_cols)
p = (row - 1) * total_cols + col;