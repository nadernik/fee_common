function testRulesBySyllable(rules, exper, varargin)
%% Parameters
P.File = [];
P.TargetSyllable = [];
P.TargetRange = [];
P = parseargs(P, varargin{:});

if isempty(P.File) % If File parameter not set, use all files
    P.File = 1:getLatestDatafileNumber(exper);
end
total_files = length(P.File);
%% Check to make sure at least one rule is set to play noise.
% If no rules are selected to play noise, this test will be useless. It
% will always return 0% hit for all syllables.
if ~any([rules.actionNoise])
    errordlg('Mark the "Play Noise" checkbox for at least one rule.', 'Cannot test on syllables', 'modal')
    return
end

%% load all annotations
wbh = waitbar(0);

rootdir = getExperRootdir(exper);
miscfiles  = getProcessedDataFiles(exper.birdname,'experNames',exper.expername, 'rootdir', rootdir);
pitchfiles = getProcessedDataFiles(exper.birdname,'experNames',exper.expername, 'rootdir', rootdir, 'dataType', 'pitch');

all_syll_noise = [];
all_syll_type = [];
all_pitch = [];
files_processed = 0;
for ii = 1:length(miscfiles)
    load([rootdir exper.birdname filesep miscfiles(ii).name])
    pitch_loaded = false;
    for jj = 1:total_files
        key = getExperAudioFilename(exper, P.File(jj));
        % get segs from this file
        idx_seg_file = cellfun(@strcmp, {misc.segs.key}, repmat({key}, size(misc.segs)));
        if any(idx_seg_file)
            files_processed = files_processed + 1;
        end
        idx_seg_file = idx_seg_file & [misc.segs.segType] ~= -1; % skip unclustered syllables
        total_syllables = sum(idx_seg_file);
        if total_syllables > 0 % if we have segs, load audio and apply rules
            % load audio
            audio_in = loadAudio(exper, P.File(jj));
            Fs_in = exper.desiredInSampRate;
            Fs_tdt = 24414; %Hz, TDT sampling rate
            audio = resample2(audio_in, Fs_tdt, Fs_in);
            audio = audio - mean(audio);
            % apply rules
            file_noise = testRulesOnFile(rules, audio);
            % map noise onto syllables
            t = (0:length(audio)-1) * 1/Fs_tdt;
            t = repmat({t}, total_syllables, 1);
            temp = [[misc.segs(idx_seg_file).fStartTime]' [misc.segs(idx_seg_file).fEndTime]'];
            t_range = mat2cell(temp, ones(1,size(temp,1)), 2);
            syll_noise = cellfun(@extract_time_range, repmat({file_noise}, total_syllables, 1), t, t_range, 'UniformOutput', false);
            all_syll_noise = [all_syll_noise; syll_noise];
            syll_type = [misc.segs(idx_seg_file).segType];
            all_syll_type = [all_syll_type syll_type];
            % load pitch
            if ~pitch_loaded
                load(fullfile(rootdir,exper.birdname,pitchfiles(ii).name))
                pitch_loaded = true;
            end
            all_pitch = [all_pitch {pitch.segs(idx_seg_file).pitch}];                
        end
        waitbar(files_processed / total_files)
    end %file
end %miscfile

L = cellfun(@length,all_syll_noise,'UniformOutput',false);
all_syll_noise = cellfun(@resample2, all_syll_noise, repmat({100},size(L)), L,'UniformOutput',false);
all_syll_noise = cell2mat(all_syll_noise');
close(wbh)
%% Plot results for each syllable type
for type = unique(all_syll_type)
    figure
    % SUBPLOT 1 -- Example spectrogram
    axh(1) = subplot(3,1,1);
    %displaySpecgramQuick(sampleaudio{type}, Fs)
    % SUBPLOT 2 -- 
    axh(2) = subplot(3,1,2);
    imagesc(all_syll_noise(:,all_syll_type == type)')
    %xlims = xlim(axh(1));
    %nz = all_syll_noise(all_syll_type == clust);
    %x = linspace(xlims(1),xlims(2),size(nz,1));
    %y = 1:size(nz,2);
    %imagesc(x,y,nz')
    % pitch traces
    axh(3) = subplot(3,1,3);
    has_noise = any(all_syll_noise);
    hold on
    idx = has_noise & all_syll_type == type;
    cellfun(@plot, all_pitch(idx), repmat({'r'},1,sum(idx)))
    hits = sum(idx);
    idx = ~has_noise & all_syll_type == type;
    cellfun(@plot, all_pitch(idx), repmat({'b'},1,sum(idx)))
    escapes = sum(idx);
    %linkaxes(axh,'x') %FIXME
    N = hits + escapes;
    title(sprintf('Cluster %g N = %g %.0f%% hit',type,N,hits/N * 100))
end

%% Histograms of pitch at target interval in hit vs. escape
is_target = ismember(all_syll_type, P.TargetSyllable);
is_hit = is_target &  has_noise;
is_esc = is_target & ~has_noise;
hit_pitch_trace = all_pitch(is_hit); % cell array
esc_pitch_trace = all_pitch(is_esc); % cell array
target_pitch_esc = nan(sum(is_esc), 1);
target_pitch_hit = nan(sum(is_hit), 1);
fs = 1;
for ii = 1:sum(is_hit)
    target_pitch_hit(ii) = mean(extract_time_range(hit_pitch_trace{ii}, fs, P.TargetRange));
end
for ii = 1:sum(is_esc)
    target_pitch_esc(ii) = mean(extract_time_range(esc_pitch_trace{ii}, fs, P.TargetRange));
end
binsize = 5; %Hz
p1 = floor(min([min(target_pitch_hit), min(target_pitch_esc)]) / binsize);
p2 = ceil( max([max(target_pitch_hit), max(target_pitch_esc)]) / binsize);
bins = (p1:p2) .* binsize;
y_hit = hist(target_pitch_hit, bins);
y_esc = hist(target_pitch_esc, bins);

figure
stairs(bins, y_esc, 'Color', [0 0 1], 'LineWidth', 4)
hold on
stairs(bins, y_hit, 'Color', [1 0 0], 'LineWidth', 4)
hold off