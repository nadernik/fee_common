function rate = daq_getOutputSamplingRate()

%Return the current output sampling rate;

global GS
rate = GS.Rate;