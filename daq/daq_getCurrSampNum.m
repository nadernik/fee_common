function currSampNum = daq_getCurrSampNum()
%Returns the sample number of the most recent sample transferred to the
%buffer.

%The first sample recorded after daq_Start is number 1.

global BUFFERUNITSIZE
global NUMBUFFERUNITS

currSampNum = BUFFERUNITSIZE * NUMBUFFERUNITS;

