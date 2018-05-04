

%% montage video during sleep
path = 'E:\ProcessedCalciumData\6636_July1\asleep'; 
DIR = dir(fullfile(path, '*.mat')); 

CompVid = [];
CompSound = [];
CompSpec = [];

for filei = 1:length(DIR)
    load(fullfile(path, DIR(filei).name), 'dffVIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
    CompVid = cat(1,CompVid,dffVIDEO); 
    CompSound = [CompSound; SOUND]; 
    CompSpec = cat(1,CompSpec,SPEC);
    display(['file ' num2str(filei)])
end
showcontour = 1; 
% ShowCaVid(CompVid,CompSound,CompSpec, fullfile(dir, 'tmp.avi'), [], showcontour)
ShowCaVid(CompVid,CompSound,CompSpec, [], [], showcontour)
maxproj = squeeze(max(CompVid,[],1)); 
sumproj = squeeze(sum(CompVid,1)); 
save(fullfile(path, 'compiled'), 'CompVid', 'CompSound', 'CompSpec', '-v7.3');
save(fullfile(path, 'compiled'), 'maxproj', 'sumproj', '-append')
%% montage video awake
path = 'E:\ProcessedCalciumData\6636_July1\awake'; 
load(fullfile(path, 'analysis.mat')); 
CompVidSONG = [];
CompSoundSONG = [];
CompSpecSONG = [];
CompVidBOS = [];
CompSoundBOS = [];
CompSpecBOS = [];
CompVidCON = [];
CompSoundCON = [];
CompSpecCON = [];
save(fullfile(path, 'compiled'), 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG',...
   'CompVidBOS', 'CompSoundBOS', 'CompSpecBOS',...
   'CompVidCON', 'CompSoundCON', 'CompSpecCON',...
   '-v7.3')
for filei = 1:length(dbase.SegmentTimes)
    segtimes = dbase.SegmentTimes{filei}; 
    BOSsegInd = cellfun(@(x) issame(x,'B'), dbase.SegmentTitles{filei}, 'UniformOutput', 1)>0;
    CONsegInd = cellfun(@(x) issame(x,'C'), dbase.SegmentTitles{filei}, 'UniformOutput', 1)>0;
    load(fullfile(path, dbase.SoundFiles(filei).name), 'dffVIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
    % SONG
    if sum((~BOSsegInd)&(~CONsegInd)&dbase.SegmentIsSelected{filei}==1)>0
        bouts = SegsToBouts(segtimes((~BOSsegInd)&(~CONsegInd)&dbase.SegmentIsSelected{filei}==1,:), .1*SOUNDfs); 
        for bi = 1:size(bouts,1)
            useframes = round(bouts(bi,1)/SOUNDfs*VIDEOfs):...
                round(bouts(bi,2)/SOUNDfs*VIDEOfs);
            useframes(useframes<=0) = []; useframes(useframes>nFrames) = []; 
            if length(useframes)>0
                CompVidSONG = cat(1,CompVidSONG,dffVIDEO(useframes,:,:)); 
                CompSoundSONG = [CompSoundSONG; SOUND(round((AudBinWhenFrameStarts(useframes(1)))+1):...
                    (round(AudBinWhenFrameStarts(useframes(end)))+floor(SOUNDfs/VIDEOfs)))]; 
                CompSpecSONG = cat(1,CompSpecSONG,SPEC(useframes,:,:));
                display(['SONG file ' num2str(filei) ' bout ' num2str(bi)])
            end
        end
    end
    % BOS
    if sum((BOSsegInd)&(~CONsegInd)&dbase.SegmentIsSelected{filei}==1)>0
        bouts = SegsToBouts(segtimes((BOSsegInd)&(~CONsegInd)&dbase.SegmentIsSelected{filei}==1,:), .1*SOUNDfs); 
        for bi = 1:size(bouts,1)
            useframes = round(bouts(bi,1)/SOUNDfs*VIDEOfs):...
                round(bouts(bi,2)/SOUNDfs*VIDEOfs);
            useframes(useframes<=0) = []; useframes(useframes>nFrames) = []; 
            if length(useframes)>0
                CompVidBOS = cat(1,CompVidBOS,dffVIDEO(useframes,:,:)); 
                CompSoundBOS = [CompSoundBOS; SOUND(round((AudBinWhenFrameStarts(useframes(1)))+1):...
                    (round(AudBinWhenFrameStarts(useframes(end)))+floor(SOUNDfs/VIDEOfs)))]; 
                CompSpecBOS = cat(1,CompSpecBOS,SPEC(useframes,:,:));
                display(['BOS file ' num2str(filei) ' bout ' num2str(bi)])
            end
        end
    end
    % CON
    if sum((~BOSsegInd)&(CONsegInd)&dbase.SegmentIsSelected{filei}==1)>0
        bouts = SegsToBouts(segtimes((~BOSsegInd)&(CONsegInd)&dbase.SegmentIsSelected{filei}==1,:), .1*SOUNDfs); 
        for bi = 1:size(bouts,1)
            useframes = round(bouts(bi,1)/SOUNDfs*VIDEOfs):...
                round(bouts(bi,2)/SOUNDfs*VIDEOfs);
            useframes(useframes<=0) = []; useframes(useframes>nFrames) = []; 
            if length(useframes)>0
                CompVidCON = cat(1,CompVidCON,dffVIDEO(useframes,:,:)); 
                CompSoundCON = [CompSoundCON; SOUND(round((AudBinWhenFrameStarts(useframes(1)))+1):...
                    (round(AudBinWhenFrameStarts(useframes(end)))+floor(SOUNDfs/VIDEOfs)))]; 
                CompSpecCON = cat(1,CompSpecCON,SPEC(useframes,:,:));
                display(['BOS file ' num2str(filei) ' bout ' num2str(bi)])
            end
        end
    end
   save(fullfile(path, 'compiled'), 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG',...
       'CompVidBOS', 'CompSoundBOS', 'CompSpecBOS',...
       'CompVidCON', 'CompSoundCON', 'CompSpecCON',...
       '-append');

end
% showcontour = 1; 
% ShowCaVid(CompVid,CompSound,CompSpec, fullfile(dir, 'tmp.avi'), [], showcontour)
% ShowCaVid(CompVid,CompSound,CompSpec, [], [], showcontour)
%%
clear all; close all; 
load('E:\ProcessedCalciumData\6636_July1\awake\compiled.mat', ...
    'CompVidSONG', 'CompSoundSONG','CompSpecSONG')
ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, [], [], 1)

A = CompVidSONG;
[t y x] = size(A); 
[X1,X2] = meshgrid(1:x,1:y);
ccoor = [x/2 y/2];
Amat = reshape(permute(A,[2 3 1]),y*x,t); 
mask = sqrt((X2(:)-ccoor(2)).^2 + (X1(:)-ccoor(1)).^2)<175; 
Amat(~mask,:) = 0; 
maxproj = reshape(max(Amat,[],2),y,x); %squeeze(max(A,[],1));
imagesc(maxproj)

Clusters = clusterdata(Amat(mask,1:50), 'maxclust', 100, 'distance', 'correlation'); 
%%
im = zeros(300,400); 
im(mask) = Clusters; 
figure; imagesc(im); colormap lines


%%
clear all; close all; clc
load('C:\Users\emackev\Documents\StuffICanDelete\6636_July1\asleep\compiled.mat', 'CompVid')
load('C:\Users\emackev\Documents\StuffICanDelete\6636_July1\awake\compiled.mat', ...
    'CompVidSONG', 'CompVidBOS','CompVidCON')
% maxproj = cat(3,squeeze(max(CompVidBOS,[],1)), ...
%     squeeze(max(CompVidSONG,[],1)), ...
%     squeeze(max(CompVid,[],1))); 
meanproj = cat(3,squeeze(mean(CompVidBOS,1)), ...
    squeeze(mean(CompVid,1)), ...
    squeeze(mean(CompVidSONG,1))); 
maxs = permute([prctile(CompVidBOS(:),98) ...
    prctile(CompVid(:),98), ...
    prctile(CompVidSONG(:),98)], [1 3 2]);
normMeans = bsxfun(@rdivide, meanproj, maxs); 
thres = prctile(normMeans(:),10);
normMeans(normMeans<thres) = thres; normMeans = normMeans-thres; normMeans = normMeans/prctile(normMeans(:),99.9);
figure(8); shg; 
imshow(normMeans.*cat(3,ones(300,400), zeros(300,400), zeros(300,400))); pause(1)
imshow(normMeans.*cat(3,ones(300,400), ones(300,400), zeros(300,400))); pause(1)
imshow(normMeans.*cat(3,ones(300,400), ones(300,400), ones(300,400))); pause(1)
imshow(normMeans); title('BOS-R SONG-B SLEEP-G')
% figure; imshow(meanproj/prctile(meanproj(:),99.99)); title('mean proj: BOS-R SONG-G SLEEP-B')