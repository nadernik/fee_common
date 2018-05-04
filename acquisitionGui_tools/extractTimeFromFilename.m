function time = extractTimeFromFilename(exper, filename)

filetimestr = extractDatafileTime(exper,filename);
time = convertExperTimeStr2MatlabTime(filetimestr);