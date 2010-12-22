function chan = extractDatafileChannel(exper,filename)

name = filename(length(exper.birdname) + length('_d') + 27:end);
ndx = strfind(name,'.dat');
chan = str2num(name(1:ndx(1)-1));