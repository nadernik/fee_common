function sorted_rasters(dbase, varargin)

% NOT IMPLEMENTED:
% Time warping - because no one knows how to use it
% Selected files only - because need to have electro_gui open
% Continuous function - because menu option isn't there? need electro_gui?


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

% Options - FIXME

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




parse(p, varargin)
r = p.Results;

%% Set things
setFileRange(h, r.FileRange)
setTriggerSource(h, r.TriggerSource)
setEventSource(h, r.EventSource)
setTriggerType(h, r.TriggerType)

% Options - FIXME

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



