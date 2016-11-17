%% load CalciumData spreadsheet

XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/CalciumData.xlsx');
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
Columns = XLS.textdata.Sheet1(1,:);

% decide where to save stuff
savedir = 'E:\ProcessedCalciumData\AllRows'; %'Z:\emackev\inscopix'; 'C:\Users\emackev\Documents\StuffICanDelete';
% to populate xls... use AlignImSongFiles now...
% DIR1 = dir(fullfile('E:\TempFileTransfer', '2016-10-21', '*chan0.dat'))
% DIR = dir(fullfile('E:\TempFileTransfer', 'HVCgcamp10212016', '*.tif'))
% DIR = DIR(cellfun(@numel,(regexp( {DIR.name}', 'recording_\d+_\d+.tif')))==1);
% {DIR.name}'

%% process data
for row = [1548 1549 1503:1547]; %1181:1271 1179:1180 %882;%941:947; %862:-1:804; %741:803;%[713:740 673:712]; %646:-1:622; %[431:-1:382]; %[198:203 207:229]
    try
    clearvars -except row XLS Columns savedir
    display(['working on row ' num2str(row)])
    % compile metadata
    birdname = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns))); 
    filenameAUDIO = char(XLS.textdata.Sheet1(row,strmatch('AcqGuiFilename', Columns))); 
    filenameAUDIO(strfind(filenameAUDIO, '''')) = []; % to avoid excel adding extra ''''s
    if length(strfind(filenameAUDIO, '.dat'))==0 % some rows include .dat, some don't
        filenameAUDIO = [filenameAUDIO '.dat']; 
    end 
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
    if length(AudBinWhenFrameStarts)>nFrames
        warning(['frame alignment mismatch, nMovFrames = ' num2str(nFrames) ...
            ', nAudFrames = ' num2str(length(AudBinWhenFrameStarts))]); 
        AudBinWhenFrameStarts = AudBinWhenFrameStarts(1:nFrames); 
        AudBinWhenFrameEnds = AudBinWhenFrameEnds(1:nFrames);
    elseif length(AudBinWhenFrameStarts)<nFrames
        warning(['frame alignment mismatch, nMovFrames = ' num2str(nFrames) ...
            ', nAudFrames = ' num2str(length(AudBinWhenFrameStarts))]); 
        nFrames = length(AudBinWhenFrameStarts);   
    end
    tSound = ((1:length(SOUND)) - AudBinWhenFrameStarts(1))/SOUNDfs;
    indMovOn = (tSound>=0)&(tSound<=((AudBinWhenFrameEnds(end)- AudBinWhenFrameStarts(1))/SOUNDfs)); 
    AudBinWhenFrameEnds = AudBinWhenFrameEnds - AudBinWhenFrameStarts(1); 
    AudBinWhenFrameStarts = AudBinWhenFrameStarts - AudBinWhenFrameStarts(1); 
    tSound = tSound(indMovOn);
    SOUND = SOUND(indMovOn);
    display('done processing sound data')

    % compile video
    VIDEO = zeros(nFrames,ceil(tiffInfo(1).Height/3.6),ceil(tiffInfo(1).Width/3.6)); % 300x400 pixel version (maintains aspect ratio of original 1080x1440 video)
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
    
%     % if want background subtracted version
%     Y = permute(VIDEO,[2 3 1]); 
%     Y = Y - min(Y(:)); 
%     [Yest, results] = local_background(Y, [], 15); %, ssub, rr, ACTIVE_PX, sn, thresh)
% 
%     
%     VIDEObs = permute(Y-Yest,[3 1 2]); % subtract background
    
    % if want old dff
%     vecVIDEO = reshape(permute(VIDEObs,[2 3 1]),size(VIDEO,2)*size(VIDEO,3), nFrames);
%     tic; a = DeltaFOF_elm(vecVIDEO-min(vecVIDEO(:)), VIDEOfs); toc
%     
%     dffVIDEO = permute(reshape(a,size(VIDEO,2),size(VIDEO,3),nFrames),[3 1 2]); 
%     display('calculated dff')
    
    % save
    filename = fullfile(savedir, ['CaELM_row' num2str(row)]); 
    tic; save(filename, 'VIDEOfs', ...;%'VIDEObs', ...
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
% savedir = 'E:\ProcessedCalciumData\AllRows'; %'E:\ProcessedCalciumData\AllRows'; %'C:\Users\emackev\Documents\StuffICanDelete';%'E:\StuffICanDelete'; %
% close all; shg
savedir = 'E:\ProcessedCalciumData\AllRows'; %'Z:\emackev\inscopix'; 'C:\Users\emackev\Documents\StuffICanDelete';

% savedir = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct18\Undirected1'
row = 1549; %882; 882; 947; %808; %895; %882; %895%sleep; 678; %182; %197; %678; %770;  %930; %758; %678; %744 
savevid = 0; % see/hear it in real time no iff don't save
load(fullfile(savedir, ['CaELM_row' num2str(row)]), 'VIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
showcontour = 0; 
params.VIDEOfs = VIDEOfs;
params.SOUNDfs = SOUNDfs;
params.specTime = -.5:(1/params.SOUNDfs):.5;
params.F = linspace(507.8125, 5976.6, 141);
params.AudBinWhenFrameStarts = AudBinWhenFrameStarts; 
params.AudBinWhenFrameEnds =  AudBinWhenFrameEnds; 
% ShowCaVid(VIDEObs,SOUND,SPEC,'C:\Users\emackev\Dropbox (MIT)\TempFileTransfer\rr15.avi' ,params,showcontour)%, fullfile(savedir, 'tmp.avi'))

Y = permute(VIDEO,[2 3 1]); 
Y = Y - min(Y(:)); 
[Yest, results] = local_background(Y, [], 15); %, ssub, rr, ACTIVE_PX, sn, thresh)
VIDEObs = permute(Y-Yest,[3 1 2]); % subtract background
    
ShowCaVid(VIDEO,SOUND,SPEC,'C:\Users\emackev\Dropbox (MIT)\TempFileTransfer\6701raw.avi' ,params,showcontour)%, fullfile(savedir, 'tmp.avi'))
ShowCaVid(VIDEO,SOUND,SPEC,[] ,params,showcontour)%, fullfile(savedir, 'tmp.avi'))
% HandpickROIs(VIDEO,SOUND,SPEC, [] , params,showcontour)%, fullfile(savedir, 'tmp.avi'))
title(num2str(row)); 
%% checking for rotations
savedir = 'E:\ProcessedCalciumData\AllRows'; %'Z:\emackev\inscopix'; 'C:\Users\emackev\Documents\StuffICanDelete';

CheckRows = [1380:2:1433]; %[1181:5:1211 1212:1214]; %1046:8:1145
COMP = []; 
COMPT = []; 
for rowi = 1:numel(CheckRows)
    load(fullfile(savedir, ['CaELM_row' num2str(CheckRows(rowi))]), 'VIDEO'); 
    tmp = squeeze(median(VIDEO,1)); 
    COMP = [COMP tmp]; 
    COMPT = [COMPT; tmp]; 
    clf; imagesc(tmp); title(num2str(CheckRows(rowi)));drawnow; shg
%     sound(sin(1:1000))
    CheckRows(rowi)
end
tmp = repmat(COMP,numel(CheckRows),1) - ...
    repmat(COMPT,1,numel(CheckRows)); 
imagesc(abs(tmp))
set(gca, 'xtick', size(VIDEO,3)*((1:numel(CheckRows))-.5),...
    'xticklabel', arrayfun(@num2str, CheckRows, 'uniformoutput', 0))
set(gca, 'ytick', size(VIDEO,2)*((1:numel(CheckRows))-.5),...
    'yticklabel', arrayfun(@num2str, CheckRows, 'uniformoutput', 0))

%%
rows = [552:558 561:563]
depths = [2.73 2.42 2.27 1.98 1.75 1.43 1.22 1.00 .75 .52]; 
figure(2); clf; colormap gray
M = []; 
M1 = [];
for rowi = 1:length(rows)
    row = rows(rowi);
    load(fullfile(savedir, ['CaELM_row' num2str(row)]), 'VIDEO', 'dffVIDEO'); 
    m = squeeze(mean(VIDEO,1)); 
    m1 =  squeeze(max(dffVIDEO,[],1));
    if mod(rowi,2)==0; 
        m = flipud(fliplr(m)); 
        m1 = flipud(fliplr(m1)); 
    end
    M = [M; m]; 
    M1 = [M1; m1]; 
end
M = M-min(M(:)); M = M/max(M(:));
M1 = M1-min(M1(:)); M1 = M1/max(M1(:));
imagesc([M M1]); axis image; axis off; colormap gray
set(gcf, 'papersize', [3 10], 'paperposition', [0 0 3 10])
figure(3);  clf; hold on
plot((0:9)*.5, depths(1:10), 'ko', 'markerfacecolor', 'k')
p = polyfit((0:9)*.5, depths(1:10),1);
plot((0:9)*.5, p(1)*(0:9)*.5 + p(2), 'r'); axis tight
xlabel('# turns')
ylabel('focus shaft length (cm)')
title(['Length changes by ' num2str(p(1)) ' cm/turn'])
set(gcf, 'papersize', [3 10], 'paperposition', [0 0 3 10])

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
            CompVid = cat(1,CompVid, dffVIDEO(useframes,:,:)); 
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
