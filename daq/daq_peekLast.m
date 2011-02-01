function [data,time,startSamp] = daq_peekLast(nSamps)
%Copy the last nSamps samples from the buffer, and return them for use
%in the matlab.

nStartSamp = daq_getCurrSampNum - nSamps;
[data, time] = daq_peek(nStartSamp);

%chop off extra samples from the beginning and adjust startSamp accordingly.
startSamp = nStartSamp + length(time) - nSamps;
data = data(end-nSamps+1:end,:);
time = time(end-nSamps+1:end);

