%% Input
GeneralOutFolder='/Users/gushijie/Documents/Fee/';
Bird='6122';                                                    %(1st input)
DataFolder='/Volumes/data0-shared/elm/Inscopix/051917_5140F/';  %(2nd input)
SleepStart=['19 May 2017 06:30 PM'; '19 May 2017 08:20 PM'];%(3rd input)
SleepEnd=['19 May 2017 08:00 PM'; '20 May 2017 01:00 AM']; %(3rd input)
SleepStartTime = datenum(SleepStart);
SleepEndTime = datenum(SleepEnd);
VIDEOfs=30;
%GeneralOutFolder=DataFolder;

outputFolder=fullfile(GeneralOutFolder,Bird,filesep);
if ~exist(outputFolder)
    mkdir(GeneralOutFolder,Bird)
end

Fls=dir(strcat(DataFolder,'*tif'));
Data2keep=[];
Y=[];
TIMESTAMP=[];

for i = 16:length(Fls)
    RecordingEnd = Fls(i).datenum;
    RecordingStart = datenum(Fls(i).name(11:25),'yyyymmdd_HHMMSS');

    if any(and(and(RecordingStart>SleepStartTime,RecordingStart<SleepEndTime),and(RecordingEnd>SleepStartTime,RecordingEnd<SleepEndTime)))
        try
        Data2keep=[Data2keep; Fls(i).name]; % NumberOfSeconds1=etime(datevec(SleepEndTime(indSTART)),datevec(RecordingStart)); % in seconds            
        tiffInfo = imfinfo(fullfile(DataFolder,Fls(i).name)); 
        nFrames = numel(tiffInfo);
        VIDEO = zeros(ceil(tiffInfo(1).Height/3.6),ceil(tiffInfo(1).Width/3.6),nFrames); % 300x400 pixel version (maintains aspect ratio of original 1080x1440 video)
        for framei = 1:nFrames
            bigframe = imread(fullfile(DataFolder,Fls(i).name), framei, 'info', tiffInfo);
            VIDEO(:,:,framei) = imresize(imgaussfilt(bigframe, 3.6),1/3.6); % smaller smoothed version
        end
        timestamp=datestr(linspace(RecordingStart,RecordingEnd,nFrames),'yyyymmdd HHMMSS');
        timestamp=str2num(timestamp);
        filename = fullfile(outputFolder, ['Sleep_' Bird '-' datestr(Fls(i).name(11:25),'ddmmmyyyy-HH:MM:SS') '-' datestr(Fls(i).datenum,'HH:MM:SS')]); 
        tic;
        save(filename, 'VIDEOfs','VIDEO','nFrames','timestamp','-v7.3'); toc;
        display(['small file saved, saving took ' num2str(toc) ' sec'])
        catch exception
        display(['ERROR File' num2str(i)])
        msgText = getReport(exception)
        end
        Y = cat(3,Y,VIDEO);
        TIMESTAMP=[TIMESTAMP;timestamp];              
    end
end
% Write down what files are used in sleep analysis
logtable=struct2table(Data2keep);
logtable.Properties.Description='data during sleep';
writetable(logtable,fullfile(DataFolder,'data_during_sleep.txt'));

% Save compiled big data
FILENAME = fullfile(outputFolder, ['Sleep_' Bird '-' datestr(Fls(1).name(11:25),'ddmmmyyyy-HH:MM:SS') '-' datestr(Fls(end).datenum,'HH:MM:SS')]); 
tic;
save(FILENAME, 'VIDEOfs','Y','TIMESTAMP','-v7.3'); toc;
display(['full file saved, saving took ' num2str(toc) ' sec'])
display('done processing video data')

% Write log file
WRITEPATH = 'GeneralOutFolder';
fid=fopen('SleepCalciumTable.csv', 'at'); %append as text
fprintf(fid,['\n',Bird,',',DataFolder,',',SleepStart(1,:),',',SleepEnd(end,:)])
fclose(fid);

