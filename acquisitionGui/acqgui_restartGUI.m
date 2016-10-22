function status = acqgui_restartGUI(obj, ~, guifig, startTime, bBatch)
%Initiates a acquisition restart, and runs any overnight batch
%programs.  Typically invoked by a restartTimer, but can be called
%directly for forced restart.

status = false;

if(daq_isUpdating)
    %the restart timer will try again in 5 seconds.
    return;
end

handles = guidata(guifig);
startHour = str2double(get(handles.editStartTime, 'String'));
stopHour = str2double(get(handles.editStopTime, 'String'));
tsd = getappdata(guifig,'threadSafeData');
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
[recinfo, status] = aa_checkoutAppData(guifig, 'acqrecordinfo');
if ~status
    %the restart timer will try again in 5 seconds.
    return;
end

if ~isempty(timerfind('Name','trigOnSong'))
    if any([recinfo.bSongTrigRecording] | [recinfo.bForcedRecording])
        %the restart timer will try again in 5 seconds.
        aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
        return;
    end
    stop(timerfind('Name','trigOnSong'));
    delete(timerfind('Name','trigOnSong'));
end
delete(dgd.DaqBuffer);
aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);

%stop the restart-timer from trying to restart.  The deed is done.
if(~isempty(obj))
    stop(obj);
    delete(obj);
end
status = true;

%close the gui.
close(guifig);
daq_Quit();

%can't pause here, can't just wait, because timers are stopped and deleted
%asynchronously.  Not sure why matlab does that.
if ~exist('startTime', 'var')
    n = now;
    [y, mn, d] = datevec(n);
    if startHour > (n - floor(n)) * 24
        startTime = datenum(y, mn, d, startHour, 0,0);
    else
        startTime = datenum(y, mn, d+1, startHour, 0,0);
    end
end

nExper = numel(dgd.expers);
dispChanAudio = nan(nExper, 1);
dispChan = nan(nExper, 1);
dispChan2 = nan(nExper, 1);
dispChan3 = nan(nExper, 1);
songDetection = emptystruct('songDensity', 'powerThres', 'songLength', 'minFreq', 'maxFreq', [nExper, 1]);

for experNo = 1:nExper
    songDetection(experNo).songDensity = dgd.experData(experNo).songDetection.durationThreshold;
    songDetection(experNo).powerThres = dgd.experData(experNo).songDetection.ratioThreshold;
    songDetection(experNo).songLength = dgd.experData(experNo).songDetection.songDuration;
    songDetection(experNo).minFreq = dgd.experData(experNo).songDetection.minFreq;
    songDetection(experNo).maxFreq = dgd.experData(experNo).songDetection.maxFreq;
    dispChanAudio(experNo) = dgd.experData(experNo).dddbackground.dispchanAudio;
    dispChan(experNo) = dgd.experData(experNo).dddbackground.dispchan;
    dispChan2(experNo) = dgd.experData(experNo).dddbackground.dispchan2;
    dispChan3(experNo) = dgd.experData(experNo).dddbackground.dispchan3;
end

t_startExper = timer;
set(t_startExper, 'Name', 'acqguiStartExperHelper');
set(t_startExper,'TimerFcn',{@startExperHelper, dgd.bTrigOnSong, ...
                                                dgd.expers, ...
                                                dgd.logfile, ...
                                                dispChanAudio, ...
                                                dispChan, ...
                                                dispChan2, ...
                                                dispChan3, ...
                                                songDetection, ...
                                                startHour, ...
                                                stopHour, ...
                                                tsd});
set(t_startExper,'ExecutionMode','singleShot');
set(t_startExper,'BusyMode', 'queue');
startat(t_startExper, startTime);

if ~exist('bBatch','var') || bBatch
    try
        acqgui_overnightBatch(dgd.expers);
    catch ME
        warning(['Overnight batch failed: ', ME.message]);
    end
end
end

function startExperHelper(~, ~, bTrigOnSong, cexpers, logfile, dispchanAudio, dispchan, dispchan2, dispchan3, songDetection, startHour, stopHour, tsd)
%create new days exper and restart gui.
try
    for nExper = 1:length(cexpers)
        rootndx = strfind(cexpers{nExper}.dir,cexpers{nExper}.birdname);
        rootdir = cexpers{nExper}.dir(1:rootndx-2);
        expers(nExper) = createExperAuto(rootdir, cexpers{nExper}.birdname, datestr(now,29), cexpers{nExper}.desiredInSampRate, cexpers{nExper}.audioCh, cexpers{nExper}.sigCh);
    end
catch ME
    disp(['Could not create experiments: ', ME.message]);
end
try
    acquisitionGui('bTrigOnSong', bTrigOnSong, ...
                   'logfile', logfile, ...
                   'expers', expers, ...
                   'dispchanAudio', dispchanAudio, ...
                   'dispchan', dispchan, ...
                   'dispchan2', dispchan2, ...
                   'dispchan3', dispchan3, ...
                   'songDetection', songDetection, ...
                   'bRestartInMorning', true, ...
                   'startHour', startHour, ...
                   'stopHour', stopHour, ...
                   'threadSafeData', tsd);
catch ME
    disp(['Could not restart acquisitionGui: ', ME.message]);
    disp(getReport(ME));
end
end