function daq_Quit
%Quit the data acquisition toolbox.

global GS
s = GS;
stop(s);
daq_deleteListeners();
delete(s);
clear s;
daq.reset;
%clean up