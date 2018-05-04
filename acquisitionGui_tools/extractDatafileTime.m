function strTimeCreated = extractDatafileTime(junk, filename)

[junk, sndx] = regexp(filename, '_d\d\d\d\d\d\d_');
endx = regexp(filename, 'chan\d');
strTimeCreated = filename(sndx(end)+1:endx(end)-1);
