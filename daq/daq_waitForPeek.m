function daq_waitForPeek()
%Wait for current peek to complete.

global NPEEK;
DELAY = 0.05;

randId = randi(1000);
fprintf('Entering peek %d\n', randId);
if(daq_isUpdating)
    error('daq_waitForPeek function has interrupted daq_bufferUpdate.  This must be prevented.');
end

n = 0;
peekTic = tic();
while(NPEEK ~= 0)
    pause(DELAY); 
    n = n + 1;
    fprintf('peek %d has paused for a total of %fs\n', randId, n * DELAY);
    if(n == 100) %timeout: n = 100 => timeout = 5 seconds
        peekTime = toc(peekTic);
        fprintf('peek %d timeout after %f\n', randId, peekTime);
        keyboard
        daq_Quit();
        error('peek failed');
    end
end
fprintf('Exiting peek %d\n', randId);
end