function calibration_plot(datadir,varargin)
% assumes data was taken with daqAcquire
% assumes threshold is positive
P.chan = 1;
P.window_pre = [-20 -5]; % milliseconds
P.window_post = [5 20]; % milliseconds
P.use_file = []; % used to take subset of files. can be list of indicies or binary vector of length filenames
P.time_zero = 0;% date serial number
P.threshold_frac = 0.25;
P.bDebug = 0;
P = parseargs(P,varargin{:});

ftemplate = ['ds_*_chan' int2str(P.chan) '.mat'];
files = dir([datadir filesep ftemplate]);
if ~isempty(P.use_file)
    files = files(P.use_file);
end
t = zeros(size(files));
y = zeros(size(files));
yerr = zeros(size(files));
for n_file = 1:length(files)
    load([datadir filesep files(n_file).name])
    threshold = max(rec.Data) * P.threshold_frac;
    index_stim = find(diff(rec.Data >= threshold) == 1)+1; % upward crossings 
    if P.bDebug
        figure(5001)
        plot(rec.Data)
        hold on
        scatter(index_stim,rec.Data(index_stim),200,'.k')
        hold off
        title(['Threshold crossings' files(n_file).name])
        pause
    end
    total_trials = length(index_stim);
    index_pre = round(P.window_pre(1)/1000*rec.Fs):round(P.window_pre(2)/1000*rec.Fs);
    index_post = round(P.window_post(1)/1000*rec.Fs):round(P.window_post(2)/1000*rec.Fs);
    response_pre = zeros(length(index_pre),total_trials);
    response_post = zeros(length(index_post),total_trials);
    for trial = 1:total_trials
        try
            response_pre(:,trial) = rec.Data(index_stim(trial) + index_pre);
            response_post(:,trial) = rec.Data(index_stim(trial) + index_post);
        catch 
            response_pre(:,trial) = nan;
            response_post(:,trial) = nan;
        end
    end
    residual_pre = response_pre - nanmean(response_pre,2)*ones(1,total_trials);
    residual_post = response_post - nanmean(response_post,2)*ones(1,total_trials);
    rms_pre = mean(abs(residual_pre));
    rms_post = mean(abs(residual_post));
    t(n_file) = rec.Time;
    rms_diff = rms_post - rms_pre;
    y(n_file) = mean(rms_diff);
    yerr(n_file) = std(rms_diff);
end

t = t - P.time_zero;
figure
errorbar(t,y,yerr)
ticks = get(gca,'XTick');
set(gca,'XTickLabel',datestr(ticks,'HH:MM'))
yl = ylim;
ylim([0 yl(2)])
xlabel('Time (HH:MM)')
ylabel('Stim Response')