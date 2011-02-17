function varargout = plot_pitch_multiday(birdname, expername, varargin)
P.cluster_escapes = 1;
P.cluster_hits = NaN;
P.rootdir = 'c:\stetner\data';
P.pitch_lims = [30 40];
P.pitch_lim_units = 'samples'; % also supported: seconds, samples
P.window_hours = 1;
P.n_distribution = 100;
P = parseargs(P, varargin{:});
P.birdname = birdname;
P.expername = expername;
if ~iscell(P.expername)
    P.expername = {P.expername};
end
figure;
subplot(2,2,1)
hold on
clusters = [];
times = [];
pitches = [];
pitchTimes = [];
[miscfile, pitchfile] = next_filenames(P);
while ~isempty(miscfile)
    % load annotation file
    load(miscfile)
    load(pitchfile)
    % cluster
    temp = [misc.segs(:).segType];
%     is_escape = [ == P.cluster_escapes];
%     is_hit = [misc.segs(:).segType == P.cluster_hits];
%     idx = is_escape | is_hit;
    idx = temp == P.cluster_escapes | temp == P.cluster_hits;
    clusters = [clusters misc.segs(idx).segType];
    % times
    times = [times misc.segs(idx).absStart];
    % pitch
    pitchTimes = [pitchTimes {pitch.segs(idx).pitchTime}];
    pitches = [pitches pitch_helper(pitch.segs(idx),P)];
    [miscfile, pitchfile] = next_filenames(P);
    % plot traces
    idx = temp == P.cluster_escapes;
    if sum(idx) > 0
        cellfun(@plot,{pitch.segs(idx).pitchTime},{pitch.segs(idx).pitch},repmat({'b'},1,sum(idx)))
    end
    idx = temp == P.cluster_hits;
    if sum(idx) > 0
        cellfun(@plot,{pitch.segs(idx).pitchTime},{pitch.segs(idx).pitch},repmat({'r'},1,sum(idx)))
    end
    clear misc pitch
end


% average pitch scatter
subplot(2,2,2)
idx = clusters == P.cluster_escapes;
scatter(times(idx), pitches(idx), 'b')
hold on
idx = clusters == P.cluster_hits;
scatter(times(idx), pitches(idx), 'r')


% percent hits by hour
idx = clusters == P.cluster_hits;
times_hits = times(idx);
idx = clusters == P.cluster_escapes;
times_escapes = times(idx);
earliest = min([min(times_hits) min(times_escapes)]);
latest = max([max(times_hits) max(times_escapes)]);
edges = earliest:P.window_hours/24:latest;
centers = edges*24 + P.window_hours/2;
count_hits = histc(times_hits,[edges]);
count_escapes = histc(times_escapes,[edges]);
percent_noised = count_hits ./ (count_hits + count_escapes);
subplot(2,2,4)
plot(centers, percent_noised)

% pitch distributions
idx = clusters == P.cluster_escapes | clusters == P.cluster_hits;
pitches = pitches(idx);
times = times(idx);
[times, idx] = sort(times);
pitches = pitches(idx); % put pitches in order to match times
if length(pitches) < 2*P.n_distribution
    warning('pitch distributions overlap in time')
end
subplot(2,2,3)
hold on
% plot distribution of last n syllables
x = 500:5:900;
hist(pitches(end-P.n_distribution:end),x)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r')
% plot distribution of first n syllables
hist(pitches(1:P.n_distribution),x)
% make histograms transparent
h = findobj(gca,'Type','patch');
set(h,'FaceAlpha',0.5)
% give some statistics on whether bird has learned
sprintf('Starting pitch: %g +/- %g\nEnding pitch: %g +/- %g\n', ...
    median(pitches(1:P.n_distribution)), ...
    std(pitches(1:P.n_distribution)), ...
    median(pitches(end-P.n_distribution:end)), ...
    std(pitches(end-P.n_distribution:end)))
ttest2(pitches(1:P.n_distribution), pitches(end-P.n_distribution:end))


end

function [miscfile, pitchfile] = next_filenames(P)
persistent n
if isempty(n)
    n.exper = 1;
    n.suffix = 1;
    suffixstr = '';
else
    n.suffix = n.suffix + 1;
    suffixstr = sprintf('-pt%03.f', n.suffix);
end
miscfile = [P.rootdir filesep P.birdname filesep P.birdname '_all_misc_' P.expername{n.exper} suffixstr '.mat'];
pitchfile = [P.rootdir filesep P.birdname filesep P.birdname '_all_pitch_' P.expername{n.exper} suffixstr '.mat'];
% assumes that if misc file exists, then pitch file exists too
% assumes every exper has at least one misc file
if ~exist(miscfile,'file')
    if n.exper < length(P.expername) % if there are more expers
        n.exper = n.exper + 1; % next exper
        n.suffix = 1; % first part
        suffixstr = '';
        miscfile = [P.rootdir filesep P.birdname filesep P.birdname '_all_misc_' P.expername{n.exper} suffixstr '.mat'];
        pitchfile = [P.rootdir filesep P.birdname filesep P.birdname '_all_pitch_' P.expername{n.exper} suffixstr '.mat'];
    else % no more expers, so no more files
        n = [];
        miscfile = '';
        pitchfile = '';
    end
end
end

function pitches = pitch_helper(segs,P)
if isempty(segs)
    pitches = [];
    return
end
switch P.pitch_lim_units
    case 'percent'
        pitches = cell(1,length(segs));
        for k = 1:length(segs) % slow :(
            lim_idx = round(P.pitch_lims ./ 100 .* length(segs(k).pitch));
            lim_idx(1) = lim_idx(1) + 1; % prevent 0 index
            pitches{k} = segs(k).pitch(lim_idx(1):lim_idx(2));
        end
        pitches = cellfun(@mean,pitches);
    case 'seconds'
        pitch_lim = repmat({P.pitch_lims},size(segs));
        pitches = cellfun(@extract_time_range, {segs.pitch}, {segs.pitchTime}, pitch_lim, 'UniformOutput', false);
        pitches = cellfun(@mean,pitches);
    case 'samples'
        pitches = nan(diff(P.pitch_lims)+1,length(segs));
        for k = 1:length(segs) % slow :(
            pitches(:,k) = segs(k).pitch(P.pitch_lims(1):P.pitch_lims(2));
        end
        pitches = mean(pitches);
    otherwise
        error('unrecognized pitch_lim_units')
end
end