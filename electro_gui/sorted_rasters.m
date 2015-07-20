function sorted_rasters(dbase, varargin)

%eg = openfig('electro_gui');
eg = electro_gui;
handles = guidata(eg);
electro_gui('push_Open_Callback', handles.push_Open, [], handles)

%MacrosMenuclick
handles = guidata(eg);
macroNames = get(handles.menu_Macros, 'label');
hObject = handles.menu_Macros(strcmp(macroNames, 'Sorted_rasters')); % menu item corresponding to to Sorted_rasters
electro_gui('MacrosMenuclick', hObject, [], handles)


% f = find(handles.menu_Macros==hObject);
% if isempty(f)
%     warning('Could not find the appropriate macro')
%     keyboard()
% end
% mcr = get(handles.menu_Macros(f),'label');
% handles = eval(['egm_' mcr '(handles)']);


%h = egm_Sorted_rasters(handles, 'ReturnFigureHandle')



