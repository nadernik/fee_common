function daqgui_restartGUI(obj, event, guifig)
%Callback function that invokes acquisition with Stim.

if(daq_isUpdating)
    return;
end

handles = guidata(guifig);
dgd = aa_getAppDataReadOnly(guifig, 'daqguidata');
params = aa_getAppDataReadOnly(guifig, 'paramsTrigOnSong');

if(~isempty(timerfind('Name','trigOnSong')))
    if(params.isRecordingSong)
        return;
    end
    stop(timerfind('Name','trigOnSong'));
    delete(timerfind('Name','trigOnSong'));
end
daqreset;

%stop the restart-timer from trying to restart.  The deed is done.
stop(obj);
delete(obj);

%extract info needed for restart.
exper = dgd.exper;
logfile = dgd.logfile;
songDensity = str2double(get(handles.editSongDensity, 'String'));
powerThres = str2double(get(handles.editPowerThres, 'String'));
songLength = str2double(get(handles.editSongLength, 'String'));
startHour = str2double(get(handles.editStartTime, 'String'));
stopHour = str2double(get(handles.editStopTime, 'String'));

%close the gui.
close(guifig);
daqreset;

%can't pause here, can't just wait, because timers are stop and deleted
%asynchronously.  Not sure why matlab does that.
n = now;
[y, mn, d, h, m, s] = datevec(n);
if(startHour >((n-floor(n))*24))
    startTime = datenum(y,mn,d,startHour,0,0);
else
    startTime = datenum(y,mn,d+1,startHour,0,0);
end

t_startExper = timer;
set(t_startExper, 'Name', 'daqguiStartExperHelper');
set(t_startExper,'TimerFcn',{@startExperHelper, exper, logfile, songDensity, songLength, powerThres, startHour, stopHour});
set(t_startExper,'ExecutionMode','singleShot');
set(t_startExper,'BusyMode', 'queue');
startat( t_startExper, startTime);

function startExperHelper(obj, event, exper, logfile, songDensity, songLength, powerThres, startHour, stopHour)
%create new days exper and restart gui.
rootndx = strfind(exper.dir,exper.birdname);
rootdir = exper.dir(1:rootndx-2);
exper = createExperAuto(rootdir, exper.birdname, datestr(now,29), exper.desiredInSampRate, exper.audioCh, exper.sigCh);
experAcquistionGui('logfile', logfile, 'exper', exper, ...
                    'songDensity', songDensity, 'songLength', songLength, ...
                    'powerThres', powerThres, 'startTrigOnSong', true, ...
                    'bRestartInMorning', true, 'startHour', startHour, 'stopHour', stopHour);