function daq_Quit
%Quit the data acquisition toolbox.

global GAI
global GAO

ai = GAI;
ao = GAO;
stop([ai,ao]);

%clean up
delete(ai);
clear ai;
delete(ao);
clear ao;