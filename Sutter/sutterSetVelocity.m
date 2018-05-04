function [Status] = sutterSetVelocity(s, vel, bFine)
%The conversion from microsteps is a mystery using the FEE modified
%controller.  The microns given are approximate to within a few microns,
%assuming you are using the old english system threaded rod.  Otherwise
%the units are dependant to the type of threaded rod used.

%Vel:  the number of microsteps per sec the sutter should move.  The size
%of a microstep depends on whether the resolution is set to fine or course.
%Note: the current position of the sutter is always returned in fine
%microsteps.

%bFine (is the resolution, otherwise course.
if(~exist('bFine'))
    bFine = true;
end

if(~exist('vel'))
    vel = 1500; %This correspondes to approximately to 5um in 200ms.
end

try
    sutterFlush(s);    
	if bFine
		vel=bitor(2^15,vel);
    end
    fprintf(s, 'V'); %send the current position command.
    fwrite(s, vel, 'uint16');
    fprintf(s,'\n');
    %Same thing different style:
  	%fwrite(state.motor.serialPortHandle, 'V');
	%fwrite(state.motor.serialPortHandle, vel, 'uint16');
	%fwrite(state.motor.serialPortHandle, 13);    
    pause(.05);
    fread(s,3); %read the response.
    Status = 1;
catch
    e = lasterror;
    w = lastwarn;
    disp(['sutterSetCurrentPosition: lasterr:', e.message, ' lastwarn:',w]);
    Status = 0;
end
