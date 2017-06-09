%% Input from lab notebook and specify where to save
function Compile_Sleep_GcampData(GeneralOutFolder, Bird, DataFolder, SleepStart, SleepEnd)
%% Just let it run, it will save each tiff as matfile if it is within sleep range.
   % Meanwhile, it compiled all the qualified tiffs into one big mat file.
   % MAT file convention follows singsing data. 
   % Small data has VIDEO(t*300*400), Big data has Y(300*400*T).
   
VIDEOfs=30;                                             %(4th input if data aqui change)

SleepStartTime = datenum(SleepStart);
SleepEndTime = datenum(SleepEnd);

outputFolder=fullfile(GeneralOutFolder,Bird,filesep);
if ~exist(outputFolder)
    mkdir(GeneralOutFolder,Bird)
end

Fls=dir(strcat(DataFolder,'*tif'));
Data2keep=[];
Y=[];
TIMESTAMP=[];

for i = 1:length(Fls)
    RecordingEnd = Fls(i).datenum;
    RecordingStart = datenum(Fls(i).name(11:25),'yyyymmdd_HHMMSS');
    display(['Working on file ' Fls(i).name])
    if any(and(and(RecordingStart>SleepStartTime,RecordingStart<SleepEndTime),and(RecordingEnd>SleepStartTime,RecordingEnd<SleepEndTime)))
        try
        Data2keep=[Data2keep; Fls(i)]; % NumberOfSeconds1=etime(datevec(SleepEndTime(indSTART)),datevec(RecordingStart)); % in seconds            
        tiffInfo = imfinfo(fullfile(DataFolder,Fls(i).name)); 
        nFrames = numel(tiffInfo);
        VIDEO = zeros(nFrames,ceil(tiffInfo(1).Height/3.6),ceil(tiffInfo(1).Width/3.6)); % 300x400 pixel version (maintains aspect ratio of original 1080x1440 video)
        for framei = 1:nFrames
            bigframe = imread(fullfile(DataFolder,Fls(i).name), framei, 'info', tiffInfo);
            VIDEO(framei,:,:) = imresize(imgaussfilt(bigframe, 3.6),1/3.6); % smaller smoothed version
        end
        timestamp=datestr(linspace(RecordingStart,RecordingEnd,nFrames));
        filename = fullfile(outputFolder, ['Sleep_' Bird '_' ,datestr(RecordingStart,'ddmmmyyyyHHMMSS'), '_' datestr(RecordingEnd,'HHMMSS')]); 
        tic;
        save(filename, 'VIDEOfs','VIDEO','nFrames','timestamp','-v7.3'); toc;
        display(['small file saved, saving took ' num2str(toc) ' sec'])
        catch exception
        display(['ERROR File' num2str(i)])
        msgText = getReport(exception)
        end
        VIDEO=permute(VIDEO,[2 3 1]);
        Y = cat(3,Y,VIDEO);
        TIMESTAMP=[TIMESTAMP;timestamp];              
    end
    display(['Done with file ' Fls(i).name])
end
% Write down what files are used in sleep analysis
logtable=struct2table(Data2keep);
logtable.Properties.Description='data during sleep';
writetable(logtable,fullfile(DataFolder,'data_during_sleep.txt'));

% Save compiled big data
FILENAME = fullfile(outputFolder, ['CompiledSleep_' Bird '_' Fls(1).name(11:25), '-' datestr(Fls(end).date,'yyyymmdd_HHMMSS')]); 
tic;
save(FILENAME, 'VIDEOfs','Y','TIMESTAMP', 'GeneralOutFolder', 'Bird', 'DataFolder', 'SleepStart', 'SleepEnd', '-v7.3'); toc;
display(['full file saved, saving took ' num2str(toc) ' sec'])
display('done processing video data')
% Write log excel(csv)
% fid=fopen(fullfile(GeneralOutFolder,'SleepCalciumTable.csv'), 'at'); %append as text
% %DataFolderSafe=strrep(DataFolder,'\','\\');
% fprintf(fid,['\n',Bird,',',DataFolder,',',SleepStart(1,:),',',SleepEnd(end,:)],'char')
% fclose(fid);
end
