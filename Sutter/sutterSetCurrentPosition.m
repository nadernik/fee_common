function [Status] = sutterSetCurrentPosition(s, micronsApprox)
%The conversion from microsteps is a mystery using the FEE modified
%controller.  The microns given are approximate to within a few microns,
%assuming you are using the old english system threaded rod.  Otherwise
%the units are dependant to the type of threaded rod used.

try
    microsteps = round(micronsApprox / 1.0171 * 60);
    microsteps = 20*round(microsteps/20);
    fprintf(s, 'm'); %send the current position command.
    fwrite(s, microsteps, 'int32');
    fprintf(s,'\n');
    pause(5);
    fread(s,2); %read the response.
    Status = 1;
catch
    e = lasterror;
    w = lastwarn;
    disp(['sutterSetCurrentPosition: lasterr:', e.message, ' lastwarn:',w]);
    Status = 0;
end

%Go To Position
%command ‘m’xxxxyyyyzzzzCR 06Dh + three signed long integers + 0Dh
%returns CR 0Dh
