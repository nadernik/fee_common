function daq_waitForPeek()
%Wait for current peek to complete.

global NPEEK;

if(daq_isUpdating)
    error('daq_waitForPeek function has interrupted daq_bufferUpdate.  This must be prevented.');
end

n = 0;
while(NPEEK ~= 0)
    pause(.05); 
    n = n + 1;
    if(n == 100)
        daqreset;
        error('peek failed');
    end
end