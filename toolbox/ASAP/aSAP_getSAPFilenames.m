function [filenames,path,fullfilenames] = aSAP_getSAPFilenames(birdId, dateDir, ext, startTime, endTime, rootDir)
%get files in a period sorted by creation time.


filenames = {};
fullfilenames = {};

if(~exist(ext))
    ext = 'wav';
end
if(~exist('rootDir'))
    rootDir = 'C:\aarecordings';
end
if(~exist('startTime'))
    startTime = -Inf;
end
if(~exist('endTime'))
    endTime = -Inf;
end

path = [rootDir, filesep, birdId, filesep, dateDir];
d = dir([path,filesep,'*.',ext]);

[year,month,day,junk] = datevec(aSAP_SAPDateDir2Date(str2num(dateDir)));

if(length(d)>0)
    [fileName{1:length(d)}] = deal(d.name);
    for(nFile = 1:length(fileName))
        time(nFile) = aSAP_extractTimeFromSAPFileName(fileName{nFile});
    end
    
    %Sort files by time created.
    [time, sortndx] = sort(time);
    fileName = fileName(sortndx);
    
    %handle various formats for inputing starttime: datenum, [hour], [hour, min], [hour, min, sec], datevec. 
    if(length(startTime) == 1 & startTime < 25)
        dnStartTime = datenum([year, month, day, startTime, 0, 0]);
    elseif(length(startTime) == 2)
        dnStartTime = datenum([year, month, day, startTime(1), startTime(2), 0]);
    elseif(length(startTime) == 3)
        dnStartTime = datenum([year, month, day, startTime(1), startTime(2), startTime(3)]);
    elseif(length(startTime) == 6)
        dnStartTime = datenum(startTime);
    elseif(startTime < 700000)
        dnStartTime = aSAP_wintime2dn(startTime);
    else
        dnStartTime = startTime;
    end
    
    %handle various formats for inputing starttime: datenum, [hour], [hour, min], [hour, min, sec], datevec.     
    if(length(endTime) == 1 & endTime < 25)
        dnEndTime = datenum([year, month, day, endTime, 0, 0]);
    elseif(length(endTime) == 2)
        dnEndTime = datenum([year, month, day, endTime(1), endTime(2), 0]);
    elseif(length(endTime) == 3)
        dnEndTime = datenum([year, month, day, endTime(1), endTime(2), endTime(3)]);
    elseif(length(endTime) == 6)
        dnEndTime = datenum(endTime);
    elseif(endTime < 700000)
        dnEndTime = aSAP_wintime2dn(endTime);
    else
        dnEndTime = endTime;
    end
    
    %Get the indices of the files that meet the criteria.
    validFileNdx = find((time>dnStartTime) & (time<dnEndTime));
    filenames = fileName(validFileNdx);
    for(nFile = 1:length(filenames))
        fullfilenames{nFile} = [path,filesep,filenames{nFile}];
    end
end
