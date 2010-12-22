function varargout = plot_pitch_multiday(birdname, expername, varargin)
P.cluster_escapes = 1;
P.cluster_hits = NaN;
P.rootdir = 'c:\stetner\data';
P.pitch_lims = [30 40];
P.pitch_lim_units = 'samples'; % also supported: ms, samples
P = parseargs(P, varargin{:});
P.birdname = birdname;
P.expername = expername;

clusters = [];
times = [];
pitches = [];
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
    pitches = [pitches pitch_helper(pitch.segs(idx),P)];
    [miscfile, pitchfile] = next_filenames(P);
    clear misc pitch
end
fh = figure;
idx = clusters == P.cluster_escapes;
scatter(times(idx), pitches(idx), 'b')
hold on
idx = clusters == P.cluster_hits;
scatter(times(idx), pitches(idx), 'r')
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
switch P.pitch_lim_units
    case 'percent'
        error('not implemented yet')
    case 'ms'
        error('not implemented yet')
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