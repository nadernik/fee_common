function rate = daq_getInputSamplingRate()

%Return the current input sampling rate;

global GAI
rate = get(GAI,'SampleRate');