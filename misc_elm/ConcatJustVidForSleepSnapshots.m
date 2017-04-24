%% compile big sleep video from autorecorded clips
% clear all; close all; clc
savecompiledvidhere = 'G:\TempFileTransfer\TmpProcVids\April11SleepCompilation.avi';
pathname = '\\feevault\data0\Inscopix\HVCgcamp04112017\';
DIR = dir([pathname '*.tif'])
compY = []; 
obj = vision.VideoFileWriter(savecompiledvidhere);
obj.FrameRate = 30; 
LastFrameOfFile = []; 
fcnt = 0; 
filecnt = 1; 
for fi = 1:length(DIR)
    % condition on times...
    if (mod(fi,3) == 0) & (datenum(DIR(fi).date) > datenum('April 11, 2017, 9:24PM'))
        figure(1); clf
        filenameVIDEO = fullfile(pathname, DIR(fi).name); 
        tiffInfo = imfinfo(filenameVIDEO); 
        nFrames = numel(tiffInfo);
        fcnt = fcnt + nFrames; 
        LastFrameOfFile = [LastFrameOfFile fcnt]; 
        % load video
        Y = zeros(ceil(tiffInfo(1).Height/3.6),ceil(tiffInfo(1).Width/3.6),nFrames); % 300x400 pixel version (maintains aspect ratio of original 1080x1440 video)
        for framei = 1:nFrames
            bigframe = imread(filenameVIDEO, framei, 'info', tiffInfo);
            Y(:,:, framei) = imresize(imgaussfilt(...
                squeeze(bigframe), 3.6),1/3.6); % smaller smoothed version
        end
        display('loaded')
        
        % subtract the background
        Y = Y - min(Y(:)); 
        [Yest, results] = local_background(Y, [], 15); %, ssub, rr, ACTIVE_PX, sn, thresh)
        Ybs = Y-Yest; % subtract background
        display('subtracted')

        % smooth it
        Ybs_smooth = 0*Ybs; 
        for fri = 1:size(Ybs,3)
            tmp = squeeze(Ybs(:,:,fri));
            tmp = imgaussfilt(tmp, 3, 'Padding', 'symmetric'); % low pass filter
        %     tmp = tmp - imgaussfilt(tmp,bpass(1), 'Padding', 'symmetric'); % high pass filter
            Ybs_smooth(:,:,fri) = tmp; 
        %     imagesc(tmp); axis image; drawnow
        end
        display('smoothed')

        % plot it
        tmp = Ybs_smooth(:,:,1:100:end);
        maxproj{fi} = max(tmp,[],3); 
        clims = [0 prctile(tmp(:),99.996)]; % [.1 .5]; % [0 prctile(VIDEO(:),99.996)];
        im = imagesc(maxproj{fi},clims); axis image; axis off; colormap gray; drawnow; shg; hold on
        text(10,10,DIR(fi).date, 'color', 'w', 'fontweight', 'bold');
        for fri = 1:size(Ybs_smooth,3)
            im.CData = Ybs_smooth(:,:,fri);
            drawnow
            Frame = getframe(gcf); 
            step(obj, Frame.cdata); 
        end
        
        % save it
        compY = cat(3, compY, Ybs_smooth); 
        save(fullfile(pathname, 'SleepCompilation'), 'maxproj', 'compY', 'DIR', 'LastFrameOfFile', ...
       '-v7.3'); 
        display(['saved ' filenameVIDEO]);
    end
end
release(obj); 
display('saved video')

%%


load \\feevault\data0\Inscopix\HVCgcamp04112017\SleepCompilation

