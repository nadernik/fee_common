function daq_qmoredata(obj, event, ai, outputSig)
%Internal function.  Should not be called explicitly.

%Callback function necessary for the continuous and constant output of a signal.  
%Used by daq_StartConstOutput.

global COUNT;

putdata(obj,outputSig);
COUNT = COUNT +1;