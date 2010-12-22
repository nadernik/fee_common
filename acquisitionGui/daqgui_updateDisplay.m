function daqgui_updateDisplay(guifig)
%helper function for daqgui...

dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
ddd = aa_getAppDataReadOnly(guifig, 'daqdisplaydata');
handles = guidata(guifig);
[dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
currchan = dgd.currChan;

exper = dgd.exper;
if(logical(ok) && dispfilenum > 0)
    %Load the data...
    tic;
    audio = loadAudio(exper,dispfilenum);   
    [sig, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper, dispfilenum, currchan);
    daq_log(['Time to loadfiles: ' num2str(toc)]);
    
    %Clip according to current zoom if current.
    if(ddd.currFilenum == dispfilenum)
        sn = min(ddd.startNdx, length(audio));
        en = max(1, ddd.endNdx);
        if(sn < en)
            audio = audio(sn:en);
            sig = sig(sn:en);
        end
    else
        sn = 1;
        en = length(audio);
    end
    
    %display the audio specgram.
    axes(handles.axesAudio);     
    timeAxis = [sn-1:en-1]/exper.desiredInSampRate;
    if(length(audio)>0)
        displaySpecgramQuick(audio, exper.desiredInSampRate, [0,8000], getSpecgramPowerRange(handles), timeAxis(1));
        title([exper.birdname, ' ', exper.expername, ' ', num2str(dispfilenum), ' ', timeCreated]);                         
        set(handles.axesAudio,'ButtonDownFcn', @daqguiAxesButtonPress);
    end
    
    %Display the channel signal.
    axes(handles.axesSignal); 
    if(length(sig)>0)
        axes(handles.axesSignal);
        plotTimeSeriesQuick(timeAxis, sig);
        axis tight;
        set(handles.axesSignal,'ButtonDownFcn', @daqguiAxesButtonPress);
    end
end

function daqguiAxesButtonPress(src, event)
%Load the appdata we need...
guifig = get(src,'Parent');
handles = guidata(guifig);
dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
[ddd, status] = aa_checkoutAppData(guifig, 'daqdisplaydata');
if(~status)
    return;
end

%If we successfully got the appdata
%try,
    %Check if the display data is current, if not update.
    [dispfilenum, ok] = str2num(get(handles.editFilenum,'String'));
    if(ddd.currFilenum ~= dispfilenum)
        exper = dgd.exper;
        audio = loadAudio(exper,dispfilenum);   
        ddd.currFilenum = dispfilenum;
        ddd.startNdx = 1;
        ddd.endNdx = length(audio);
        ddd.lengthFile = ddd.endNdx;
        ddd.fs = exper.desiredInSampRate; 
        ddd.startTime = 0;
    end
    
    ax = src;
    axes(ax);
    mouseMode = get(gcf, 'SelectionType');
    clickLocation = get(ax, 'CurrentPoint');

    if(strcmp(mouseMode, 'alt'))
        rect = rbbox;
        endPoint = get(ax,'CurrentPoint'); 
        point1 = clickLocation(1,1:2);              % extract x and y
        point2 = endPoint(1,1:2);
        shiftTime = point1(1) - point2(1);    
        shiftNdx = round((shiftTime * ddd.fs) + 1);
        shiftNdx = shiftNdx - max(0, ddd.endNdx + shiftNdx - ddd.lengthFile);
        shiftNdx = shiftNdx - min(0, ddd.startNdx + shiftNdx -1);
        ddd.startNdx = ddd.startNdx + shiftNdx;
        ddd.endNdx = ddd.endNdx + shiftNdx;
    elseif(strcmp(mouseMode, 'open'))
        %double click to zoom out
        ddd.startNdx = 1;
        ddd.endNdx = ddd.lengthFile;
    elseif(strcmp(mouseMode, 'normal'))
        %left click to zoom in.
        rect = rbbox;
        endPoint = get(gca,'CurrentPoint'); 
        point1 = clickLocation(1,1:2);              % extract x and y
        point2 = endPoint(1,1:2);
        p1 = min(point1,point2);             % calculate locations
        offset = abs(point1-point2);         % and dimensions
        if(offset(1)/diff(xlim) < .001)
            quarter = round((ddd.endNdx - ddd.startNdx) / 4);
            midndx = round((p1(1) - ddd.startTime)*ddd.fs + 1);
            ddd.startNdx = max(1,midndx - quarter);
            ddd.endNdx = min(ddd.lengthFile, midndx + quarter);
        else
            ddd.startNdx = max(round((p1(1) - ddd.startTime)*ddd.fs + 1),1);
            ddd.endNdx = min(round((p1(1) + offset(1) - ddd.startTime)*ddd.fs + 1),ddd.lengthFile);
        end
    end
    aa_checkinAppData(guifig, 'daqdisplaydata', ddd);
    daqgui_updateDisplay(guifig);
%catch,
%    l = lasterror
%    l.stack.name(:)
%    aa_checkinAppData(guifig, 'daqdisplaydata', ddd);
%    warning('crash in daqguiAxesButtonPress');
%end

function range = getSpecgramPowerRange(handles)
powermin = str2num(get(handles.editSpecgramMinPower, 'String'));
powermax = str2num(get(handles.editSpecgramMaxPower, 'String'));
range  =[powermin, powermax];
if(length(range)==1)
    range = [];
end