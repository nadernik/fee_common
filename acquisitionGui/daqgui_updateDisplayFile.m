% --- Update display file.
function daqgui_updateDisplayFile(guifig, dispfilenum)
handles = guidata(guifig);
set(handles.editFilenum, 'String', num2str(dispfilenum));
daqgui_updateDisplay(guifig);