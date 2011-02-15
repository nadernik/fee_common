function real_time_visualization(exper, varargin)
handles.exper = exper;

%% parameters
P.last_n = 50; % how many syllables to show in pitch_distributions and pitch_traces plots
P.rootdir = 'c:\stetner\data';
P.baseline_exper = [];
P.polygons_file = 'polygonswithnoise.mat'; % looks for this in rootdir\birdname directory
% P.noise_amplitude_threshold = 90;%dB
P.debugging = true;
P.escape_cluster = 1;
P.hit_cluster = 2;
handles.P = parseargs(P, varargin{:});

%% persistent variables

% figure handles
figure(712)
handles.axes_traces = subplot(2,2,1);
handles.axes_hits_histogram = subplot(2,2,2);
handles.axes_distribution = subplot(2,2,3);
handles.axes_scatter = subplot(2,2,4);

% empty data structures for plots
handles.d.trace = struct('time', nan(P.last_n,1), 'val', nan(P.last_n,1));
handles.d.point = struct('time', nan(P.last_n,1), 'val', nan(P.last_n,1));
handles.d.baseline = struct('time', nan(P.last_n,1), 'val', nan(P.last_n,1));

% place holders
handles.last_filenum = 0;
handles.lastidx = 0;

%% load baseline
if ~isempty(handles.P.baseline_exper)
	% if we are given a baseline file, load the annotation
	handles.d.baseline = load_pitch_points(handles.P.baseline_exper, handles.P.last_n)
elseif exist(handles.anno_filename,'file')
	% if we aren't given a baseline file, try to load the annotation from the
	% current experiment
	handles.d = dload(handles.exper, handles.d)
end


%% load polygons
temp = load(P.polygons_file);
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
if ~escape_cluster_exists 
    error('Polygons file (%s) does not contain cluster for escapes (%g). You can change the cluster number by supplying the ''cluster_escape'' parameter.', handles.P.polygons_file, handles.P.escape_cluster)
end
if ~hit_cluster_exists 
    error('Polygons file (%s) does not contain cluster for hits (%g). You can change the cluster number by supplying the ''cluster_hit'' parameter.', handles.P.polygons_file, handles.P.hit_cluster)
end

function rtviz_timer_cb(handles)
	% check for new files
	max_filenum = getLatestDatafileNum(handles.exper);
	if max_filenum > last_filenum
		for filenum = (last_filenum + 1):max_filenum % for each new file
			handles.d = proccess_data_file(handles.exper, filenum, handles.d, handles.P{:});
		end
		plot_traces(handles)
		plot_scatter(handles)
		plot_distribution(handles)
		plot_hits_histogram(handles)
	end	
end

%%
function d = proccess_data_file(exper, filenum, d, varargin) %%%FIXME
	% segment syllables


	% annotation
	key = 
	element = 
	misc = 
	pitch = 

	% pitch
	pitch.segs(count).key = filenames{nAnnot};
	pitch.segs(count).absStart = annot.segAbsStartTimes(nSeg);
	[pi, pg, hp, pt, entropy] = estimatePitch(syllAudio, fs);
	pitch.segs(count).pitch = pi;
	pitch.segs(count).pitchGoodness = pg;
	pitch.segs(count).harmonicPower = hp;
	pitch.segs(count).pitchTime = pt; 
	pitch.segs(count).entropy = entropy;

	% misc
	misc.segs(count).key = filenames{nAnnot};
	misc.segs(count).absStart = annot.segAbsStartTimes(nSeg);
	misc.segs(count).duration = (endNdx - startNdx)/fs; %annot.segFileEndTimes(nSeg) - annot.segFileStartTimes(nSeg);
	misc.segs(count).fStartTime = (startNdx - 1)/fs;%annot.segFileStartTimes(nSeg);
	misc.segs(count).fEndTime = (endNdx-1)/fs;%annot.segFileEndTimes(nSeg);
	misc.segs(count).segType = annot.segType(nSeg);
	misc.segs(count).fs = fs;

	%BEGIN: Tatsuo's code for masking and stim.                                       
	%convert mask times to array of 0s and 1s
	syllable = zeros(annot.length,1); % array of 0s and 1s
	syllable(startNdx:endNdx) = 1;

	%mask info
	misc.segs(count).maskTime = [];
	if (isfield(annot, 'maskFileStartTimes'))
		bMask = zeros(annot.length,1); %(0: no mask, 1: mask)
		for n=1:length(annot.maskFileStartTimes)
			bMask(annot.maskFileStartTimes(n):annot.maskFileEndTimes(n)) = 1;
		end
		isMask = false; % default
		SyllMask = syllable & bMask;
		if sum(SyllMask)~=0
			isMask = true;
		end

		if isMask
			misc.segs(count).maskTime = ((find(SyllMask)-startNdx-1)/P.fs)'; % relative to syllables onset (s)                 
		end                            
	end
	%END: Tatsuo's code for masking and stim.

	% audio
	rawaudio.segs(count).key = filenames{nAnnot};
	rawaudio.segs(count).absStart = annot.segAbsStartTimes(nSeg);
	rawaudio.segs(count).audio = syllAudio


	d.pitch.segs = [d.pitch.segs pitch];

	;    

	% throw out overlapping syllables
	% for each syllable
	% is there noise?
	% if no noise, determine cluster
	% calculate features that we need

	% is it in the target cluster?
	% if noise or if in target cluster,
	% extract pitch trace
	% calculate mean pitch over TARGET INTERVAL
	% update persistent variables
	% update plots
end
%%
function plot_traces(handles) %%%FIXME
	cla(handles.axes_traces);
	hold(handles.axes_traces);
	t1 = min(handles.d.time);
	t2 = max(handles.d.time);
	for n = 1:handles.P.last_n
		% color by how recent they are. less recent are closer to white.
		if handles.P.color_traces_by_time
			cval = 0.5 - 0.5*(handles.d.time(n) - t1) / (t2 - t1);
		else
			cval = 0;
		end
		if handles.d.noised(n)
			rgb = [1 cval cval]; % red
		else
			rgb = [cval cval cval]; % gray
		end
		p = plot(handles.axes_traces, 1:length(handles.d.trace(n)), handles.d.trace(n));
		set(p,'Color',rgb)
	end
end
%%
function plot_scatter(handles) %%%FIXME
	cla(handles.axes_scatter)
	hold(handles.axes_scatter)
	% hits
	t = handles.d.time(handles.d.noised);
	mean_pitch = handles.d.points(handles.d.noised);
	scatter (t, mean_pitch)
	% escapes
	t = handles.d.time(~handles.d.noised);
	mean_pitch = handles.d.points(~handles.d.noised);
	scatter(t, mean_pitch)
end
%%
function plot_distribution(handles) %%%FIXME
	cla(handles.axes_distribution)
	hold(handles.axes_distribution)
	hist(
	handles.d.baseline_distribition
end
%%
function plot_hits_histogram(handles) %%%FIXME
	% find mask times (absolute)
	% find escape times (absolute)
	% ASSUMES: anything in the target cluster did not get hit
end

function baseline = load_pitch_points(exper, varargin)
P.last_n = 50;

% loads processed annotation files and initializes b