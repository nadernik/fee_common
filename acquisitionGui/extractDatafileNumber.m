function num = extractDatafileNumber(exper, name)
%Extract the datafile number from the datafile name.

name = name(length(exper.birdname) + length('_d') + 1:end);
ndx = strfind(name,'_');
name = name(1:ndx(1)-1);
num = str2num(name);
