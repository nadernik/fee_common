function daq_log(str)

global DAQLOGFILENAME;
global DAQLOGFID;

if(DAQLOGFID > -1)
    stack = dbstack;
    fprintf(DAQLOGFID, [datestr(now),' : ', stack(2).name, ' : ', str, '\n']);
end