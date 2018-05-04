function [microsteps, micronsApprox, Status] = sutterGetCurrentPosition(s)
%The conversion from microsteps is a mystery using the FEE modified
%controller.  The microns given are approximate to within a few microns,
%assuming you are using the old english system threaded rod.  Otherwise
%the units are dependant to the type of threaded rod used.

try
    fprintf(s, 'c\n'); %send the current position command.
    pause(.05);
    microsteps = fread(s,3,'int32');
    if(length(microsteps)~=3)
        error('Sutter connection malfunctioning');
    end
    fread(s,2); %read the response.
    micronsApprox = (microsteps/60 * 1.0171);
    Status = 1;
catch
    microsteps = [];
    micronsApprox = [];
    e = lasterror;
    w = lastwarn;
    disp(['sutterGetCurrentPosition: lasterr:', e.message, ' lastwarn:',w]);
    Status = 0;
end

%Go To Position
%command ‘m’xxxxyyyyzzzzCR 06Dh + three signed long integers + 0Dh
%returns CR 0Dh
