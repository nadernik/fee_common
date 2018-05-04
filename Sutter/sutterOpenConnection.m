function [s, Status] = sutterOpenConnection()
try
    %Close and clear any old connections.
    instrs = instrfind('Port','COM1');
    if(~isempty(instrs))
        fclose(instrs);
        delete(instrs);
    end

    %Open a new connection.
    s = serial('COM1');
    s.BaudRate = 9600;
    s.DataBits = 8;
    s.StopBits = 1;
    s.parity = 'none';
    s.Terminator = 'CR'; %equivalent to 13, vs Line Feed LF == 10.

    fopen(s);
    %test connection...
    [microsteps, micronsApprox, Status] = sutterGetCurrentPosition(s);
catch
    Status = 0;
end