function [maturity_index, axh] = compare_maturity_index(dbase_file_names, filenums)

%% These default parameters are from Aronov et al. 2008
P.Bouts = 10; % number of bouts to analyze
P.MaxInterval = 0.5; % seconds, maximum interval between syllables in a bout
P.MinDuration = 2; % seconds, minimum duration of a bout

%%

% If make sure
if iscell(dbase_file_names) && iscell(filenums)
    assert(length(dbase_file_names) == length(filenums))
elseif iscell(dbase_file_names)
    filenums{1:length(dbase_file_names)} = filenums;
else
    error('Unexpected arguments')
end

total_comparisons = P.Bouts * (P.Bouts - 1) / 2;

%%
for nbird = 1:length(dbase_file_names)
    load(dbase_file_names{nbird}, 'dbase')
    dbase = Select_syllable_within_bout(dbase, P.MaxInterval, P.MinDuration, filenums{nbird});
    
    % find all files that contain a bout
    files_with_bout = find(cellfun(@(x) ~isempty(x), dbase.BoutTimes, 'UniformOutput', true));
    
    % select random files that have bouts
    assert(length(files_with_bout) > P.Bouts)
    files = randsample(files_with_bout, P.Bouts);

    nc = 0;
    maturity_index{nbird} = zeros(1, total_comparisons);
    wbh = waitbar(0, sprintf('Bird %g', nbird));
    for i1 = 1:P.Bouts
        [full_audio1 fs dt label props] = eval(['egl_' dbase.SoundLoader '([''' dbase.PathName '\' dbase.SoundFiles(files(i1)).name '''],1)']);
        bout_audio1 = full_audio1(dbase.BoutTimes{files(i1)}(1, 1):dbase.BoutTimes{files(i1)}(1, 2));
        for i2 = (i1 + 1):P.Bouts
            nc = nc + 1;
            waitbar(nc/total_comparisons, wbh, sprintf('Bird %g', nbird))
            [full_audio2 fs dt label props] = eval(['egl_' dbase.SoundLoader '([''' dbase.PathName '\' dbase.SoundFiles(files(i2)).name '''],1)']);
            bout_audio2 = full_audio2(dbase.BoutTimes{files(i2)}(1, 1):dbase.BoutTimes{files(i2)}(1, 2));
            maturity_index{nbird}(nc) = SpecCrossCorr_YM2(bout_audio1, bout_audio2, dbase.Fs);
        end
    end
    close(wbh)
    
end

%%
figh = figure;
axh = axes;
bar(cellfun(@mean, maturity_index))
hold on
errorbar(1:length(maturity_index), cellfun(@std, maturity_index) / total_comparisons)
