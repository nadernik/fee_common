%% load CalciumData spreadsheet

XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/CalciumData.xlsx');
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
Columns = XLS.textdata.Sheet1(1,:);

% decide where to save stuff
savedir = 'E:\ProcessedCalciumData'; %'Z:\emackev\inscopix'; 'C:\Users\emackev\Documents\StuffICanDelete';
%% to populate xls...
DIR1 = dir(fullfile('Z:\emackev\UnprocessedCalciumData\HVCOpto\2016-07-22', '*chan0.dat'))
DIR = dir(fullfile('Z:\emackev\UnprocessedCalciumData\HVCgcamp07222016', '*.tif'))
DIR = DIR(cellfun(@numel,(regexp( {DIR.name}', 'recording_\d+_\d+.tif')))==1);
{DIR.name}'
%% process data
for row = 495:547; %[431:-1:382]; %[198:203 207:229]
    try
    clearvars -except row XLS Columns savedir
    display(['working on row ' num2str(row)])
    % compile metadata
    birdname = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns))); 
    filenameAUDIO = char(XLS.textdata.Sheet1(row,strmatch('AcqGuiFilename', Columns))); 
    filenameAUDIO(strfind(filenameAUDIO, '''')) = []; % to avoid excel adding extra ''''s
    filenameSYNC = filenameAUDIO; filenameSYNC(end-4) = '5'; % chan 5 contains sync input
    filenameVIDEO = char(XLS.textdata.Sheet1(row,strmatch('InscopixFilename', Columns))); 
    filenameVIDEO(strfind(filenameVIDEO, '''')) = []; % to avoid excel adding extra ''''s
    if length(strfind(filenameVIDEO, '.tif'))==0 % some rows include .tif, some don't
        filenameVIDEO = [filenameVIDEO '.tif']; 
    end 
    tiffInfo = imfinfo(filenameVIDEO); 
    nFrames = numel(tiffInfo);

    % load sound and sync data, clip to align with video
    [SOUND SOUNDfs SOUNDabsstarttime label props] = egl_AA_daq(filenameAUDIO, 1);
    [SYNC SOUNDfs SOUNDabsstarttime label props] = egl_AA_daq(filenameSYNC, 1); 
    % align video and audio using sync channel
    AudBinWhenFrameStarts = find(SYNC(2:end)>1 & SYNC(1:end-1)<1 & ...
        [SYNC(3:end); SYNC(end)] > 1 & [SYNC(4:end); SYNC(end); SYNC(end)] > 1 & [SYNC(5:end); SYNC(end); SYNC(end); SYNC(end)] > 1); % to prevent false reads when sync is finicky
    df = max(diff(AudBinWhenFrameStarts));
    AudBinWhenFrameEnds = (AudBinWhenFrameStarts + df); %find(SYNCdata(2:end)<1 & SYNCdata(1:end-1)>1);
    if length(AudBinWhenFrameStarts)~=nFrames
        warning(['frame alignment mismatch, nMovFrames = ' num2str(nFrames) ...
            ', nAudFrames = ' num2str(length(AudBinWhenFrameStarts))]); 
        AudBinWhenFrameStarts = AudBinWhenFrameStarts(1:nFrames); 
        AudBinWhenFrameEnds = AudBinWhenFrameEnds(1:nFrames); 
    end
    tSound = ((1:length(SOUND)) - AudBinWhenFrameStarts(1))/SOUNDfs;
    indMovOn = (tSound>=0)&(tSound<=((AudBinWhenFrameEnds(end)- AudBinWhenFrameStarts(1))/SOUNDfs)); 
    AudBinWhenFrameEnds = AudBinWhenFrameEnds - AudBinWhenFrameStarts(1); 
    AudBinWhenFrameStarts = AudBinWhenFrameStarts - AudBinWhenFrameStarts(1); 
    tSound = tSound(indMovOn);
    SOUND = SOUND(indMovOn);
    display('done processing sound data')

    % compile video
    VIDEO = zeros(nFrames,300,400); % 300x400 pixel version (maintains aspect ratio of original 1080x1440 video)
    for framei = 1:nFrames
        bigframe = imread(filenameVIDEO, framei, 'info', tiffInfo);
        VIDEO(framei,:,:) = imresize(imgaussfilt(...
            squeeze(bigframe), 3.6),1/3.6); % smaller smoothed version
    end
    display('done processing video data')

    % compile spectrogram for each frame
    soundclip = zeros(1,round(SOUNDfs)+1); 
    specTime = -.5:(1/SOUNDfs):.5; 
    [S,~,F] = spectrogramELM(soundclip,SOUNDfs,.002, 0); 
    SPEC = zeros(nFrames,size(S,1), size(S,2));
    for framei = 1:nFrames
        soundclip = zeros(1,round(SOUNDfs)+1); 
        tframe = AudBinWhenFrameStarts(framei) + round(specTime*SOUNDfs);
        indtframe = tframe>0 & tframe <= length(SOUND); 
        tframe = tframe(indtframe); 
        soundclip(indtframe) = SOUND(tframe); 
        [S,~,~] = spectrogramELM(soundclip,SOUNDfs,.002, 0); 
        tmp = 10*log10(S+eps); 
        tmp(tmp(:)<prctile(tmp(:),50)) = prctile(tmp(:),50);
        SPEC(framei,:,:) = tmp;
    end
    display('done computing spectrograms')
    
    % computing delta F over F video
    VIDEOfs = round(SOUNDfs/min(diff(AudBinWhenFrameStarts))); 
    vecVIDEO = reshape(permute(VIDEO,[2 3 1]),300*400, nFrames);
    tic; a = DeltaFOF_elm(vecVIDEO, VIDEOfs); toc
    dffVIDEO = permute(reshape(a,300,400,nFrames),[3 1 2]); 
    display('calculated dff')
    
    % save
    filename = fullfile(savedir, ['CaELM_row' num2str(row)]); 
    tic; save(filename, 'dffVIDEO', 'VIDEOfs', ...
        'SOUND', 'VIDEO', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F',...
        'filenameVIDEO', 'filenameAUDIO',  '-v7.3'); toc;
    display(['saved, saving took ' num2str(toc) ' sec'])
    catch
        display(['ERROR ROW ' num2str(row)])
    end
end
%% display movie from saved data for one row
savedir = 'E:\ProcessedCalciumData\AllRows'; %'E:\ProcessedCalciumData\AllRows'; %'C:\Users\emackev\Documents\StuffICanDelete';%'E:\StuffICanDelete'; %

row = 332
savevid = 0; % see/hear it in real time no iff don't save
load(fullfile(savedir, ['CaELM_row' num2str(row)]), 'dffVIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
showcontour = 0; 
ShowCaVid(dffVIDEO,SOUND,SPEC,'C:\Users\emackev\Dropbox (MIT)\TempFileTransfer\example1.avi' ,[],showcontour)%, fullfile(savedir, 'tmp.avi'))
% HandpickROIs(dffVIDEO,SOUND,SPEC, [] ,[],showcontour)%, fullfile(savedir, 'tmp.avi'))
%% montage video of all singing data from a particular folder
% dir = 'C:\Users\emackev\Documents\StuffICanDelete\6636_selected_singing\2016-06-05'; 
% dir = 'C:\Users\emackev\Documents\StuffICanDelete\6636_selected_singing\2016-06-09'; 
% dir = 'C:\Users\emackev\Documents\StuffICanDelete\6636_selected_singing\2016-06-11'; 
% dir = 'C:\Users\emackev\Documents\StuffICanDelete\6636_selected_singing\2016-06-18'; 

% dir = 'C:\Users\emackev\Documents\StuffICanDelete\6636_selected_singing\2016-06-22'; 
dir = 'C:\Users\emackev\Documents\StuffICanDelete\6636_selected_singing\2016-06-27'; 
% dir = 'C:\Users\emackev\Documents\StuffICanDelete\6636_selected_singing\2016-07-01'; 
load(fullfile(dir, 'analysis'))
CompVid = [];
CompSound = [];
CompSpec = [];
for filei = 1:length(dbase.SegmentTimes)
    segtimes = dbase.SegmentTimes{filei}; segtimes = segtimes(dbase.SegmentIsSelected{filei}==1,:); 
    load(fullfile(dir, dbase.SoundFiles(filei).name), 'dffVIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
    bouts = SegsToBouts(segtimes, 1*SOUNDfs); 
    for bi = 1:size(bouts,1)
        useframes = round(bouts(bi,1)/SOUNDfs*VIDEOfs):...
            round(bouts(bi,2)/SOUNDfs*VIDEOfs);
        useframes(useframes<=0) = []; useframes(useframes>nFrames) = []; 
        if length(useframes)>0
            CompVid = cat(1,CompVid,                                                             dffVIDEO(useframes,:,:)); 
            CompSound = [CompSound; SOUND(round((AudBinWhenFrameStarts(useframes(1)))+1):...
                (round(AudBinWhenFrameStarts(useframes(end)))+floor(SOUNDfs/VIDEOfs)))]; 
            CompSpec = cat(1,CompSpec,SPEC(useframes,:,:));
            display(['file ' num2str(filei) ' bout ' num2str(bi)])
        end
    end

   
end
showcontour = 1; 
% ShowCaVid(CompVid,CompSound,CompSpec, fullfile(dir, 'tmp.avi'), [], showcontour)
ShowCaVid(CompVid,CompSound,CompSpec, [], [], showcontour)
