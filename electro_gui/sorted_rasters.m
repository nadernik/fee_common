function varargout = sorted_rasters(dbase, varargin)

% NOT IMPLEMENTED:
% Time warping - because no one knows how to use it
% Selected files only - because need to have electro_gui open
% Continuous function - because menu option isn't there? need electro_gui?
% Deleting events - beacuse this is only for when you make a mistake
% When hold is on, can still change disabled controls. This is dangerous.
% Select triggers button - because no one knows what it does
% PPT export - because it doesn't work on my computer
% Auto color by label - because not sure if needed and woudl be hard to
%    specify which things should be autocolored

% things that will require editing egm_Sorted_rasters.m
%   remove overlaps on opening

%%%TODO
% Export to MATLAB (triginfo)
% Export figure? What is the output of this function?
% Trial height
% Time axis
% Y axis



%% Create sorted rasters figure if not passed a handle to it
% If we are passed a handle, assume it already has the dbase loaded
if ishandle(varargin{1})
    h = varargin{1};
    params = varargin(2:end);
else
    [~, h] = egm_Sorted_rasters;
    params = varargin(1:end);
end

%% Parse parameters

p = inputParser;

% FileRange vector of file numbers to include. Default is to include all
% files.
numFiles = length(dbase.SoundFiles);
isFileNumber = @(x) 1 <= x & x <= numFiles & mod(x, 1) == 0;
addParameter(p, 'FileRange', 1:numFiles, @(x) all(isFileNumber(x)))

% Sources
% Can be 'Sound' or an integer for a class of events. 
addParameter(p, 'TriggerSource', 'Sound')
addParameter(p, 'EventSource',   'Sound')

% Types - a string
addParameter(p, 'TriggerType', 'Syllables');
addParameter(p, 'EventType',   'Syllables');

% Trigger source options 
addParameter(p, 'TriggerSyllIncluded',     ''     )
addParameter(p, 'TriggerSyllExcluded',     ''     )
addParameter(p, 'TriggerMotifSequence',    {}     )
addParameter(p, 'TriggerMotifMaxGap',        0.2  )
addParameter(p, 'TriggerBoutInterval',       2    )
addParameter(p, 'TriggerBoutMinDuration',    0.2  )
addParameter(p, 'TriggerBoutMinSyllCount',   2    )
addParameter(p, 'TriggerBurstMinFreq',     100    )
addParameter(p, 'TriggerBurstMinCount',      2    )
addParameter(p, 'TriggerPauseMinDuration',   0.05 )

% Event source options
addParameter(p, 'EventSyllIncluded',     ''     )
addParameter(p, 'EventSyllExcluded',     ''     )
addParameter(p, 'EventMotifSequence',    {}     )
addParameter(p, 'EventMotifMaxGap',        0.2  )
addParameter(p, 'EventBoutInterval',       2    )
addParameter(p, 'EventBoutMinDuration',    0.2  )
addParameter(p, 'EventBoutMinSyllCount',   2    )
addParameter(p, 'EventBurstMinFreq',     100    )
addParameter(p, 'EventBurstMinCount',      2    )
addParameter(p, 'EventPauseMinDuration',   0.05 )

% Alignment (onset, offset, or midpoint)
addParameter('Alignment', 'Onset')

% Filtering
isFilterLimits = @(x) numel(x) == 2 && isnumeric(x);
unlimited = [-Inf, Inf];
addParameter(p, 'FilterByTriggerDuration',   unlimited, isFilterLimits)
addParameter(p, 'FilterByPrevTriggerOnset',  unlimited, isFilterLimits)
addParameter(p, 'FilterByPrevTriggerOffset', unlimited, isFilterLimits)
addParameter(p, 'FilterByNextTriggerOnset',  unlimited, isFilterLimits)
addParameter(p, 'FilterByNextTriggerOffset', unlimited, isFilterLimits)
addParameter(p, 'FilterByPrevEventOnset',    unlimited, isFilterLimits)
addParameter(p, 'FilterByPrevEventOffset',   unlimited, isFilterLimits)
addParameter(p, 'FilterByNextEventOnset',    unlimited, isFilterLimits)
addParameter(p, 'FilterByNextEventOffset',   unlimited, isFilterLimits)
addParameter(p, 'FilterByFirstEventOnset',   unlimited, isFilterLimits)
addParameter(p, 'FilterByFirstEventOffset',  unlimited, isFilterLimits)
addParameter(p, 'FilterByLastEventOnset',    unlimited, isFilterLimits)
addParameter(p, 'FilterByLastEventOffset',   unlimited, isFilterLimits)
addParameter(p, 'FilterByNumberOfEvents',    unlimited, isFilterLimits)
addParameter(p, 'FilterByIsInEvent',         unlimited, isFilterLimits)

addParameter(p, 'BackgroundColor', [1 1 1])
addParameter(p, 'Hold', 'off')
addParameter(p, 'SkipSorting', false)

% Window
addParameter(p, 'LockLimitsToTrigger', true)
addParameter(p, 'ExcludePartialWindows', true)
addParameter(p, 'ExcludePartialEvents', false)
addParameter(p, 'WindowLimits', [0.15 0.15], isFilterLimits)
addParameter(p, 'StartReference', 'Current offset')
addParameter(p, 'StopReference', 'Current offset')

% Exporting
addParameter(p, 'ExportHeightUnits', 'Absolute')
addParameter(p, 'ExportWidthUnits', 'Absolute')
addParameter(p, 'ExportPSTHHeight', 2)
addParameter(p, 'ExportHistHeight', 2)
addParameter(p, 'ExportInterval', 0.25)
addParameter(p, 'ExportResolution', 300);
addParameter(p, 'ExportWidth', 6);
addParameter(p, 'ExportHeight', 4);

% Sorting
addParameter(p, 'PrimarySortBy', 'Trigger duration')
addParameter(p, 'PrimarySortDirection', 'ascending')
addParameter(p, 'PrimarySortGroupLabels', false)
addParameter(p, 'SecondarySortBy', 'Absolute time')
addParameter(p, 'SecondarySortDirection', 'ascending')

% Raster
defaultRaster(1).Name = 'Current trigger onset';
defaultRaster(1).Include = 1;
defaultRaster(1).Continuous = 1;
defaultRaster(1).Color = [1 0 0];
defaultRaster(1).Param = 1;
addParameter(p, 'RasterElements', defaultRaster)

% Histograms
addParameter(p, 'PsthShow', true)
addParameter(p, 'PsthBinSize', 0.01)
addParameter(p, 'PsthYLim', 'Auto')
addParameter(p, 'PsthSmoothing', 1)
addParameter(p, 'PsthYUnits', 'Rate (Hz)')
addParameter(p, 'PsthCount', 'Onsets')

addParameter(p, 'VerticalHistogramShow', true)
addParameter(p, 'VerticalHistogramBinSize', 0.01)
addParameter(p, 'VerticalHistogramYLim', 'Auto')
addParameter(p, 'VerticalHistogramSmoothing', 1)
addParameter(p, 'VerticalHistogramYUnits', 'Rate (Hz)')
addParameter(p, 'VerticalHistogramCount', 'Onsets')
addParameter(p, 'VerticalHistogramROI', [-Inf, Inf])
parse(p, params{:})
r = p.Results;

%% Set things
setHold(h, r.Hold)

setFileRange(h, r.FileRange)
setTriggerSource(h, r.TriggerSource)
setEventSource(h, r.EventSource)
setTriggerType(h, r.TriggerType)

% Trigger source options 
setSourceOption(h, 'trigger', 'includeSyllList', r.TriggerSyllIncluded)
setSourceOption(h, 'trigger', 'ignoreSyllList',  r.TriggerSyllExcluded)
setSourceOption(h, 'trigger', 'motifSequences',  r.TriggerMotifSequence)
setSourceOption(h, 'trigger', 'motifInterval',   r.TriggerMotifMaxGap)
setSourceOption(h, 'trigger', 'boutInterval',    r.TriggerBoutInterval)
setSourceOption(h, 'trigger', 'boutMinDuration', r.TriggerBoutMinDuration)
setSourceOption(h, 'trigger', 'boutMinSyllables',r.TriggerBoutMinSyllCount)
setSourceOption(h, 'trigger', 'burstFrequency',  r.TriggerBurstMinFreq)
setSourceOption(h, 'trigger', 'burstMinSpikes',  r.TriggerBurstMinCount)
setSourceOption(h, 'trigger', 'pauseMinDuration',r.TriggerPauseMinDuration)

% Event source options
setSourceOption(h, 'event', 'includeSyllList', r.EventSyllIncluded)
setSourceOption(h, 'event', 'ignoreSyllList',  r.EventSyllExcluded)
setSourceOption(h, 'event', 'motifSequences',  r.EventMotifSequence)
setSourceOption(h, 'event', 'motifInterval',   r.EventMotifMaxGap)
setSourceOption(h, 'event', 'boutInterval',    r.EventBoutInterval)
setSourceOption(h, 'event', 'boutMinDuration', r.EventBoutMinDuration)
setSourceOption(h, 'event', 'boutMinSyllables',r.EventBoutMinSyllCount)
setSourceOption(h, 'event', 'burstFrequency',  r.EventBurstMinFreq)
setSourceOption(h, 'event', 'burstMinSpikes',  r.EventBurstMinCount)
setSourceOption(h, 'event', 'pauseMinDuration',r.EventPauseMinDuration)


setAlignment(h, r.Alignment)

% Filtering
setFiltering(h, 'Trigger duration',        r.FilterByTriggerDuration)
setFiltering(h, 'Previous trigger onset',  r.FilterByPrevTriggerOnset)
setFiltering(h, 'Previous trigger offset', r.FilterByPrevTriggerOffset)
setFiltering(h, 'Next trigger onset',      r.FilterByNextTriggerOnset)
setFiltering(h, 'Next trigger offset',     r.FilterByNextTriggerOffset)
setFiltering(h, 'Preceding event onset',   r.FilterByPrevEventOnset)
setFiltering(h, 'Preceding event offset',  r.FilterByPrevEventOffset)
setFiltering(h, 'Following event onset',   r.FilterByNextEventOnset)
setFiltering(h, 'Following event offset',  r.FilterByNextEventOffset)
setFiltering(h, 'First event onset',       r.FilterByFirstEventOnset)
setFiltering(h, 'First event offset',      r.FilterByFirstEventOffset)
setFiltering(h, 'Last event onset',        r.FilterByLastEventOnset)
setFiltering(h, 'Last event offset',       r.FilterByLastEventOffset)
setFiltering(h, 'Number of events',        r.FilterByNumberOfEvents)
setFiltering(h, 'Is in event',             r.FilterByIsInEvent)

setBackgroundColor(h, r.BackgroundColor)
setSkipSorting(h, r.SkipSorting)
setLockLimitsToTrigger(h, r.LockLimitsToTrigger)
setExcludePartialWindows(h, r.ExcludePartialWindows)
setExcludePartialEvents(h, r.ExcludePartialEvents)
setWindowLimits(h, r.WindowLimits)
setStartReference(h, r.StartReference)
setStopReference(h, r.StopReference)

% Exporting
setExportHeightUnits(h, r.ExportHeightUnits)
setExportWidthUnits(h, r.ExportWidthUnits)
setExportPSTHHeight(h, r.ExportPSTHHeight)
setExportHistHeight(h, r.ExportHistHeight)
setExportInterval(h, r.ExportInterval)
setExportResolution(h, r.ExportResolution)
setExportWidth(h, r.ExportWidth)
setExportHeight(h, r.ExportHeight)

% Sorting
setPrimarySortBy(h, r.PrimarySortBy)
setPrimarySortDirection(h, r.PrimarySortDirection)
setPrimarySortGroupLabels(h, r.PrimarySortGroupLabels)
setSecondarySortBy(h, r.SecondarySortBy)
setSecondarySortDirection(h, r.SecondarySortDirection)

% Raster
for ii = 1:length(r.RasterElements)
    setRasterElement(h, r.RasterElements(ii))
end

% Histogram
setHistShow(      h, 'psth', r.PsthShow)
setHistBinSize(   h, 'psth', r.PsthBinSize)
setHistYLim(      h, 'psth', r.PsthYLim)
setHistSmoothing( h, 'psth', r.PsthSmoothing)
setHistYUnits(    h, 'psth', r.PsthYUnits)
setHistCount(     h, 'psth', r.PsthCount)

setHistShow(      h, 'vert', r.VerticalHistogramShow)
setHistBinSize(   h, 'vert', r.VerticalHistogramBinSize)
setHistYLim(      h, 'vert', r.VerticalHistogramYLim)
setHistSmoothing( h, 'vert', r.VerticalHistogramSmoothing)
setHistYUnits(    h, 'vert', r.VerticalHistogramYUnits)
setHistCount(     h, 'vert', r.VerticalHistogramCount)
setHistROI(       h, 'vert', r.VerticalHistogramROI)

%% GENERATE RASTER!
handles = guidata(h);
callbackIfEnabled('push_GenerateRaster_Callback', handles.push_GenerateRaster, [], handles)