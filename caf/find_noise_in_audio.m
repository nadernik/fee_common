function [start_times, end_times] = find_noise_in_audio(audio, fs, varargin)

P.dec_factor = 20; % integer >= 1
P.bDebug = false;
P.min_duration = 10e-3; %seconds
P.threshold = 0.05;
P = parseargs(P, varargin{:});

% load audio
audio = audio - mean(audio);
t = (0:length(audio)-1) ./ fs;

% decimate
nadd = P.dec_factor * ceil(length(audio)/P.dec_factor) - length(audio);
if nadd > 0
    audio(end+1:end+nadd) = nan;
    t(end+1:end+nadd) = nan;
end
binned = reshape(audio.^2,P.dec_factor,[]);
t_binned = reshape(t,P.dec_factor,[]);
audio_decimated = mean(binned);
t_decimated = mean(t_binned);

% find noise (threshold crossings)
above_threshold = audio_decimated >= P.threshold;
start_times = t_decimated(diff(above_threshold) == 1); % 0->1 transitions
end_times = t_decimated(diff(above_threshold) == -1); % 1->0 transitions

if isempty(start_times)
    return
end

% eliminate short noise segments
durations = end_times - start_times;
too_short = durations < P.min_duration;
start_times = start_times(~too_short);
end_times = end_times(~too_short);

if isempty(start_times)
    return
end

% eliminate short gaps
gaps = start_times(2:end) - end_times(1:end-1);
too_short = gaps < P.min_duration;
start_times = start_times([true ~too_short]);
end_times = end_times([~too_short true]);

% plot for debugging
if P.bDebug
    figure(9156)
    ax(1) = subplot(2,1,1);
    displaySpecgramQuick(audio, fs)
    ax(2) = subplot(2,1,2);
    cla
    hold on
    plot(t_decimated, audio_decimated,'-b')
    line(xlim,P.threshold * ones(1,2),'Color','r','LineStyle',':')
    for i = 1:length(start_times)
        line([start_times(i) end_times(i)], [0 0], 'Color', 'r', 'LineWidth', 5)
    end
    linkaxes(ax,'x')
end