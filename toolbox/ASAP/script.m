%Get current date directory
dateDir = aSAP_getDate2SAPDateDir(now-1);

%overnight script for 2/13/2006
%Segment Syllables...
for(birdIdCell = {'aa120'});
    for(dateNum = 424:-1:422)
        dateDir = num2str(dateNum);
        birdId = birdIdCell{1};
        [fileSumm,sylls,bouts] = getRawBoutAndSyllSummaryForPeriod(birdId, dateDir, 1, 23, 'c:\aarecordings');
        save(['//Sambafinch/andalman/SAPRecordings/',birdId,'/',birdId,'-',dateDir,'-fileSumm.mat'], 'fileSumm');
        save(['//Sambafinch/andalman/SAPRecordings/',birdId,'/',birdId,'-',dateDir,'-sylls.mat'], 'sylls');
        save(['//Sambafinch/andalman/SAPRecordings/',birdId,'/',birdId,'-',dateDir,'-bouts.mat'], 'bouts');
        clear sylls;
        clear bouts;
        
        numFiles = length(fileSumm.fileinfo);
        for(nFile = 1:numFiles)
            if(length(fileSumm.fileinfo(nFile).rawBoutStartSyll)>0)
                if(~strcmp(fileSumm.fileinfo(nFile).filepath,''))
                    filename = [fileSumm.fileinfo(nFile).filepath, filesep, fileSumm.fileinfo(nFile).filename];
                else
                    filename = fileSumm.fileinfo(nFile).filename;
                end
                [spath,sname,sext] = fileparts(filename);
                featfilename = [spath,filesep,sname,'.feat','.mat'];
                d = dir(featfilename);
                if(length(d)==0)
                    try
                        aSAP_generateASAPFeatureFileFromWav(filename);
                    end
                end
                disp([num2str(nFile),'/',num2str(numFiles), ' : ', filename]);
            end
        end                
    end
end

    


