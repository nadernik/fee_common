% --- Update display file.
function acqgui_updateDisplayFile(guifig, dispfilenum)
%Call this function if the file being displayed is changing or if the experiment is
%being switched.  It updates the display data and the text field displaying
%the filenum.

handles = guidata(guifig);

%if we're reloading the same file because of a experiment switch
%then the currFilenum will already equal dispfilenum.
%Also occurs when experiment is initially opened.
dddRO = aa_getAppDataReadOnly(guifig, 'acqdisplaydata');
if(dddRO.currFilenum == dispfilenum)
    acqgui_updateDisplay(guifig);
else
    [ddd,status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
    if(~status)
        set(handles.editFilenum, 'String', num2str(dddRO.currFilenum));
        return;
    end
    set(handles.editFilenum, 'String', num2str(dispfilenum));   
    ddd.currFilenum = dispfilenum;
    ddd.startNdx = 0;
    ddd.endNdx = 0;
    ddd.lengthFile = 0;
    aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
    acqgui_updateDisplay(guifig);
end
    