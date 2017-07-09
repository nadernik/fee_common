function ButtonWasPressed(hObject, eventdata, handles)
    global istart w pressed patches h SpecIm ExtraIm Tit npat ...
        slines1 slines2 dbase FnumBnum Timestamps; 
KeyPressed = eventdata.Key;
switch KeyPressed
    case 'rightarrow'
        istart = min(istart+stepdur/2, size(PlotC,2)-stepdur);
        set(mTextBox,'String',num2str(istart));
        UpdatePlot()
    case 'leftarrow'
        istart = max(istart-stepdur/2,1);
        set(mTextBox,'String',num2str(istart));
        UpdatePlot()
end
end