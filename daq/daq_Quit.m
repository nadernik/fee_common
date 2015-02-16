function daq_Quit()
%Quit the data acquisition toolbox.

%information globals
global GS;
global GINCHANS;
global GOUTCHANS;
global COUNT;
global NUMBUFFERUNITS;
global GLISTENERS;

%buffer related globals
global BUFFERUNITSIZE;
global GDAQDATA;
global GDAQTIME;
global BTRIGGER;
global NPEEK;

%logging related globals
global DAQLOGFILENAME;
global DAQLOGFID;

%Triggering variables
global BTRIGGER;
global TRIGGERFILENAME;
global TRIGGERSTART;
global TRIGGEREND;
global TRIGGERFID;

%Peek variables
global PEEKDATASTORE;
global PEEKTIMESTORE;

if isempty(GS) %session has not been created
    daq.reset;
else %session is open, need to clean up
    %% Stop session and clear listeners
    s = GS;
    stop(s);
    daq_deleteListeners();
    delete(s);
    %% Try to close files
    %Data files (trigger files)
    for fNo = 1:numel(TRIGGERFID)
        try
            flcose(TRIGGERFID(fNo));
        catch err
        end
    end
    try
        flcose(DAQLOGFID);
    catch err
    end
    %% Clear global variables
    clearvars('-global', 'GS', 'GINCHANS', 'GOUTCHANS', 'COUNT',...
        'NUMBUFFERUNITS', 'GLISTENERS', 'BUFFERUNITSIZE', 'GDAQDATA',...
        'GDAQTIME', 'BTRIGGER', 'NPEEK', 'DAQLOGFILENAME', 'DAQLOGFID',...
        'BTRIGGER', 'TRIGGERFILENAME', 'TRIGGERSTART', 'TRIGGEREND', ...
        'TRIGGERFID', 'PEEKDATASTORE', 'PEEKTIMESTORE');
    %% Clear memory of all DAQ related files, release hardware
    daq.reset;
end
%clean up