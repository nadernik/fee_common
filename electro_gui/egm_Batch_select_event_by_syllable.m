function handles = egm_Batch_select_event_by_syllable(handles)
% Select (or de-select) events by the syllables in which they occur

%% Prompt user to choose the event type
event_name = cell(size(handles.EventSources));
for ii = 1:length(handles.EventSources)
    event_name{ii} = [handles.EventSources{ii} ' - ' handles.EventFunctions{ii} ' - ' handles.EventDetectors{ii}];
end
[event_type, ok] = listdlg('ListString', event_name, 'SelectionMode', 'single', 'ListSize', [320 150], 'Name', 'Choose event type');
if ~ok
    return
end

%% Prompt user to choose syllable
all_syllable_labels = horzcat(handles.SegmentTitles{:});
% Unfortunately, unlabeled syllables are the empty matrix [] instead of the
% empty string ''. Need to get rid of these empty matrices so we can use
% MATLAB's unique() function.
mpty = cellfun(@isempty, all_syllable_labels);
syllable_types = unique(all_syllable_labels(~mpty));
[ndx, ok] = listdlg('ListString', syllable_types);
% abort macro if user did not select a syllable type
if ~ok 
    return
end

chosen_label = syllable_types{ndx};

%% Prompt user for what to do with other events (deselect or leave unchanged)?
other_event_action = questdlg('What happens to the OTHER events?', 'Other events', 'Deselect', 'Leave unchanged', 'Leave unchanged');

%% Get events in chosen syllable
% Note that a single event can belong to multiple syllables.

count_events_selected = 0; 
count_other_events = 0;

for filenum = 1:length(handles.SegmentTitles)% for each file
   
    % for each syllable in this file
    is_in_syll = false(length(handles.EventSelected{event_type}{1,filenum}), 1);
    for syllnum = 1:length(handles.SegmentTitles{filenum})

        % skip if this isn't the chosen syllable type
        this_label = handles.SegmentTitles{filenum}{syllnum};
        if isempty(this_label) || ~strcmp(this_label, chosen_label)
            continue
        end
       
        % get events in this syllable
        t1 = handles.EventTimes{event_type}{1,filenum};
        t2 = handles.EventTimes{event_type}{2,filenum};
        t_event_start = min(t1, t2); % vector (1 x number_of_events)
        t_event_end   = max(t1, t2); % vector (1 x number_of_events)
        t_syll_start = handles.SegmentTimes{filenum}(syllnum,1); % scalar
        t_syll_end   = handles.SegmentTimes{filenum}(syllnum,2); % scalar
        event_starts_in_syll = t_event_start >= t_syll_start  & t_event_start <= t_syll_end;
        event_ends_in_syll   = t_event_end   >= t_syll_start  & t_event_end   <= t_syll_end;
        syll_starts_in_event = t_syll_start  >= t_event_start & t_syll_start  <= t_event_end;
        syll_ends_in_event   = t_syll_end    >= t_event_start & t_syll_end    <= t_event_end;
        is_in_syll = is_in_syll | ...
            event_starts_in_syll | event_ends_in_syll | ...
            syll_starts_in_event | syll_ends_in_event;
    end
    
    % select these events
    for p = 1:size(handles.EventSelected{event_type}, 1)
        % for each point in the event (e.g. zenith and nadir, or upward 
        % crossing and downward crossing)
        handles.EventSelected{event_type}{p, filenum}(is_in_syll) = 1;
    end
    
    % de-select other events if user asked for it at the beginning
    if strcmp(other_event_action, 'Deselect')
        for p = 1:size(handles.EventSelected{event_type}, 1)
            % for each point in the event (e.g. zenith and nadir, or upward
            % crossing and downward crossing)
            handles.EventSelected{event_type}{p, filenum}(~is_in_syll) = 0;
        end
    end
    
    count_events_selected = count_events_selected + sum(is_in_syll);
    count_other_events = count_other_events + sum(~is_in_syll);
end
disp([int2str(count_events_selected) ' events selected because they occur in syllable ' chosen_label])
disp([int2str(count_other_events) ' other events were ' other_event_action])
    
    