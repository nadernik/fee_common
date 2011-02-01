function [fileSumm, sylls, bouts] = getRawBoutAndSyllSummaryForPeriod(birdId, dateDir, startTime, endTime, rootDir)

if(~exist('rootDir'))
    rootDir = '\\Sambafinch\andalman\SAPRecordings';
end
if(~exist('startTime'))
    startTime = -Inf;
end
if(~exist('endTime'))
    endTime = -Inf;
end

%getFilesInPeriod
[wavfilenames,path] = aSAP_getSAPFilenames(birdId, dateDir, 'wav', startTime, endTime, rootDir);
[fileSumm, sylls, bouts] = getRawBoutAndSyllSummaryForWavFiles(wavfilenames, path);


