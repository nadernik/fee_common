function dbase = dbaseSubset(dbase, filenums)
%DBASESUBSET New dbase that contains a subset of files from the original
%
%DBASE = DBASESUBSET(DBASE, FILENUMS)

dbase.Times = dbase.Times(1, filenums);
dbase.FileLength = dbase.FileLength(1, filenums);
dbase.SoundFiles = dbase.SoundFiles(filenums, 1);
for ch = 1:length(dbase.ChannelFiles)
    if ~isempty(dbase.ChannelFiles{ch})
        dbase.ChannelFiles{ch} = dbase.ChannelFiles{ch}(filenums, 1);
    end
end
dbase.SegmentThresholds = dbase.SegmentThresholds(1, filenums);
dbase.SegmentTimes = dbase.SegmentTimes(1, filenums);
dbase.SegmentTitles = dbase.SegmentTitles(1, filenums);
dbase.SegmentIsSelected = dbase.SegmentIsSelected(1, filenums);
dbase.EventThresholds = dbase.EventThresholds(:, filenums);
for ev = 1:length(dbase.EventTimes)
    dbase.EventTimes{ev} = dbase.EventTimes{ev}(:, filenums);
    dbase.EventIsSelected{ev} = dbase.EventIsSelected{ev}(:, filenums);
end
dbase.Properties.Names = dbase.Properties.Names(:, filenums);
dbase.Properties.Values = dbase.Properties.Values(:, filenums);
dbase.Properties.Types = dbase.Properties.Types(:, filenums);
dbase.AnalysisState.CurrentFile = 1;
