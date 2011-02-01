function bRecording = daq_isRecording(channel)
%Returns true if recording is currently taking place on specified hardware
%channel.

global BTRIGGER;
global GINCHANS;

matchannel = find(GINCHANS == channel);

bRecording = BTRIGGER(matchannel);
