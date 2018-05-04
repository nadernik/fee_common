function sutterGetDetailedStatus(s)
%The conversion from microsteps is a mystery using the FEE modified
%controller.  The microns given are approximate to within a few microns,
%assuming you are using the old english system threaded rod.  Otherwise
%the units are dependant to the type of threaded rod used.

try
    sutterFlush(s);
    
    fprintf(s, 's\n'); %send the current position command.
    flags = fread(s,1,'uint8')
    udirx = fread(s,1,'uint8')
    udiry = fread(s,1,'uint8')
    udirz = fread(s,1,'uint8')
    
    cont_ustepPerClick = fread(s,1,'uint16')
    offset = fread(s,1,'uint16')
    range = fread(s,1,'uint16')
    pulse_ustepPerPulse = fread(s,1,'uint16')
    pulse_ustepPerSec = fread(s,1,'uint16')
    
    indevice = fread(s,1,'uint8')
    flags2 = fread(s,1,'uint8')
    
    fread(s,1,'uint16')
    fread(s,1,'uint16')
    fread(s,1,'uint16')
    fread(s,1,'uint16')
    step_div = fread(s,1,'uint16')
    step_mul = fread(s,1,'uint16')
    xspeed = fread(s,1,'uint16')
    firmwarever = fread(s,1,'uint16')
    
    fread(s,2); %read the response.
catch
    e = lasterror;
    w = lastwarn;
    disp(['sutterSetCurrentPosition: lasterr:', e.message, ' lastwarn:',w]);
    Status = 0;
end

