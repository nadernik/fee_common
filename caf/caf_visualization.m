function caf_visualization(exper, varargin)
handles.exper = exper;

%% parameters
P.last_n = 50; % how many syllables to show in pitch_distributions and pitch_traces plots
P.rootdir = 'c:\stetner\data';
P.baseline_exper = [];
P.polygons_file = 'polygons.mat'; % looks for this in rootdir\birdname directory
% P.noise_amplitude_threshold = 90;%dB
P.debugging = true;
P.escape_cluster = 1;
P.hit_cluster = 2;
P.syllable_target_time = [];
P.max_syll_duration = 1; % seconds

% segmentation
P.method = 'fixed';
P.thresholdAbs = -14;
P.triggerAbs = -11;

% trace plot
P.color_traces_by_time = true;

P = parseargs(P, varargin{:});
handles.P = P;

%% persistent variables

% figure handles
figure(347)
handles.axes_traces = subplot(2,2,1);
handles.axes_hits_histogram = subplot(2,2,2);
handles.axes_distribution = subplot(2,2,3);
handles.axes_scatter = subplot(2,2,4);

% data for plots
handles.d.trace = struct('time', {}, 'val', {});
handles.d.point = struct('time', {}, 'val', {});
handles.d.noised = [];
handles.d.baseline_pitch = struct('time', {}, 'val', {});

% place holders
handles.last_filenum = 0;
handles.lastidx = 0;

%% initialization

% load polygons
temp = load([handles.P.rootdir filesep exper.birdname filesep handles.P.polygons_file]);
handles.clusters = temp.c;

% check to make sure that clusters for escapes and hits exist
escape_cluster_exists = false;
hit_cluster_exists = false;
for n = 1:length(handles.clusters)
    if handles.P.escape_cluster == handles.clusters(n).number
        escape_cluster_exists = true;
    end
    if handles.P.hit_cluster == handles.clusters(n).number
        hit_cluster_exists = true;
    end
end
%%%DEBUG
% if ~escape_cluster_exists
%     error('Polygons file (%s) does not contain cluster for escapes (%g). You can change the cluster number by supplying the ''cluster_escape'' parameter.', handles.P.polygons_file, handles.P.escape_cluster)
% end
% if ~hit_cluster_exists 
%     error('Polygons file (%s) does not contain cluster for hits (%g). You can change the cluster number by supplying the ''cluster_hit'' parameter.', handles.P.polygons_file, handles.P.hit_cluster)
% end

% load baseline
if isempty(handles.P.baseline_exper)
   handles.P.baseline_exper = handles.exper;
end
filenum = getLatestDatafileNumber(handles.P.baseline_exper);
syllables_to_go = P.last_n;
while syllables_to_go > 0 && filenum > 0
    [trace point noised] = proccess_data_file(handles.P.baseline_exper, filenum, handles.clusters, handles.P);
    new_syllables = length(point);
    offset = max(1, new_syllables - syllables_to_go + 1);
    % add to structures, from end
    ndx = (offset-new_syllables:0) + syllables_to_go;
    handles.d.trace(ndx) = trace(offset:end);
    handles.d.point(ndx) = point(offset:end);
    handles.d.noised(ndx) = noised(offset:end);
    syllables_to_go = syllables_to_go - new_syllables + offset - 1;
    filenum = filenum-1;
end
handles.d.baseline_pitch = handles.d.point;

plot_traces(handles);
plot_scatter(handles);
plot_distribution(handles);
plot_hits_histogram(handles);

% finally, start the timer to check for new data files periodically
%FIXME
% keyboard %%%DEBUG
end

%% main flow
function handles = caf_visualization_timer_cb(handles)
% check for new files
max_filenum = getLatestDatafileNumber(exper);
if max_filenum > last_filenum
    for filenum = (last_filenum + 1):max_filenum % for each new file
        handles.d = proccess_data_file(exper, filenum, handles.clusters, P, d); %%%FIXME
        % update persistent variables
        idx = mod(d.lastidx + 0:total_sylls-1, P.last_n) + 1;
        d.point
        d.trace(idx) = trace;
        d.lastidx = idx(end);
    end
    plot_traces(handles);
    plot_scatter(handles);
    plot_distribution(handles);
    plot_hits_histogram(handles);
end
end


%%
function [trace, point, noised] = proccess_data_file(exper, filenum, c, P, d)
[audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper, filenum);
audio = audio - mean(audio);
t = (0:length(audio)-1) * 1/info.fs;
% segment syllables
[syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, thresEdge,thresSyll, soundStd] = aSAP_segSyllablesFromRawAudio(audio, info.fs, ...
                                    'method', P.method, ...                                  
                                    'thresholdAbs', P.thresholdAbs, ...
                                    'triggerAbs', P.triggerAbs);
% for each syllable
total_sylls = length(syllStartTimes);
trace = struct('time', {}, 'val', {});
point = struct('time', {}, 'val', {});
noised = [];
for syll = 1:total_sylls
    idx = t >= syllStartTimes(syll) & t < syllEndTimes(syll); 
    syll_audio = audio(idx);
    % determine cluster
    [cluster, features] = cluster_from_audio(syll_audio, info.fs, c);
    if cluster ~= P.escape_cluster && cluster ~= P.hit_cluster
        % skip further analysis if this is not a hit or escape
        continue
    end
    [noise_start_time, noise_end_time] = find_noise_in_audio(syll_audio, info.fs);
    if isempty(noise_start_time)
        noised(end+1) = false;
    else
        noised(end+1) = true;
    end
        
%     if isempty(noise_start_time)
        % if no noise, take whole pitch trace and pitch point based on time
        % from syllable onset
        trace(end+1).time = features.pitchTime;
        trace(end).val = features.pitch;
        point(end+1).time = startTime + syllStartTimes(syll)/60/60/24; % absolute time, in days
        point(end).val = mean(excerpt_time_range(features.pitch, features.pitchTime, P.syllable_target_time));
        
%     else
%         % if noise, take pitch trace up until noise and pitch point based
%         % on 5 ms just before noise
%         trace(end+1).time = features.pitchTime(features.pitchTime < noise_start_time);
%         trace(end).val = excerpt_time_range(features.pitch, features.pitchTime, [0 noise_start_time],size(trace,1));
%         point(end+1).time = startTime + syllStartTimes(syll)/60/60/24; % absolute time, in days
%         point(end).val = mean(excerpt_time_range(features.pitch, features.pitchTime, [-0.005 0], noise_start_time));
%         noised(end+1) = true;
%     end
end
end
%%
function plot_traces(handles)
axes(handles.axes_traces)
cla
hold on
t = [handles.d.point.time];
for n = 1:handles.P.last_n
	% color by how recent they are. less recent are closer to white.
	if handles.P.color_traces_by_time
		cval = 0.5 - 0.5*(handles.d.point(n).time - min(t)) / (max(t) - min(t));
	else
		cval = 0;
	end
	if handles.d.noised(n)
		rgb = [1 cval cval]; % red
	else
		rgb = [cval cval cval]; % gray
	end
	plot(handles.d.trace(n).time, handles.d.trace(n).val, 'Color', rgb);
end
end
%%
function plot_scatter(handles)
axes(handles.axes_scatter)
cla
hold on
% hits
t = [handles.d.point(boolean(handles.d.noised)).time];
mean_pitch = [handles.d.point(boolean(handles.d.noised)).val];
scatter (t, mean_pitch,'xr')
% escapes
t = [handles.d.point(~boolean(handles.d.noised)).time];
mean_pitch = [handles.d.point(~boolean(handles.d.noised)).val];
scatter(t, mean_pitch,'.k')
end
%%
function plot_distribution(handles)
axes(handles.axes_distribution)
cla
hold on
hist([handles.d.point.val])
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r')
hist([handles.d.baseline_pitch.val])
h = findobj(gca,'Type','patch');
set(h,'FaceAlpha',0.5)
end
%%
function plot_hits_histogram(handles)
axes(handles.axes_hits_histogram)
cla
hold on
%%%FIXME
end