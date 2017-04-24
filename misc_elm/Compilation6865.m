%% put data in a folder
% DataFolder = 'E:\ProcessedCalciumData\6865_Jan4'; % singing, tutoring, sleep
% DataFolder = 'E:\ProcessedCalciumData\6865_SleepAndTutoring'; % first tutoring and sleep
% DataFolder = 'E:\ProcessedCalciumData\6868_SleepAndTutoring'; % first tutoring and sleep
% DataFolder = 'E:\ProcessedCalciumData\6869_SleepAndTutoring'; % first tutoring and sleep
DataFolder = 'G:\ProcessedCalciumData\6568_March25'; % first tutoring and sleep
%% label data using electrogui
%% compile data
moat= 1; 
analysis2compiled(DataFolder, moat);
%% maybe look at movie
load(fullfile(DataFolder, 'compiled'), 'Y', 'CompSoundSONG', 'CompSpecSONG', 'VIDEOfs', 'SOUNDfs');
[Yest, results] = local_background(Y, [], 15); %, ssub, rr, ACTIVE_PX, sn, thresh)
CompVidSONG = permute(Y-Yest,[3 1 2]); % subtract background
% smooth it
VIDEObs_smooth = 0*CompVidSONG; 
for fi = 1:size(CompVidSONG,1)
    tmp = squeeze(CompVidSONG(fi,:,:));
    tmp = imgaussfilt(tmp, 3, 'Padding', 'symmetric'); % low pass filter
%     tmp = tmp - imgaussfilt(tmp,bpass(1), 'Padding', 'symmetric'); % high pass filter
    VIDEObs_smooth(fi,:,:) = tmp; 
%     imagesc(tmp); axis image; drawnow
end
% CompVidSONG = permute(Y,[3 1 2]); 
clear Y
params.VIDEOfs = VIDEOfs;
params.SOUNDfs = 40000;
ShowCaVid(VIDEObs_smooth,CompSoundSONG,CompSpecSONG, 'C:\Users\emackev\Downloads\CM6568.avi',params, 0)
%% run CNMFE (on openmind)

% put CNMFEscript.m and compiled.mat in the appropriate ForOpenMind folders

% Set resources in Testing.sh, using notepad++ 

% put data and and code files onto openmind
% scp -rp /home/emackev/MyDocuments/ForOpenMind/ForOm/* elm@openmind7.mit.edu:/om/user/elm
% scp -rp /home/emackev/MyDocuments/ForOpenMind/ForHome/* elm@openmind7.mit.edu:/home/elm

% run cnmfe on openmind
% ssh elm@openmind7.mit.edu
% sbatch Testing.sh

% check up on it with 
% squeue | grep elm

% bring results back to this computer
% scp elm@openmind7.mit.edu:/om/user/elm/analysisOut/cnmfe_results.mat /home/mobaxterm/MyDocuments/ForOpenMind/

% check how much memory it took with: 
% sacct -o reqmem,maxrss,averss,elapsed -u elm

%% plot raster
% clf

DataFolder = 'G:\ProcessedCalciumData\6938_April7prepostnap'; % singing, tutoring, sleep
cnmfeFilePath = 'G:\ProcessedCalciumData\6938_April7prepostnap\cnmfe_results.mat'; 
% 
% DataFolder = 'E:\ProcessedCalciumData\6701_Nov20'; % first tutoring and sleep
% cnmfeFilePath = 'E:\ProcessedCalciumData\6701_Nov20\cnmfe_results'; 
% LabelCanon = {'A' 'B' 'C' 'D' 'E'};

moat = .5; 
% check neurons, discard bad ones
load(cnmfeFilePath, 'neuron'); 
% TOEXCLUDE = indSeqSort([31:59]); %excludeNeurons(cnmfeFilePath);
% circleNeurons(cnmfeFilePath,indSeqSort, nColors);
% tokeep = setdiff(1:size(neuron.C,1), TOEXCLUDE);
% neuron.C = neuron.C(tokeep,:); 
% neuron.A = neuron.A(:,tokeep); 
% cnmfeFilePath = [cnmfeFilePath(1:end-4) '_cleaned.mat']; 
% save(cnmfeFilePath, 'neuron'); 

%%%blah
% figure(1); 
% LabelCanon = {'A' 'B' 'C' 'D'}; %{'A' 'B' 'C' 'D' 'E'}; %{'a' 'b' 'b' 'b' 'c'}; %
% [indSeqSort, nColors, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat);


% figure(2); 
% LabelCanon = {'A' 'B' 'C' 'D' 'E'}; %{'a' 'b' 'b' 'b' 'c'}; %
% [indSeqSort1, nColors, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat, ...
%     indSeqSort(sort([4 9 27 79 72 149 188 120 80 155 220 56 146 186 38 48 49 132 212 30 173 167], 'ascend')));

% sort using mds
M = neuron.C; %conv2(neuron.C, gausswin(50)'); 

% M = bsxfun(@minus, M, mean(M,1)); 
% M = bsxfun(@minus, M, mean(M,2)); 

figure(3); clf
nNeurons = size(neuron.C,1);
Corr = corr(M(:,[1:2431 8506:end])'); %(:,1:1400)'); %imagesc(Corr)
% indSeqSort = sortbyCorr(Corr); 
% [~,indSeqSort] = sort(mdscale(1-Corr, 1)); 
Corr(isnan(Corr)) = 0; 
Z = linkage(Corr, 'weighted', 'correlation'); 
D = pdist(Corr);
leafOrder = optimalleaforder(Z,D, 'criteria', 'group');
h(1) = subplot(2,2,1); 
[dend,T,indSeqSort] = dendrogram(Z, size(M,1), 'Reorder',leafOrder,'Orientation','left'); 
nColors1 = lines(nNeurons);
[~,unsort] = sort(indSeqSort); 
hold on
scatter( 0*ones(1,nNeurons),1:nNeurons, 'cdata', 1-nColors1, 'marker', 's', 'markerfacecolor', 'flat')
xlabel('Distance (au)'); 
set(gca, 'ytick', [])

h(2) = subplot(2,2,2); 
imagesc(Corr(indSeqSort, indSeqSort)); %axis square
set(gca, 'ydir', 'normal')
linkaxes(h, 'y')
xlabel('Neuron #');ylabel('Neuron #')

subplot(2,2,3:4)
circleNeurons(cnmfeFilePath,indSeqSort, nColors1);
papersize = [8 8];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])

% figure(2)
% 
% LabelCanon =  {'n' 'n' 'p' 'p'}; %'A' 'B' 'C' 'D'}; %'n' 'n' 'p' 'p'}; %{'a' 'b' 'b' 'b' 'c'}; %
% [indSeqSort1, nColors1, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat, ...
%     indSeqSort); %([13 14 106 111 113 115 116 118 127 128]));

% figure(1)
% LabelCanon =  {'A' 'B' 'C' 'D'}; %'n' 'n' 'p' 'p'}; %{'a' 'b' 'b' 'b' 'c'}; %
% [indSeqSort1, nColors, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat, ...
%     indSeqSort); %([13 14 106 111 113 115 116 118 127 128]));
% 
% figure(2)
% LabelCanon =  {'n' 'n'}; %{'a' 'b' 'b' 'b' 'c'}; %
% [indSeqSort1, nColors2, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat, ...
%     indSeqSort); %([13 14 106 111 113 115 116 118 127 128]));

% figure(3); 
% LabelCanon = {'A' 'B' 'C' 'D'}; %{'a' 'b' 'b' 'b' 'c'}; %
% [indSeqSort1, nColors, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat, indSeqSort([15 19 20 21 23 27 30 32 34 38 40 41 43 44 45:51 54 57 58]));
% circleNeurons(cnmfeFilePath,indSeqSort([31 33 150 152 156]), nColors);
% circleNeurons(cnmfeFilePath,indSeqSort([1:30 60:end]), nColors1([1:30 60:end],:));
figure(1); coloredTraces(DataFolder, cnmfeFilePath, indSeqSort([1:30 60:end]), nColors1([1:30 60:end],:))
% figure(1); coloredTraces(DataFolder, cnmfeFilePath, indSeqSort, nColors1)
% selectedTraces(DataFolder, cnmfeFilePath, indSeqSort([31 33 150 152 156]), nColors1, baselines)
% selectedTraces(DataFolder, cnmfeFilePath, indSeqSort, nColors, baselines)

%%
%% April 7
clear all
DataFolder = 'G:\ProcessedCalciumData\6938_April7prepostnap'; % singing, tutoring, sleep
cnmfeFilePath = 'G:\ProcessedCalciumData\6938_April7prepostnap\cnmfe_results.mat'; 
% 
load(cnmfeFilePath, 'neuron'); 
load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs', 'SOUNDfs', 'CompSoundSONG', 'FnumBnum');

% check neurons, discard bad ones
load(cnmfeFilePath, 'neuron'); 
TOEXCLUDE = indSeqSort([31:59]); %excludeNeurons(cnmfeFilePath);
% circleNeurons(cnmfeFilePath,indSeqSort, nColors);
tokeep = setdiff(1:size(neuron.C,1), TOEXCLUDE);
neuron.C = neuron.C(tokeep,:); 
neuron.A = neuron.A(:,tokeep); 
cnmfeFilePath = [cnmfeFilePath(1:end-4) '_cleaned.mat']; 
save(cnmfeFilePath, 'neuron'); 

% distance matrix
nNeurons = size(neuron.C,1);
D = zeros(nNeurons,nNeurons);
for ni = 1:size(neuron.A,2)
    tmp = reshape(neuron.A(:,ni),300,400);
    tmps = sum(tmp(:));
    xi = sum(sum(tmp,2)'/tmps.*(1:300));
    yi = sum(sum(tmp,1)/tmps.*(1:400));
    for nj = 1:ni
        tmp = reshape(neuron.A(:,nj),300,400);
        tmps = sum(tmp(:));
        xj = sum(sum(tmp,2)'/tmps.*(1:300));
        yj = sum(sum(tmp,1)/tmps.*(1:400));
        D(ni,nj) = sqrt((xi-xj).^2 + (yi-yj).^2); 
    end
end
D = D+D';%imagesc(D); 

figure(3); clf
M = neuron.C; %conv2(neuron.C, gausswin(50)'); 

Corr = corr(M(:,[1:2431 8506:end])'); %(:,1:1400)'); %imagesc(Corr)
% indSeqSort = sortbyCorr(Corr); 
% [~,indSeqSort] = sort(mdscale(1-Corr, 1)); 
Corr(isnan(Corr)) = 0; 
Z = linkage(Corr, 'weighted', 'correlation'); 
Ds = pdist(Corr);
leafOrder = optimalleaforder(Z,Ds, 'criteria', 'group');
h(1) = subplot(2,2,1); 
[dend,T,indSeqSort] = dendrogram(Z, size(M,1), 'Reorder',leafOrder,'Orientation','left'); 
nColors1 = jet(nNeurons);
[~,unsort] = sort(indSeqSort); 
hold on
scatter( 0*ones(1,nNeurons),1:nNeurons, 'cdata', 1-nColors1, 'marker', 's', 'markerfacecolor', 'flat')
xlabel('Distance (au)'); 
set(gca, 'ytick', [])

h(2) = subplot(2,2,2); 
imagesc(Corr(indSeqSort, indSeqSort)); %axis square
set(gca, 'ydir', 'normal')
linkaxes(h, 'y')
xlabel('Neuron #');ylabel('Neuron #'); drawnow

subplot(2,2,3:4)
circleNeurons(cnmfeFilePath,indSeqSort, nColors1);
papersize = [8 8];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])


% check correlation vs distance
Cmatsorted = Corr(indSeqSort,indSeqSort); 
Dmatsorted = D(indSeqSort,indSeqSort); 

figure(4); clf
subplot(2,2,1)
imagesc(Cmatsorted); hold on
scatter(ones(1,nNeurons),1:nNeurons, 'cdata', 1-nColors1, 'marker', 's', 'markerfacecolor', 'flat')
title('Correlation Matrix')

subplot(2,2,2)
imagesc(Dmatsorted)
title('Distance Matrix')

subplot(2,2,3)
scatter(Dmatsorted(:), Cmatsorted(:), 'o', 'cdata', 1-repmat(nColors1,length(indSeqSort),1), 'markerfacecolor', 'flat'); 
xlabel('Distance (pixels)'); ylabel('Correlation')

subplot(2,2,4)
circleNeurons(cnmfeFilePath,indSeqSort, nColors1);
papersize = [8 8];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
shg


%% April 7
figure(1)
clf
load(cnmfeFilePath, 'neuron'); 
load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs', 'SOUNDfs', 'CompSoundSONG', 'FnumBnum');

C = neuron.C(indSeqSort,:);
% C(C>prctile(C(:),99)) = prctile(C(:),99); 
% median filter
LocalWin = 30; 
LocalMin = C;
for bi = 1:size(C,2)
    LocalMin(:,bi) = min(C(:,...
        max(1,bi-LocalWin):min(size(C,2), bi+LocalWin)),[],2);
end
C = C - LocalMin; 

C = conv2(C, gausswin(10)'); 

M_songpre = C(:,[1:2431]);
M_tutor = C(:,[2476:3511 9946:end]); 
M_sleep = C(:,[3556:8461]); 
M_songpost = C(:,8506:9901); 
subplot(1,3,1)
range = [-.8 .8]; 
imagesc(corr(M_songpre'), range); axis image; title('song pre')
subplot(1,3,2)
% imagesc(corr(M_sleep') - corr(M_songpre'))
imagesc(corr(M_sleep'), range);
axis image; title('sleep')
subplot(1,3,3)
imagesc(corr(M_songpost'), range);axis image; title('song post')
cmap = [[(1:64)'; 64*ones(64,1)] ...
    [1:64 64:-1:1]' ...
    [64*ones(64,1); (64:-1:1)']]/64;
colormap(cmap)
%% 6865 stability jan 11 12
% load(fullfile(DataFolder, 'compiled.mat'), 'Y', 'FnumBnum');

A = squeeze(max(Y(:,:,FnumBnum(:,1)>10),[],3));
B = squeeze(max(Y(:,:,FnumBnum(:,1)<=5),[],3));
% C = squeeze(max(Y,[],3));
% imshowpair(A,B)
figure(1)
filename = 'C:\Users\emackev\Downloads\stabilityGIF.gif'; 
clim = [min(A(:)) max(A(:))]; 
for i = 1:1
    colormap gray
    imagesc(A,clim); axis image; axis off; drawnow; pause(.2); shg
    title('6865 Jan 11, max proj 5 singing files')
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);

        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);

    imagesc(B,clim); axis image;axis off; drawnow; pause(.2)
    title('6865 Jan 12, max proj 5 singing files')
        frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);

        imwrite(imind,cm,filename,'gif','WriteMode','append');
    
%     imagesc(C); axis image;drawnow; pause(.2)
end
%% 6701 stability
% load(fullfile(DataFolder, 'compiled.mat'), 'Y', 'FnumBnum');

A = squeeze(max(Y(:,:,FnumBnum(:,1)>5),[],3));
B = squeeze(max(Y(:,:,FnumBnum(:,1)<=5),[],3));
C = squeeze(max(Y,[],3));
imshowpair(A,B)
figure(1)
filename = 'C:\Users\emackev\Downloads\stabilityGIF.gif'; 
clim = [min(B(:)) max(B(:))]; 
for i = 1:1
    colormap gray
    imagesc(A,clim); axis image; axis off; drawnow; pause(.2); shg
    title('6701 Nov 30, max proj 5 singing files')
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);

        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);

    imagesc(B,clim); axis image;axis off; drawnow; pause(.2)
    title('6701 Nov 29, max proj 5 singing files')
        frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);

        imwrite(imind,cm,filename,'gif','WriteMode','append');
    
%     imagesc(C); axis image;drawnow; pause(.2)
end
%%
% subtract the background
% Y = permute(VIDEO,[2 3 1]); 
% Y = Y - min(Y(:)); 
Y = Y(:,:,500:800); 
[Yest, results] = local_background(Y, [], 15); %, ssub, rr, ACTIVE_PX, sn, thresh)
VIDEObs = permute(Y-Yest,[3 1 2]); % subtract background
% ShowCaVid(VIDEObs,SOUND,SPEC,[] ,params,showcontour)%, fullfile(savedir, 'tmp.avi'))

% smooth it
VIDEObs_smooth = 0*VIDEObs; 
for fi = 1:size(VIDEObs,1)
    tmp = squeeze(VIDEObs(fi,:,:));
    tmp = imgaussfilt(tmp, 3, 'Padding', 'symmetric'); % low pass filter
%     tmp = tmp - imgaussfilt(tmp,bpass(1), 'Padding', 'symmetric'); % high pass filter
    VIDEObs_smooth(fi,:,:) = tmp; 
%     imagesc(tmp); axis image; drawnow
end
%%
imagesc(squeeze(max(VIDEObs_smooth,[],1)), [0 prctile(VIDEObs_smooth(:),99.99)])
axis image; axis off; 
clf
load(cnmfeFilePath, 'neuron'); 
load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs',...
    'SOUNDfs', 'CompSoundSONG', 'FnumBnum');
istart = 676; stepdur = 90; 
sampsong = CompSoundSONG(ceil(istart*SOUNDfs/VIDEOfs:(istart+stepdur)*SOUNDfs/VIDEOfs)); 
h(1) = subplot('position', [.1 .8 .8 .1]);cla
spectrogramELM(sampsong, SOUNDfs, .002, 1); %title([num2str(istart) '; file ' num2str(FnumBnum(istart,1))]); 
SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
    segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
hold on
for syli = 1:size(SegsInFrame,1)
    patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
        [6 6 6.5 6.5], 'k')
end

axis off
h(2) = subplot('position', [.1 .1 .8 .7]);cla; hold on; 
PlotC = neuron.C;
clims = [0 prctile(neuron.C(:),99)]; %[3 25]; 

tmp = PlotC(indSeqSort,istart:istart+stepdur-1); 
tmp1 = tmp(:,~isnan(sum(tmp,1))); 
%         baselines = median(tmp1,2); % overwriting given baselines
baselines = min(tmp1,[],2); % overwriting given baselines
tmp = bsxfun(@minus, tmp, baselines); 
tmp(tmp<clims(1)) = clims(1); 
tmp(tmp>clims(2)) = clims(2); 
tmp = (tmp-clims(1))/diff(clims);

tmp = tmp(fliplr([52 79 90 92 102 120 143]),:);
tmp = bsxfun(@plus, tmp, (1:size(tmp,1))');
plot((1:stepdur)/VIDEOfs, tmp);
% set(gca, 'ydir', 'reverse'); ylabel('neuron')
xlabel('Time (s)')
linkaxes(h,'x'); 
set(gca, 'fontsize', 14, 'ytick', []);
axis tight
drawnow; shg; colormap(flipud(gray))
%%
% for fi = 1:100
%     imagesc(reshape(neuron.A(:,:)*neuron.C(:,fi),300,400)); axis image
%     drawnow; pause(.01)
% end
%% Jan 14
figure(1)
clf
load(cnmfeFilePath, 'neuron'); 
load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs', 'SOUNDfs', 'CompSoundSONG', 'FnumBnum');

C = neuron.C(indSeqSort,:);
% C(C>prctile(C(:),99)) = prctile(C(:),99); 
% median filter
LocalWin = 30; 
LocalMin = C;
for bi = 1:size(C,2)
    LocalMin(:,bi) = min(C(:,...
        max(1,bi-LocalWin):min(size(C,2), bi+LocalWin)),[],2);
end
C = C - LocalMin; 

C = conv2(C, gausswin(10)'); 

M_songpre = C(:,[1:2386]);
M_sleep = C(:,[2431:16156]); 
M_songpost = C(:,16201:end); 
subplot(1,3,1)
range = [-.8 .8]; 
imagesc(corr(M_songpre'), range); axis image; title('song pre')
subplot(1,3,2)
% imagesc(corr(M_sleep') - corr(M_songpre'))
imagesc(corr(M_sleep'), range);
axis image; title('sleep')
subplot(1,3,3)
imagesc(corr(M_songpost'), range);axis image; title('song post')
cmap = [[(1:64)'; 64*ones(64,1)] ...
    [1:64 64:-1:1]' ...
    [64*ones(64,1); (64:-1:1)']]/64;
colormap(cmap)

%% Jan 9
load(cnmfeFilePath, 'neuron'); 

figure(1)
clf
C = neuron.C(indSeqSort,:);
% C(C>prctile(C(:),99)) = prctile(C(:),99); 
% median filter
LocalWin = 30; 
LocalMin = C;
for bi = 1:size(C,2)
    LocalMin(:,bi) = min(C(:,...
        max(1,bi-LocalWin):min(size(C,2), bi+LocalWin)),[],2);
end
C = C - LocalMin; 

C = conv2(C, gausswin(10)'); 
M_sleep = C(:,8000:11800); 
M_song = C(:,1:7000); 
subplot(1,2,1)
range = [-.8 .8]; 
imagesc(corr(M_song'), range); axis image; title('song')
subplot(1,2,2)
imagesc(corr(M_sleep'), range);axis image; title('sleep')
cmap = [[(1:64)'; 64*ones(64,1)] ...
    [1:64 64:-1:1]' ...
    [64*ones(64,1); (64:-1:1)']]/64;
colormap(cmap)
% colormap gray

%% Jan 3
figure(1)
clf
load(cnmfeFilePath, 'neuron'); 

C = neuron.C(indSeqSort,:);
% C(C>prctile(C(:),99)) = prctile(C(:),99); 
% median filter
LocalWin = 30; 
LocalMin = C;
for bi = 1:size(C,2)
    LocalMin(:,bi) = min(C(:,...
        max(1,bi-LocalWin):min(size(C,2), bi+LocalWin)),[],2);
end
C = C - LocalMin; 

C = conv2(C, gausswin(10)'); 

M_songpre = C(:,[1:1171 1531:1666]);
M_sleep = C(:,[4366:6886 7651:10441]); 2521
M_playback = C(:,6886:7561);
M_tutor = C(:,[1216:1441 1756:2476]); 
M_songpost = C(:,10441:end); 
subplot(1,3,1)
range = [-.8 .8]; 
imagesc(corr(M_songpre'), range); axis image; title('song pre')
subplot(1,3,2)
% imagesc(corr(M_sleep') - corr(M_songpre'))
imagesc(corr(M_sleep'), range);
axis image; title('sleep')
subplot(1,3,3)
imagesc(corr(M_songpost'), range);axis image; title('song post')
cmap = [[(1:64)'; 64*ones(64,1)] ...
    [1:64 64:-1:1]' ...
    [64*ones(64,1); (64:-1:1)']]/64;
colormap(cmap)
% colormap gray
%%
imagesc(corr(M_sleep') - corr(M_songpre'))
%% tsne! 
% ydata = tsne(X, labels, no_dims, initial_dims, perplexity);
load(cnmfeFilePath, 'neuron'); 
C = neuron.C; 
y = mdscale(pdist(bsxfun(@minus, C, median(C,2)), 'spearman'), 1); 
plot(y(:,1),y(:,2), 'k.')
% ydata = tsne(C(:,rand(1,size(C,2))>.9)', [], 1);
% figure(2); plot(ydata(:,1), ydata(:,2), '.')
% indsort = sortbyCorr(cov(C')); 
% imagesc(cov(C(indsort,:)'))
[~,indsort] = sort(y); 
%%

