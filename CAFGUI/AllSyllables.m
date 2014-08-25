function AllSyllables(handles)
%Takes an annotation and computes various statistics on all of its
%segments.

anno_params = {'experNames', handles.experName, 'rootdir', handles.rootdir, 'targetSyll', handles.targetSyll};
pitch_fs = 1000;%Hz

debugdisp('Getting audio...')
if isfield(handles, 'audio')
    debugdisp('Audio was already loaded!')
else
    audio = getProcessedAudio(handles.birdName, anno_params{:});
    handles.audio = audio;
    guidata(handles.figure1, handles)
    debugdisp('Audio loaded from file!')
end

debugdisp('Getting pitch...')
if isfield(handles, 'pitchTrajs')
    debugdisp('Pitch trajectories were already loaded!')
else
    pitch = getProcessedPitchTrajectories(handles.birdName, anno_params{:});
    handles.pitchTrajs = pitch;
    guidata(handles.figure1, handles)
    debugdisp('Pitch trajectories loaded from file!')
end

assert(length(handles.audio) == length(handles.pitchTrajs), 'Different number of audio and pitch trajectories.')
% Check to make sure that length of audio is within 10 percent of the length
% of the corresponding pitch trajectory
len_audio = cellfun(@length, handles.audio);
len_pitch = cellfun(@length, handles.pitchTrajs);
ratio = len_audio ./ len_pitch;
ratio_ideal = handles.fs / pitch_fs;
pct_diff = (ratio - ratio_ideal) ./ ratio_ideal;
assert(all(pct_diff < .1), 'Length of one or more audio segments does not match length of corresponding pitch trajectory.')

debugdisp('Evaluating rule...')
for ii = 1:handles.lastN
    jj = length(handles.audio) - ii + 1;
    if jj == 0
        warning('Could not evaluate last %g syllables because there are only %g target syllables in the dataset.', handles.lastN, length(handles.audio))
        break
    end
    tdt_audio = resample2(handles.audio{jj}, handles.tdt_fs, handles.fs);
    hit = feval(handles.params.filterFunc, tdt_audio, handles.params);
    target_hit_frac(ii) = mean(extract_time_range(hit,                    handles.tdt_fs, handles.targetRegion/10));
    target_pitch(ii)    = mean(extract_time_range(handles.pitchTrajs{jj}, pitch_fs,       handles.targetRegion/10));
    waitbar(ii/handles.lastN)
end
delete(waitbar(1))
figure
% subplot(2,1,1)
% scatter(target_pitch, target_hit_frac)
% xlim([min(target_pitch) max(target_pitch)])
% ylim([0 1])
% 
% ylabel('Fraction of target region hit')
% 
% subplot(2,1,2)
f_hit = 0.9;
f_esc = 0.1;
color_hit     = [1   0   0  ];
color_esc     = [0   0   1  ];
color_neither = [0.5 0.5 0.5];
bins = min(target_pitch):5:max(target_pitch);
is_hit = target_hit_frac >= f_hit;
is_esc = target_hit_frac <= f_esc;
is_neither = ~is_hit & ~is_esc;
y_hit = histc(target_pitch(is_hit), bins);
y_esc = histc(target_pitch(is_esc), bins);
y_neither = histc(target_pitch(is_neither), bins);
h = bar(bins, horzcat(y_hit', y_neither', y_esc'), 1, 'stacked');
set(h(1), 'FaceColor', color_hit, 'EdgeColor', color_hit)
set(h(2), 'FaceColor', color_neither, 'EdgeColor', color_neither)
set(h(3), 'FaceColor', color_esc, 'EdgeColor', color_esc)
xlim([min(target_pitch) max(target_pitch)])
xlabel('Mean pitch in target region (Hz)')
ylabel('Number of syllables')
str_hit = sprintf('%2.0f%% Hit',     mean(is_hit)     * 100);
str_esc = sprintf('%2.0f%% Escape',  mean(is_esc)     * 100);
str_non = sprintf('%2.0f%% Neither', mean(is_neither) * 100);
title(texcolor(str_hit, color_hit, str_esc, color_esc, str_non, color_neither), 'Interpreter', 'tex')