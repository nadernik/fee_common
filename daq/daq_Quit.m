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
    try
        daq_deleteListeners();
        delete(s);
    catch err
        warning(err.message);
    end
    %% Try to close files
    %Data files (trigger files)
    for fNo = 1:numel(TRIGGERFID)
        try
            fclose(TRIGGERFID(fNo));
        catch err
            switch err.identifier
                case 'MATLAB:badfid_mx'
                otherwise
                    warning(err.message);
            end
        end
    end
    try
        fclose(DAQLOGFID);
    catch err
        switch err.identifier
            case 'MATLAB:badfid_mx'
            otherwise
                warning(err.message);
        end
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