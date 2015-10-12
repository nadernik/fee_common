function handles = egm_Video_events_from_ANVIL(handles)

ANVIL_FILE_PROPERTY_NAME = 'AnvilFile';
OFFSET_PROPERTY_NAME = 'OffsetSeconds';

detector_names = {...
    'Video_roll_left'
    'Video_roll_right'
    'Video_pitch_up'
    'Video_pitch_down'
    'Video_yaw_left'
    'Video_yaw_right'};
     

filenum = str2double(get(handles.edit_FileNumber, 'String'));
propndx = strcmp(handles.Properties.Names{filenum}, ANVIL_FILE_PROPERTY_NAME);
anvil_file = handles.Properties.Values{filenum}{propndx};
propndx = strcmp(handles.Properties.Names{filenum}, OFFSET_PROPERTY_NAME);
offset = handles.Properties.Values{filenum}{propndx};
for ii = 1:length(detector_names)
    % Select detector
    obj = handles.popup_EventDetector1;
    val = find(strcmp(get(obj, 'String'), detector_names{ii}));
    set(obj, 'Value', val)
    electro_gui('popup_EventDetector1_Callback', obj, [], handles);
    handles = guidata(obj);
    
    % Set parameters
    handles.EventParams1 = feval(['ege_' detector_names{ii}], 'params');
    handles.EventParams1.Values{1} = anvil_file;
    handles.EventParams1.Values{2} = offset;
    
    % Detect events
    handles = DetectEvents(handles, 1);

end
