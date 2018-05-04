function time = extractExperFilenumTime(exper,filenum)

ch = exper.audioCh;
filename = getExperDatafile(exper,filenum, ch);
time = extractTimeFromFilename(exper, filename);

