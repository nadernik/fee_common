function Bout_detect_TO(varargin)

%%% originally written by Lena Veit
%%% Tatsuo Okubo
%%% 2010/09/16
%%% sound channel: audio
%%% data channel: both pressure and neural

persistent params;
if isempty(params)
    params = inputParser();
    addOptional(params, 'pathName', '', @ischar);
    addOptional(params, 'soundchan', []);
    addOptional(params, 'datachan', []);
    addParameter(params, 'filter_order', 200);
    addParameter(params, 'filter_band', [1000, 4000]);
    addParameter(params, 'amplitude_smoothing_window', 0.0025);
end
params.parse(varargin{:});

if isempty(params.Results.pathName)
    pathName = uigetdir(pwd(), 'Choose the directory that contains songs');
else
    pathName = params.Results.pathName;
end

[soundchan, datachan] = defafault_channel_dialog(params.Resuts.soundchan, params.Results.datachan);

filter_order = params.Results.filter_order;
filter_band = params.Results.filter_band;
amplitude_smoothing_window = params.Results.amplitude_smoothing_window;

cd(pathName)

if exist(fullfile(pathName, 'analysis.mat'), 'file') == 2 % analysis.mat already exists
    error('analysis.mat already exists');
end

boutpath = fullfile(pathName, 'bouts');
if exist(boutpath, 'dir') == 0 % no bouts folder
    mkdir(boutpath); % make bouts folder
end

s_files = dir(fullfile(pathName, sprintf('*chan%d.dat', soundchan))); % list of sound files
n_song = numel(s_files);

dbase = empty_dbase();
dbase = init_dbase(dbase, pathName, loader_str, datachan, n_song, s_files);

fig = bout_figure(pathName, n_song);
drawnow;
starttime = now;

temp.files = [];
temp.bouts = zeros(0,2);
temp.syll = {};
temp.titl = {};
temp.sel = {};
temp.time = [];
temp.len = [];
temp.ev = {};

firstRun = true;
last_fs = 0;
for file_no = dbase.AnalysisState.CurrentFile+1:n_song
    dbase.AnalysisState.CurrentFile = file_no;

    try
        [a, fs, dateandtime, ~, ~] = ...
            egl_AA_daq(fullfile(pathName, s_files(file_no).name), 1); % load sound file
    catch
        disp('fail');
        a = [];
    end
    if ~isempty(datachan) && ~isempty(a)
        try
            for i=1:length(datachan)
                dchan = datachan(i);
                [chdata{dchan}, fs, dateandtime, ~, ~] = ...
                    egl_AA_daq(fullfile(pathName, d_files{dchan}(file_no).name), 1); % load data channels
            end
        catch
            disp('fail');
            a = [];
        end
    end

    if ~isempty(a) % sound successfully loaded
        dbase.Times(file_no) = dateandtime; % file start time
        dbase.FileLength(file_no) = length(a); % file length
        % Segment

        if firstRun
            b = fir1(filter_order, 2 * filter_band / fs);
            smooth_len = round(amplitude_smoothing_window * fs);
            amp = calculate_amplitude(a, b, smooth_len);
            last_fs = fs;
            [noiseEst, soundEst, noiseStd, soundStd] = init_two_means(amp);
            firstRun = false;
        else
            if abs(fs - last_fs) > 0.0001
                error("fs %f is not the same as last_fs %f", fs, last_fs)
            end
            amp = calculate_amplitude(a, b, smooth_len);
        end
        [noiseEst, soundEst, noiseStd, soundStd] = eg_estimateTwoMeans(amp, noiseEst, soundEst, noiseStd, soundStd);
        th = eg_AutoThreshold(amp, noiseEst, soundEst, noiseStd, soundStd);

        segs = DA_segmenter(amp,fs,th, 0.007, 0.007); % segment
        sel = select_bouts(fs, amp, th, segs);
        dbase.SegmentThresholds(file_no) = th;
        dbase.SegmentTimes{file_no} = segs;
        dbase.SegmentTitles{file_no} = cell(1,size(segs,1));
        dbase.SegmentIsSelected{file_no} = sel;

        syll = segs(sel==1,:); % find only selected segment by bout selection
        if ~isempty(syll)
            % interval that has silence of more than 500 ms
            intr = find(syll(2:end, 1) - syll(1:end - 1, 2) > 0.5 * fs);
            ons = [1; intr+1]; % syll # of bout onsets
            offs = [intr; size(syll,1)]; % syll # of bout offsets1
            for bout_no = 1:length(ons) % for all bouts
                temp.files(end+1) = file_no; % file number
                temp.bouts(end+1,:) = [...
                    max(1,round(syll(ons(bout_no),1)-.7*fs)), ...
                    min(length(a),round(syll(offs(bout_no),2)+.7*fs)) ...
                    ];
                % include +/- 700 ms from bout onsets and offsets
                f = find(segs(:,1)>temp.bouts(end,1) & segs(:,2)<temp.bouts(end,2)); % find all segments within bouts
                temp.syll{end+1} = segs(f,:)-temp.bouts(end,1); % with respect to bout file onset
                temp.titl{end+1} = cell(1,size(f,1));
                temp.sel{end+1} = sel(f);

                % rec is the structure that will be saved under the
                % audio file
                rec.Fs = fs;
                rec.Data = a(temp.bouts(end,1):temp.bouts(end,2)); % extract a bout from audio signal
                rec.Time = dateandtime + temp.bouts(end,1)/fs/(24*60*60); % modify time (MATLAB time)

                % temp is the structure that will be saved under
                % analysis_incomplete
                temp.time(end+1) = rec.Time;
                temp.len(end+1) = length(rec.Data);

                temp.ev{end+1} = zeros(0,2);

                rec.Properties.Names = {};
                rec.Properties.Types = [];
                rec.Properties.Values = {};

                if ~isempty(datachan)
                    for i=1:length(datachan)
                        dchan = datachan(i);
                        ch_temp{dchan}.Fs = fs;
                        ch_temp{dchan}.Data = chdata{dchan}(temp.bouts(end,1):temp.bouts(end,2));
                        ch_temp{dchan}.Time = dateandtime + temp.bouts(end,1)/fs/(24*60*60);
                        ch_temp{dchan}.Properties.Names = {};
                        ch_temp{dchan}.Properties.Types = [];
                        ch_temp{dchan}.Properties.Values = {};
                    end
                end

                %% save the structures
                iss = 0;
                while iss==0
                    try
                        bout_soundpath = fullfile(boutpath, sprintf('sound_%04d_%03d.mat', file_no, bout_no));
                        save(bout_soundpath,'rec');

                        if ~isempty(datachan)
                            for i=1:length(datachan)
                                dchan = datachan(i);
                                ch = ch_temp{dchan};
                                bout_dat_path = fullfile(boutpath, sprintf('ch%d_%04d_%03d.mat', dchan, file_no, bout_no));
                                save(bout_dat_path,'ch');
                            end
                        end
                        iss = 1;
                    catch
                        disp('fail');
                        pause(1);
                    end
                end

                %% update figure
                figure(fig);
                subplot('position',[.05 0.05 0.9 0.3]);
                ylim([1000 7000]);
                [p, f, t] = quick_spectrogram(gca,rec.Data,rec.Fs);
                imagesc(t,f,p);
                set(gca,'ydir','normal');
                axis tight
                axis off
                set(gca,'clim',[prctile(p(:),50) prctile(p(:),95)*1.2]);
                drawnow
            end % for all bouts within a file
        end

        set(filesanalyzed,'string',['Files analyzed: ' num2str(file_no) ' of ' num2str(n_song)]);
        set(progbar,'cdata',[ones(1,file_no) zeros(1,n_song-file_no)]);
        set(timeelapsed,'string',['Time elapsed: ' num2str((now-starttime)*(24*60*60)) ' sec']);
        set(boutssaved,'string',['Bouts saved: ' num2str(length(temp.files))]);
        drawnow
    end
end % for all the files

dbase.AnalysisState.CurrentFile = 1;
iss = 0;
while iss==0
    try
        save(fullfile(pathName, 'analysis_original.mat'),'dbase');
        iss = 1;
    catch
        disp('fail');
        pause(1);
    end
end


%% Modify dbase to bout base structure
dbase.PathName = boutpath;
dbase.Times = temp.time;
dbase.FileLength = temp.len;
dbase.SoundFiles = dir(fullfile(boutpath, 'sound*.mat'));
dbase.OldSoundLoader = dbase.SoundLoader;
dbase.OldSoundFiles = s_files;
dbase.SoundLoader = 'Surgery_Rig_daq';
dbase.OldChannelFiles = dbase.ChannelFiles;
dbase.ChannelFiles = {};
dbase.OldChannelLoader = dbase.ChannelLoader;
dbase.ChannelLoader = {};
if ~isempty(datachan)
    for i=1:length(datachan)
        dchan = datachan(i);
        glob_path = fullfile(boutpath, sprintf('ch%d*.mat', dchan));
        dbase.ChannelFiles{dchan} = dir(glob_path);
        dbase.ChannelLoader{dchan} = 'Surgery_Rig_daq_ch';
    end
end

dbase.Fs = fs;
dbase.SegmentThresholds = thres(temp.files);
dbase.SegmentTimes = temp.syll;
dbase.SegmentTitles = temp.titl;

for jj = 1:length(temp.sel)
    temp.sel{jj}(1:end) = 1;
end
dbase.SegmentIsSelected = temp.sel;

dbase.EventSources = {};
dbase.EventFunctions = {};
dbase.EventDetectors = {};
dbase.EventThresholds = zeros(0,length(dbase.FileLength)); %% TO
dbase.EventTimes = {};
dbase.EventIsSelected = {};

for file_no = 1:length(temp.files)
    dbase.Properties.Names{file_no} = {};
    dbase.Properties.Values{file_no} = {};
    dbase.Properties.Types{file_no} = {};
end

dbase.AnalysisState.SourceList = {'(None)','Sound'};
if ~isempty(datachan)
    for i=1:length(datachan)
        dchan = datachan(i);
        dbase.AnalysisState.SourceList{end+1} = ['Channel ',num2str(dchan)];
    end
    dbase.AnalysisState.EventLims = repmat([0.001 0.003],length(dchan),1);
end
dbase.AnalysisState.EventList = {'(None)'};
dbase.AnalysisState.CurrentFile = 1;
dbase.AnalysisState.EventWhichPlot = 0;
iss = 0;
while iss==0
    try
        save(fullfile(boutpath, 'analysis_bout.mat'),'dbase');
        iss = 1;
    catch
        disp('fail');
        pause(1);
    end
end
end


%% Select bouts
function selected = select_bouts(fs, ampl, ~, segs) % segs is in indices

seg_times = segs/fs*1000; % in milliseconds
selected = zeros(1,size(seg_times,1));
if size(seg_times,1)<2
    return
end

durations = seg_times(:,2)-seg_times(:,1);
wind = round(0.0025 * fs);

%% Find segments with low amplitude variation
med_deriv = median(abs(diff(ampl(1:wind:end)))); % median derivative
gd = selected;
loudness = selected;
for c = 1:size(seg_times,1)
    seg_amp = ampl(segs(c,1):segs(c,2));
    loudness(c) = median(seg_amp);
    seg_deriv = diff(seg_amp(1:wind:end));
    seg_deriv = abs(seg_deriv)/med_deriv;
    if mean(seg_deriv) / durations(c) < 0.075 % What a weird measure?
        gd(c) = 1;
    end
end

%% Eliminate exceptionally loud segments
f = find(diff(diff(loudness)) < -40) + 1; %times where the second derivative is less than -40
gd(f) = 0;

%% Select segments with reasonably short pauses between them
pause = zeros(size(seg_times, 1), 1);
f = find(gd==1);
seg_gaps = seg_times(f(2:end),1)-seg_times(f(1:end-1),2);

if ~isempty(seg_gaps)
    pause(f) = min([[seg_gaps(1); seg_gaps], [seg_gaps; seg_gaps(end)]],[],2); % take minimum pause for two consecutive gaps

    f = find(durations./(pause+eps) > .20 & gd.'==1); % selected syllables with comparitively short flanking gaps

    if ~isempty(f)
        intr = find(seg_times(f(2:end),1) - seg_times(f(1:end-1), 2) > 500); % long gaps (more than 500)
        ons = [1; intr+1]; % bout onsets
        offs = [intr; length(f)]; % bout offsets
    else
        ons = [];
        offs = [];
    end

    for c = 1:length(ons)
        numsyll = offs(c)-ons(c)+1;
        boutlength = seg_times(f(offs(c)), 2) - seg_times(f(ons(c)), 1);
        sylldur = sum(seg_times(f(ons(c):offs(c)),2)-seg_times(f(ons(c):offs(c)),1));
        if numsyll > 2 && boutlength > 300 && sylldur / boutlength > 0.3 ...
                && prctile(ampl(round(segs(f(ons(c)), 1)):round(segs(f(offs(c)), 2))), 90) > 15
            selected(f(ons(c)):f(offs(c))) = 1;
        end
    end

    selected(gd==0) = 0;
end
end

function amp = calculate_amplitude(s, b, smooth_len)
snd = filtfilt(b, 1, s); % low pass fileter from 1-4 kHz
amp = smooth(10*log10(snd.^2+eps), smooth_len); % convert it to dB
amp = amp - prctile(amp(smooth_len:length(amp) - smooth_len), 5);
amp(amp<0) = 0;
end

%%
function threshold = eg_AutoThreshold(amp, noiseEst, soundEst, noiseStd, soundStd)
if range(amp)==0
    threshold = inf;
    return;
end

try
    % Code from Aaron Andalman
    if(noiseEst>soundEst)
        disc = max(amp)+eps;
    else
        %Compute the optimal classifier between the two gaussians...
        p(1) = 1/(2*soundStd^2+eps) - 1/(2*noiseStd^2);
        p(2) = (noiseEst)/(noiseStd^2) - (soundEst)/(soundStd^2+eps);
        p(3) = (soundEst^2)/(2*soundStd^2+eps) - (noiseEst^2)/(2*noiseStd^2) + log(soundStd/noiseStd+eps);
        disc = roots(p);
        disc = disc(disc>noiseEst & disc<soundEst);
        if isempty(disc)
            disc = max(amp)+eps;
        else
            disc = disc(1);
            disc = soundEst - 0.5 * (soundEst - disc);
        end
    end
    threshold = disc;

    if ~isreal(threshold)
        threshold = max(amp)*1.1;
    end
catch
    threshold = max(amp)*1.1;
end

end

function [uNoise, uSound, sdNoise, sdSound] = init_two_means(audioLogPow)
%set initial conditions
m = sort(audioLogPow);
nAud = numel(audioLogPow);
uNoise = median(m(fix(1:nAud/2)));
uSound = median(m(fix(nAud/2:nAud)));
sdNoise = 5;
sdSound = 20;
end
%%
% by Aaron Andalman
function [uNoise, uSound, sdNoise, sdSound] = eg_estimateTwoMeans(audioLogPow, uNoise, uSound, sdNoise, sdSound)

%Run EM algorithm on mixture of two gaussian model:

%compute estimated log likelihood given these initial conditions...
nAud = numel(audioLogPow);
prob = zeros(2, nAud);
prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
[estProb, class] = max(prob);
logEstLike = sum(log(estProb)) / nAud;
logOldEstLike = -Inf;

%maximize using Estimation Maximization
while(abs(logEstLike-logOldEstLike) > .005)
    logOldEstLike = logEstLike;

    %Which samples are noise and which are sound.
    nndx = find(class==1);
    sndx = find(class==2);

    %Maximize based on this classification.
    uNoise = mean(audioLogPow(nndx));
    sdNoise = std(audioLogPow(nndx));
    if ~isempty(sndx)
        uSound = mean(audioLogPow(sndx));
        sdSound = std(audioLogPow(sndx));
    else
        uSound = max(audioLogPow);
        sdSound = 0;
    end

    %Given new parameters, recompute log likelihood.
    prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2+eps)))./(sdNoise+eps);
    prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2+eps)))./(sdSound+eps)+eps;
    [estProb, class] = max(prob);
    logEstLike = sum(log(estProb+eps)) / nAud;
end

end

function [soundchan, datachan] = default_channel_dialog(soundchan, datachan)
    if isempty(soundchan)
        answer = inputdlg( ...
                             {'Sound channel','Data channels (array)'}, ...
                             'Channel selection', ...
                             1, ...
                             {'0','[]'} ...
                         );
        soundchan = str2double(answer{1});
        datachan = str2num(answer{2});
    end
end

function dbase = empty_dbase()
dbase = [];
dbase.PathName = '';

dbase.SoundLoader = '';
dbase.SoundFiles = s_files;

dbase.ChannelLoader = {};
dbase.ChannelFiles = {};

dbase.EventSources = {};
dbase.EventFunctions = {};
dbase.EventDetectors = {};
dbase.EventThresholds = [];
dbase.EventTimes = {};
dbase.EventIsSelected = {};

dbase.Properties.Names = {};
dbase.Properties.Values = {};
dbase.Properties.Types = {};

dbase.Fs = NaN;
dbase.AnalysisState.SourceList = {'(None)'};
dbase.AnalysisState.EventList = {'(None)',};
dbase.AnalysisState.CurrentFile = 0;
dbase.AnalysisState.EventWhichPlot = 0;
dbase.AnalysisState.EventLims = repmat([0.001 0.003],1,1); % -1ms to 3ms on the event viewer
dbase.FileLength = zeros(1,0);
dbase.Times = zeros(1,0);
end

function dbase = init_dbase(dbase, pathName, loader_str, datachan, n_song, s_files)
dbase.PathName = pathName;

dbase.SoundLoader = loader_str;

dbase.SoundFiles = s_files;
if ~isempty(datachan)
    for i=1:length(datachan) % for all the channels
        dchan = datachan(i); % channel number
        dbase.ChannelFiles{dchan} = dir(fullfile(pathName, sprintf('*chan%d.dat', dchan))); % list of neural files
        dbase.ChannelLoader{1,dchan} = loader_str;
    end
end

dbase.EventThresholds = zeros(0,n_song);

for file_no = 1:n_song
    dbase.Properties.Names{file_no} = {};
    dbase.Properties.Values{file_no} = {};
    dbase.Properties.Types{file_no} = {};
end

dbase.Fs = 40000;
dbase.AnalysisState.SourceList{end+1, 1} = {'Sound'}';
dbase.FileLength = zeros(1,n_song);
dbase.Times = zeros(1,n_song);
end

function fig = bout_figure(pathName, n_song)
%% figure
fig = figure(55);
clf
subplot('position',[.05 0.35 0.9 0.6]);
text(0,3,[pathName],'fontsize',14,'interpreter','none','horizontalalignment','center');
hold on
filesanalyzed = text(0,2,['Files analyzed: 0 of ' num2str(n_song)],'fontsize',14,'interpreter','none','horizontalalignment','center');
progbar = imagesc([-1 1],[.4 .6],zeros(1,n_song));
timeelapsed = text(0,-1,'Time elapsed: 0 sec','fontsize',14,'interpreter','none','horizontalalignment','center');
boutssaved = text(0,-2,'Bouts saved: 0','fontsize',14,'interpreter','none','horizontalalignment','center');
xlim([-1 1])
ylim([-3 3]);
axis off;
end
