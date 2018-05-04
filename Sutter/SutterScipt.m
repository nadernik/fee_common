%Put sutter on 9600 baud.


%% OPEN CONNECTION WITH SUTTER
s = serial('COM1');
s.BaudRate = 9600;
s.DataBits = 8
s.StopBits = 1;
s.parity = 'none';
s.Terminator = 'CR'; %equivalent to 13, vs Line Feed LF == 10.
fopen(s);

%% Test connection.
%Request current position relative to home, not origin... these are
%different
fprintf(s, 'c\n');
out = fread(s,3,'int32'), fread(s,2);
% out is not microsteps, which not precisely accurate with microdisplay...
%The approximate conversion is 
micron = (out/60 * 1.0171);
micron2 = out/60 * 1.02 + mod(out/20,3)*.4;
%This has more errors near 0, and very far from zero, but is within a
%micron or 2, between 100um and 5000um.

%% more to origin
fprintf(s, 'o\n');
fread(s,2);

%% Close
fclose(s);