function bUpdating = daq_isUpdating
%The function returns whether the execution of daq_bufferUpdate has been
%interrupted.
%Interruption of the daq_bufferUpdate function by certain callbacks and
%timer function can cause freezes and crashes.  This function can be used
%to prevent these types of errors. 

%Crashes occur when timers or callbacks that wait on specific daq
%acquisition event are invoked such that they interrupt the daq function 
%that causes the event to arrive or occur.  The timer or callback therefore waits
%forever and a crash insues.  This function allows timers and callbacks to
%check that they haven't interrupted an important daq_function.

st = dbstack;
bUpdating = false;
for(i=1:length(st))
    if(strcmp(st(i).name,'daq_bufferUpdate') || strcmp(st(i).name,'analoginput'))
        bUpdating = true;
        return;
    end
end