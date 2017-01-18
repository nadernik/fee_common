%% put data in a folder
% DataFolder = 'E:\ProcessedCalciumData\6865_Jan4'; % singing, tutoring, sleep
% DataFolder = 'E:\ProcessedCalciumData\6865_SleepAndTutoring'; % first tutoring and sleep
% DataFolder = 'E:\ProcessedCalciumData\6868_SleepAndTutoring'; % first tutoring and sleep
% DataFolder = 'E:\ProcessedCalciumData\6869_SleepAndTutoring'; % first tutoring and sleep
DataFolder = 'E:\ProcessedCalciumData\6865_Jan5'; % first tutoring and sleep
%% label data using electrogui
%% compile data
moat= 2; 
analysis2compiled(DataFolder, moat);
%% maybe look at movie
load(fullfile(DataFolder, 'compiled'), 'Y', 'CompSoundSONG', 'CompSpecSONG', 'VIDEOfs', 'SOUNDfs');
[Yest, results] = local_background(Y, [], 15); %, ssub, rr, ACTIVE_PX, sn, thresh)
CompVidSONG = permute(Y-Yest,[3 1 2]); % subtract background
% CompVidSONG = permute(Y,[3 1 2]); 
clear Y
params.VIDEOfs = VIDEOfs;
params.SOUNDfs = 40000;
ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, [],params, 0)
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
clf
DataFolder = 'E:\ProcessedCalciumData\6865_Jan9'; % singing, tutoring, sleep
cnmfeFilePath = 'E:\ProcessedCalciumData\6865_Jan9\cnmfe_results'; 
LabelCanon = {'f' 'n' 'n' 'c'}; %
% 
% DataFolder = 'E:\ProcessedCalciumData\6869_SleepAndTutoring'; % first tutoring and sleep
% cnmfeFilePath = 'E:\ProcessedCalciumData\6869_SleepAndTutoring\cnmfe_results'; 
% LabelCanon = {'A' 'B' 'C' 'D'};

moat = 1; 
[indSeqSort, nColors, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat);
% circleNeurons(cnmfeFilePath, indSeqSort, nColors);
% coloredTraces(DataFolder, cnmfeFilePath, indSeqSort, nColors, baselines)
%% Jan 9
figure(1)
clf
C = neuron.C(indSeqSort,:);
C = conv2(C, gausswin(10)'); 
M_sleep = C(:,8000:11800); 
M_song = C(:,1:7000); 
subplot(1,2,1)
range = [.1 .9]; 
imagesc(corr(M_song'), range); axis image; title('song')
subplot(1,2,2)
imagesc(corr(M_sleep'), range);axis image; title('sleep')
% cmap = [flipud([(1:255)'; 255*ones(255,1)] ) ...
%     [(1:255)'; 255*zeros(255,1)] 255*ones(255*2,1) ]/255;
% colormap(cmap)
colormap gray
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
coloredTraces(DataFolder, cnmfeFilePath, indsort, nColors, baselines)

