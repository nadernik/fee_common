function acqgui_updateDisplay(guifig)
%helper function for acqgui...

tsd = getappdata(guifig, 'threadSafeData');
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
ddd = aa_getAppDataReadOnly(guifig, 'acqdisplaydata');
handles = guidata(guifig);

exper = dgd.expers{dgd.ce};
dispfilenum = ddd.currFilenum;
currchanAudio = ddd.currChanAudio;
currchan = ddd.currChan;
currchan2 = ddd.currChan2;
currchan3 = ddd.currChan3;

if(dispfilenum == 0)
    cla(handles.axesAudio);
    cla(handles.axesSignal);
    cla(handles.axesSignal2);
    cla(handles.axesSignal3);
    return;
end

try
    %check if file is loadable...
    %load file without loading data...
    [audio, junk1, junk2, startSamp, timeFileCreated, startTime, names, values, info] = loadData(exper, dispfilenum, currchanAudio, 0);
    whichSamples = [];
    maxLoadSize = 2000000;
    if(info.numSamples > maxLoadSize)
        whichSamples = [1,maxLoadSize];
        h = warndlg(['File is too big. Only loading first ', num2str(maxLoadSize), ' samples.']);
        uiwait(h, 5);
    end

    %Load the data...
    tic;
    [audio, junk1, junk2, startSamp, timeFileCreated, startTime, names, values] = loadData(exper, dispfilenum, currchanAudio, whichSamples);
    [sig,  sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper, dispfilenum, currchan, whichSamples);
    [sig2, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper, dispfilenum, currchan2, whichSamples);
    [sig3, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper, dispfilenum, currchan3, whichSamples);
    daq_log(['Time to loadfiles: ' num2str(toc)]);

    %Display any file properties
    strList = {};
    for(nProp = 1:length(names))
        strList{nProp} = [names{nProp},': ',values{nProp}];
    end
    set(handles.listboxDatafileProperties, 'String', strList);

    %Clip according to current zoom if current.
    if(ddd.startNdx > 0 & ddd.endNdx > 0)
        sn = min(ddd.startNdx, length(audio));
        en = max(1, ddd.endNdx);
        if(sn < en)
            audio = audio(sn:en);
            sig = sig(sn:en);
            sig2 = sig2(sn:en);
            sig3 = sig3(sn:en);
        end
    else
        sn = 1;
        en = length(audio);
    end

    %Display the audio specgram.

    timeAxis = [sn-1:en-1]/exper.desiredInSampRate;
    if(~isempty(audio))
        axes(handles.axesAudio);
        audio = audio - mean(audio);
        displaySpecgramQuick(audio, exper.desiredInSampRate, [0,8000], tsd.displayParams(dgd.ce).audioCLim, timeAxis(1));
        title([exper.birdname, ' ', exper.expername, ' ', num2str(dispfilenum), ' ', timeCreated]);
        set(handles.axesAudio,'ButtonDownFcn', @acqguiAxesButtonPress);
        ud.data = audio; ud.fs = info.fs;
        set(handles.axesAudio,'UserData', ud);
    end

    %Display the channel signal.
    if(~isempty(sig))
        axes(handles.axesSignal);
        plotTimeSeriesQuick(timeAxis, sig);
        axis tight;
        set(handles.axesSignal,'ButtonDownFcn', @acqguiAxesButtonPress);
        ud.data = sig; ud.fs = info.fs;
        set(handles.axesSignal,'UserData', ud);
        set(handles.axesSignal,'XTickLabel', []);
    end

    %Display the channel signal.
    if(~isempty(sig2))
        axes(handles.axesSignal2);
        plotTimeSeriesQuick(timeAxis, sig2);
        axis tight;
        set(handles.axesSignal2,'ButtonDownFcn', @acqguiAxesButtonPress);
        ud.data = sig2; ud.fs = info.fs;
        set(handles.axesSignal2,'UserData', ud);
        set(handles.axesSignal2,'XTickLabel', []);
    end

    %Display the channel signal.
    if(~isempty(sig3))
        axes(handles.axesSignal3);
        plotTimeSeriesQuick(timeAxis, sig3);
        axis tight;
        set(handles.axesSignal3,'ButtonDownFcn', @acqguiAxesButtonPress);
        ud.data = sig3; ud.fs = info.fs;
        set(handles.axesSignal3,'UserData', ud);
        set(handles.axesSignal3,'XTickLabel', []);
    end
catch
    disp('Error caught in acqgui_updateDisplay:');
    disp(lasterr);
    cla(handles.axesAudio);
    cla(handles.axesSignal);
    cla(handles.axesSignal2);
    cla(handles.axesSignal3);
end

function acqguiAxesButtonPress(src, event)
%Load the appdata we need...
guifig = get(src,'Parent');
handles = guidata(guifig);
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
[ddd, status] = aa_checkoutAppData(guifig, 'acqdisplaydata');
if(~status)
    return;
end

try
    %If we successfully got the display data
    exper = dgd.expers{dgd.ce};
    dispfilenum = ddd.currFilenum;

    audio = loadAudio(exper,dispfilenum);
    if(ddd.startNdx == 0)
        ddd.startNdx = 1;
        ddd.endNdx = length(audio);
        ddd.lengthFile = ddd.endNdx;
    end
    fs = exper.desiredInSampRate;
    startTime = (ddd.startNdx-1)/fs;

    ax = src;
    axes(ax);
    mouseMode = get(gcf, 'SelectionType');
    clickLocation = get(ax, 'CurrentPoint');

    if(strcmp(mouseMode, 'alt'))
        %rect = rbbox;
        %endPoint = get(ax,'CurrentPoint');
        %point1 = clickLocation(1,1:2);              % extract x and y
        %point2 = endPoint(1,1:2);
        %ylim(sort([point1(2), point2(2)]));
        %shiftTime = point1(1) - point2(1);
        %shiftNdx = round((shiftTime * fs) + 1);
        %shiftNdx = shiftNdx - max(0, ddd.endNdx + shiftNdx - ddd.lengthFile);
        %shiftNdx = shiftNdx - min(0, ddd.startNdx + shiftNdx -1);
        %ddd.startNdx = ddd.startNdx + shiftNdx;
        %ddd.endNdx = ddd.endNdx + shiftNdx;
        aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
    elseif(strcmp(mouseMode, 'extend'))
        %shift click to zoom out
        ddd.startNdx = 1;
        ddd.endNdx = length(audio);
        aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
        acqgui_updateDisplay(guifig);
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
            midndx = round((p1(1) - startTime)*fs + 1);
            ddd.startNdx = max(1,midndx - quarter);
            ddd.endNdx = min(ddd.lengthFile, midndx + quarter);
        else
            ddd.startNdx = max(round((p1(1))*fs + 1),1);
            ddd.endNdx = min(round((p1(1) + offset(1))*fs + 1),ddd.lengthFile);
        end
        aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
        acqgui_updateDisplay(guifig);
    else
        aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
    end
catch
    if(dispfilenum > 0)
        disp('Error caught in acqguiAxesButtonPress:');
        disp(lasterr);
    end
    aa_checkinAppData(guifig, 'acqdisplaydata', ddd);
    cla(handles.axesAudio);
    cla(handles.axesSignal);
    cla(handles.axesSignal2);
    cla(handles.axesSignal3);
end
