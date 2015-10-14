function handles = egm_Video_events_from_ANVIL(handles)

ANVIL_FILE_PROP_NAME = 'AnvilFile';
OFFSET_PROP_NAME = 'OffsetSeconds';

detector_names = {...
    'Video_roll_left'
    'Video_roll_right'
    'Video_pitch_up'
    'Video_pitch_down'
    'Video_yaw_left'
    'Video_yaw_right'};
% detector_names = {'Video_roll_left'}; %FIXME     

filenum = str2double(get(handles.edit_FileNumber, 'String'));
anvil_file = eg_GetProperty(handles, filenum, ANVIL_FILE_PROP_NAME);
offset = eg_GetProperty(handles, filenum, OFFSET_PROP_NAME);
for ii = 1:length(detector_names)
    % Select detector
    obj = handles.popup_EventDetector1;
    val = find(strcmp(get(obj, 'String'), detector_names{ii}));
    set(obj, 'Value', val)
    electro_gui('popup_EventDetector1_Callback', obj, [], handles);
    handles = guidata(obj);
    
    % Set parameters for event detector
    handles.EventParams1 = feval(['ege_' detector_names{ii}], 'params');
    handles.EventParams1.Values{1} = anvil_file;
    handles.EventParams1.Values{2} = offset;
    
    % Detect events
    handles = electro_gui('DetectEvents', handles, 1);

end
