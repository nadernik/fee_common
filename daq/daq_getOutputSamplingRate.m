function rate = daq_getOutputSamplingRate()

%Return the current output sampling rate;

global GAO
rate = get(GAO,'SampleRate');