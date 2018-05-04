function acqgui_updateSutterPosition(obj, evnt, guifig)
%DON'T NEED TO PASS obj OR evnt.  ONLY USED WHEN MATLAB TIMER CALLS THE FUNCTION

handles = guidata(guifig);
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');  

if(dgd.sutterStatus)
    [microsteps, micronsApprox, Status] = sutterGetCurrentPosition(dgd.sutterConnection);
    if(Status)
        set(handles.textSutterX , 'String', sprintf('X: %4.2f', micronsApprox(1)));
        set(handles.textSutterY , 'String', sprintf('Y: %4.2f', micronsApprox(2)));
        set(handles.textSutterZ , 'String', sprintf('Z: %4.2f', micronsApprox(3)));
    else
        %we somehow how lost of sutter connection... try to reconnect, just
        %this once
        set(handles.textSutterX , 'String', 'X: Not Connected');
        set(handles.textSutterY , 'String', 'Y: Not Connected');
        set(handles.textSutterZ , 'String', 'Z: Not Connected');
        
        [dgd, bStatus] = aa_checkoutAppData(guifig, 'acqguidata');
        if(~bStatus)
            return;
        end
        [dgd.sutterConnection, dgd.sutterStatus] = sutterOpenConnection;
        aa_checkinAppData(guifig, 'acqguidata',dgd);
    end
end