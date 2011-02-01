%Nightly Batch

%Get current date directory
dateDir = aSAP_getDate2SAPDateDir(now-1);
rootDir = '\\Sambafinch\andalman\SAPRecordings';
birdList = {'temp005', 'temp006', 'temp007' }
nonSongDir = '\\Sambafinch\andalman\garbageNonSongFiles';
bSingingSubsong = false;  

%overnight script

%PART 1: Move non-song files:
if(bSingingSubsong)
    songDuration = .2;
    thresDuration = .5;
    thresRatio = 2;
else
    songDuration = .6;
    thresDuration = .5;
    thresRatio = 2.5;
end
minSongFreq = 1000;
maxSongFreq = 7000;
bDebug = false;
for(birdIdCell = birdList)
    birdId = birdIdCell{1};
    songDir = [rootDir, filesep, birdId, filesep, dateDir];
    [bSong, scores, fileInfo] = moveNonSongFiles(songDir, nonSongDir, songDuration, thresDuration, thresRatio, minSongFreq, maxSongFreq, false);
end

%PART 2: Generate raw audio prints
for(birdIdCell = birdList);
    birdId = birdIdCell{1};
    [f,p] = aSAP_getSAPFilenames(birdId,dateDir,'wav',.01,23.99,rootDir);
    rawDir = ['c:\aadata\rawsongsumm\',birdId,filesep,'audio-',birdId,'-',dateDir];
    mkdir(rawDir);
    aSAP_printAudio(f,p,rawDir);
    clf
end

%PART 3
for(birdIdCell = birdList);
    birdId = birdIdCell{1};
    [fileSumm,sylls,bouts] = getRawBoutAndSyllSummaryForPeriod(birdId, dateDir, .01, 23.99, rootDir);
    save([rootDir,filesep,birdId,filesep,birdId,'-',dateDir,'-fileSumm.mat'], 'fileSumm');
    save([rootDir,filesep,birdId,filesep,birdId,'-',dateDir,'-sylls.mat'], 'sylls');
    save([rootDir,filesep,birdId,filesep,birdId,'-',dateDir,'-bouts.mat'], 'bouts');
end

%Generate features...
for(birdIdCell = birdList)
    birdId = birdIdCell{1};
    load([rootDir,filesep,birdId,filesep,birdId,'-',dateDir,'-fileSumm.mat']);
    
    numFiles = length(fileSumm.fileinfo);
    for(nFile = 1:numFiles)
        if(~strcmp(fileSumm.fileinfo(nFile).filepath,''))
            filename = [fileSumm.fileinfo(nFile).filepath, filesep, fileSumm.fileinfo(nFile).filename];
        else
            filename = fileSumm.fileinfo(nFile).filename;
        end
        if(length(fileSumm.fileinfo(nFile).rawBoutStartSyll) >= 1)
            aSAP_generateASAPFeatureFileFromWav(filename);            
        end
        disp([num2str(nFile),'/',num2str(numFiles), ' : ', filename]);        
    end
end

exit;
