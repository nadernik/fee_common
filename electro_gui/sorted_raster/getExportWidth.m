function width = getExportWidth(h)
handles = guidata(h);
ch = get(handles.panel_ExportWidth, 'Children');
iw = findobj('Parent', handles.panel_ExportWidth, 'Value', 1);
iw = 3 - find(ch == iw);
width = handles.ExportWidth(iw);