function setRasterElement(h, elem)

% Select the raster element in the list
handles = guidata(h);
val = popupLookup(handles.list_Plot, elem.Name);
set(handles.list_Plot, 'Value', val)
egm_Sorted_rasters('list_Plot_Callback', handles.list_Plot, [], handles)

% Include this object in the raster if elem.Include is true
if elem.Include == true
    handles = guidata(h);
    set(handles.check_PlotInclude, 'Value', 1)
    egm_Sorted_rasters('check_PlotInclude_Callback', ...
        handles.check_PlotInclude, [], handles)
end

% Check the 'continuous' box if elem.Continuous is true
if elem.Continuous == true
    handles = guidata(h);
    set(handles.check_PlotContinuous, 'Value', 1)
    egm_Sorted_rasters('check_PlotContinuous_Callback', ...
        handles.check_PlotContinuous, [], handles)
end

% Set color

