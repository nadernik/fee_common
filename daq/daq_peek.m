function [data,time,startSamp] = daq_peek(startSamp)
%Copy a window of data from the buffer for use in matlab.  
%The window begins at sample number startSamp, and ends with the most
%recently recorded sample.

%Use daq_getCurrSampNum to get the number of the most recent sample added
%to the buffer.

global NPEEK;
NPEEK = startSamp;
daq_waitForPeek;

global PEEKDATASTORE;
global PEEKTIMESTORE;
data = PEEKDATASTORE;
time = PEEKTIMESTORE;