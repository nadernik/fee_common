function rate = daq_getInputSamplingRate()

%Return the current input sampling rate;

global GS
rate = GS.Rate;