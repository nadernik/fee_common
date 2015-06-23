for row = 65:70;
    display(row)
    clearvars -except row
    %% load and compile data 

    % from excel
    XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/CalciumData.xlsx');
    XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
    Columns = XLS.textdata.Sheet1(1,:);
    %SINGING = XLS.data.Sheet1(row,strmatch('Singing?', Columns))==1;
    
    % if I've already compiled it, just load MATLAB
    if 0==length(char(XLS.textdata.Sheet1(row,strmatch('MatlabDatafilename', Columns))));
        % song from acq qui
        filename = char(XLS.textdata.Sheet1(row,strmatch('AcqGuiFilename', Columns))); 
        [SOUNDdata SOUNDfs SOUNDabsstarttime label props] = egl_AA_daq(filename, 1); 
        SOUNDdur = numel(SOUNDdata)/SOUNDfs; 

        % from inscopix file
        filename = char(XLS.textdata.Sheet1(row,strmatch('InscopixFilename', Columns))); 
        VIDEOabsstarttime = datenum(filename((end-14):end), 'yyyymmdd_HHMMSS');
        VIDEOfs = 20 % see .xml file, check it's 20
        tiffInfo = imfinfo([filename '.tif']); 
        nFrames = numel(tiffInfo);
        VIDEOdur = nFrames/VIDEOfs; 
        Mov = imread([filename '.tif']);
        VIDEOdata = zeros(nFrames, tiffInfo(1).Height, tiffInfo(1).Width); 

        % load all the frames
        tic
        for i = 1:nFrames
            VIDEOdata(i,:,:) = imread([filename '.tif'], i);
        end
        toc
        filename = fullfile('Q:\GCaMP',['5616GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS')])
        save(filename, 'SOUNDdata', 'SOUNDfs', 'SOUNDabsstarttime', 'SOUNDdur',...
            'VIDEOabsstarttime', 'VIDEOfs', 'tiffInfo', 'nFrames', 'VIDEOdur', ...
            'Mov', 'VIDEOdata', '-v7.3')
        display('saved data')
    else
        filename1 = char(XLS.textdata.Sheet1(row,strmatch('InscopixFilename', Columns))); 
        VIDEOabsstarttime = datenum(filename1((end-14):end), 'yyyymmdd_HHMMSS');
        filename = fullfile('Q:\GCaMP',['5616GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS')])
        if 1~=XLS.data.Sheet1(row,strmatch('MatlabDatafilename', Columns)) 
            filename = char(XLS.textdata.Sheet1(row,strmatch('MatlabDatafilename', Columns))); 
        end
        load(filename); 
    end
    display('compiled data')
    %% make some ROIs (or, skip this and load previous ROIs)
    figure(3); clf; colormap gray;shg
    smallVdata = VIDEOdata(1:min(150, size(VIDEOdata,1)),:,:); % just beginning so it takes less time
    mSubTime = bsxfun(@minus,smallVdata,median(smallVdata,1)); 
    mSubPixel = bsxfun(@minus, mSubTime, median(median(mSubTime,2),3)); 
    plotForRois = squeeze(prctile(mSubPixel,99, 1)); % max proj
    plotForRois((plotForRois-mean(plotForRois(:)))>4*std(plotForRois(:))) = mean(plotForRois(:)); % throw out noise/dead pixels
    
%     
%     imagesc(plotForRois)
%     axis equal; axis off
%     hold on
%     clicking = 1; 
%     x = []; 
%     y = []; 
%     i = 1; 
%     while clicking
%         [x(i),y(i)] = ginput(1);
%         plot(x(i),y(i), 'r.') 
%         if x(i)<0 | y(i)<0
%             x = x(1:end-1); y = y(1:end-1); 
%             clicking = 0;
%         end
%         i = i+1;
%     end
%     ROIx = x; 
%     ROIy = y; 
    %% save ROIs (or load old ones)
    %save C:\Users\emackev\Documents\MATLAB\FirstCalciumImagingROIs ROIx ROIy
    %save Q:\GCaMP\June19ROIs ROIx ROIy
    filenameroi = char(XLS.textdata.Sheet1(row,strmatch('ROIfilename', Columns))); 
    load(filenameroi); 
    
    %% plot ROIs

    clf; colormap gray
    imagesc(plotForRois, [0 300])
    hold on; axis equal; axis off
    umPerPixel = 900/1440; 
    plot(50+[0 100]/umPerPixel, [50 50],  'color', [1 1 1])
    text(mean(50+[0 100]/umPerPixel), [50], '100 um','color', [1 1 1],'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
    roicolors = lines(length(ROIx)); 
    for roi = 1:length(ROIx)
        xs = ROIx(roi) + [-20 20 20 -20 -20]; 
        ys = ROIy(roi) + [-20 -20 20 20 -20]; 
        patch(xs, ys, roicolors(roi,:), 'edgecolor', roicolors(roi,:), 'facecolor', 'none'); 
    end
    savefig(fullfile('Q:\GCaMP', ['ROIs5616GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS')]))

    %% calculating delta F over F (following Jia et al Nature Protocols 2011)

    roiWin = 20; % size of each ROI in pixels

    % parameters
    tau0 = .2; 
    tau1 = .75; 
    tau2 = 3; 

    % initialize 
    F = zeros(length(ROIx), nFrames);
    F0 = zeros(length(ROIx), nFrames);
    DFF = zeros(length(ROIx), nFrames);
    DFFmedFil = zeros(length(ROIx), nFrames);

    % Calculate the F(t) for each ROI
    for roi = 1:length(ROIx)
        for fi = 1:nFrames
            F(roi,fi) = sum(sum(VIDEOdata(fi, ...
                abs((1:tiffInfo(1).Height)-ROIx(roi))<roiWin, abs((1:tiffInfo(1).Width)-ROIx(roi))<roiWin))); 
        end
    end

    % Calculate the time-dependent baseline F0(t) for each ROI
    for roi = 1:length(ROIx)
        Fbar = smooth(F(roi,:), tau1*VIDEOfs); 
        F0(:,1) = F(:,1); % so don't divide by 0
        for fi = 2:nFrames
            win = max(1, (fi-tau2*VIDEOfs)):(fi-1); 
            F0(roi,fi) = min(Fbar(win)); 
        end
    end

    % Calculate the relative change of fluorescence signal R(t) from F and F0
    R = (F - F0)./F0; 

    % Apply noise filtering 
    for fi = 1:nFrames
        w = exp(-(1:fi)/(tau0*VIDEOfs)); 
        w = repmat(w(:)', length(ROIx),1); 
        DFF(:,fi) = sum(R(:,fi:-1:1).*w,2)./sum(w,2); 
        DFFmedFil(:,fi) = median(R(:,abs((1:nFrames)-fi)<(tau0*VIDEOfs)),2);
    end
    display('calculated deltaF/F')
    %% plot deltaF/F (or raw F) for each ROI

    % Calculating indices and time vectors for time alignment 
    secInDay = 24*60*60;
    start_time = min(VIDEOabsstarttime,SOUNDabsstarttime); 
    end_time = max(VIDEOabsstarttime+VIDEOdur/secInDay, SOUNDabsstarttime+SOUNDdur/secInDay); 
    % Vind = ceil((1:nFrames) + (start_time - VIDEOabsstarttime)*secInDay*VIDEOfs);
    % Sind = ceil((1:length(SOUNDdata)) + (start_time - SOUNDabsstarttime)*secInDay*SOUNDfs);
    % Vind = Vind(Vind>0&Vind<size(VIDEOdata,1)*VIDEOfs); 
    % Sind = Sind(Sind>0&Sind<length(SOUNDdata)*SOUNDfs); 
    tMovie = (1:nFrames)/VIDEOfs + (VIDEOabsstarttime - start_time)*secInDay; 
    tSound = (1:length(SOUNDdata))/SOUNDfs + (SOUNDabsstarttime - start_time)*secInDay;

    figure(3); clf; title(filename); 
    % plot song
    g = subplot(9,1,9)
    plot(tSound(:), SOUNDdata(:), 'k')
    box off; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
    xlabel('Time (s)')

    % plot F
    h = subplot(9,1,1:4); cla
    
    yspace = .005; 
    hold on
    for roi = 1:length(ROIx)
        plot(tMovie,F(roi,:)- F(roi,1) + (roi-1)*yspace*3e6, 'color', roicolors(roi,:))
    end
    ylabel('F (au)');
    box off; axis tight
    set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])


    % plot deltaF/F
    k = subplot(9,1,5:8); cla
    roicolors = lines(length(ROIx)); 
    yspace = .005; 
    hold on
    for roi = 1:length(ROIx)
        %plot(tMovie,F(roi,:)- F(roi,1) + (roi-1)*yspace*3e6, 'color', roicolors(roi,:))
        plot(tMovie,DFFmedFil(roi,:)+(roi-1)*yspace, 'color', roicolors(roi,:))
    end
    box off; axis tight
    set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
    ylabel('deltaF/F (au)')
    linkaxes([h g k], 'x'); 
    suptitle(['GCaMP ' datestr(VIDEOabsstarttime)])
    set(gcf, 'papersize', [5 8], 'paperposition',[0 0 5 8])
    shg

    savefig(fullfile('Q:\GCaMP', ['5616GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS')]))
    display('saved figure')
    %% Making movie

    plotROIs = 0; 

    figure(23); shg; set(gcf, 'color', [1 1 1])

    nMovFrames = (end_time - start_time)*secInDay*VIDEOfs; 
    SpecWinInd = round((-.5:1/SOUNDfs:.5)*SOUNDfs); 
    meanVIDEO = squeeze(median(VIDEOdata,1)); 

    %
    folder = 'Q:\GCaMP';
    timestamp = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    filename = ['5616GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS') 'Saved' timestamp];
    obj = vision.VideoFileWriter(fullfile(folder, [filename, '.avi']), 'AudioInputPort', 1);%,  'fps', 20);
    obj.FrameRate = 20; 

    for framei = 1:nMovFrames
        Vind = ceil(framei + (start_time - VIDEOabsstarttime)*secInDay*VIDEOfs);
        Sind = ceil(framei*SOUNDfs/VIDEOfs + (start_time - SOUNDabsstarttime)*secInDay*SOUNDfs);
        Aud = zeros(round(SOUNDfs/VIDEOfs),2); 
        % plot image
        subplot(4,1,1:3); cla; 
        set(gca, 'ydir', 'reverse')
        if Vind>0 & Vind<=nFrames
            % If doing median
            clims = [-100 200];
            imagesc(squeeze(VIDEOdata(Vind,:,:))-meanVIDEO, clims)
            hold on
            umPerPixel = 900/1440; 
            plot(50+[0 100]/umPerPixel, [50 50],  'color', [1 1 1])
            text(mean(50+[0 100]/umPerPixel), [50], '100 um','color', [1 1 1],'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')

            % If doing raw
    %         clims = [0 950];
    %         imagesc(squeeze(VIDEOdata(Vind,:,:)), clims)
            if plotROIs
                scatter(ROIx,ROIy, 5+DFF(:,Vind).*(DFF(:,Vind)>0)*60000, lines(length(ROIx))); 
            end
            colormap gray; axis equal; axis off
        else
            text(0,0, 'waiting for video data')
        end
            
        % plot spectrogram
        subplot(4,1,4); cla; 
        indplot = Sind + SpecWinInd;
        tdata = SpecWinInd(indplot>=1 & indplot<numel(SOUNDdata));
        indplot = indplot(indplot>=1 & indplot<numel(SOUNDdata)); 
        sdata = SOUNDdata(indplot);
        if numel(sdata) > 0
            displaySpecgramQuick(sdata, SOUNDfs, [0 8000], [-8 8], tdata(1)/SOUNDfs)
            cmap = gray; 
            cmap(1,:) = [0 0 0]; 
            colormap(cmap)
        end
        xlim([SpecWinInd(1) SpecWinInd(end)]/SOUNDfs)
        box off
        set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
        hold on; plot([0 0], [0 8000], 'r')

        % write to video
        F = getframe(gcf);
        if Sind>0&Sind<(numel(SOUNDdata) - round(SOUNDfs/VIDEOfs))
            Aud = [SOUNDdata(Sind:(Sind+round(SOUNDfs/VIDEOfs)-1)) ...
                SOUNDdata(Sind:(Sind+round(SOUNDfs/VIDEOfs)-1))]; 
        end
        step(obj, F.cdata, Aud)
    end

    release(obj); 
    display('saved movie')
    %% save data

end













%% downsample video data
% dsf = 10; 
% newH = floor(tiffInfo(1).Height/dsf);
% newW = floor(tiffInfo(1).Width/dsf);
% 
% ksize = dsf; 
% % x1 = 1:ksize; x2 = 1:ksize; [X1,X2] = meshgrid(x1,x2);
% % kernel = reshape(mvnpdf([X1(:) X2(:)], [ksize/2 ksize/2], [dsf/2 0; 0 dsf/2]),ksize,ksize); 
% kernel = ones(ksize,ksize)/dsf/dsf; 
% 
% % 
% smallV = zeros(nFrames, newH, newW); 
% % for each frame
% for fi = 1:nFrames
%     tmp = conv2(squeeze(VIDEOdata(fi,:,:)), kernel, 'same'); 
%     tmp = downsample(tmp, dsf); 
%     tmp = downsample(tmp', dsf)';
%     smallV(fi,:,:) = tmp; 
% end
% % smooth
% % downsample
% 
% %nFrames, tiffInfo(1).Height, tiffInfo(1).Width
% VIDEOmatrix = reshape(smallV, nFrames, newH*newW)'; 
% VIDEOmatrix = bsxfun(@minus, VIDEOmatrix, mean(VIDEOmatrix,2)); 
% maxproj = max(VIDEOmatrix,[],2);
%% create a masked version (only active pixels)
% mask = zeros(newH*newW,1);  
% ksize = 10; 
% % x1 = 1:ksize; x2 = 1:ksize; [X1,X2] = meshgrid(x1,x2);
% % kernel = reshape(mvnpdf([X1(:) X2(:)], [ksize/2 ksize/2], [3 0; 0 3]),ksize,ksize); 
% 
% mask(maxproj>40) = 1;
% %mask = maxproj;
% figure(2); imagesc(reshape(mask, newH, newW))
%VIDEOmatrix(VIDEOmatrix<0) = 0; 
% 
% maskedM = VIDEOmatrix(mask==1,:); 
% 
% tmpFrame = VIDEOmatrix(:,1); 
% tmpFrame(mask==0) = 0; 
% tmpFrame(mask==1) = maskedM(:,1).*(mod(1:length(maskedM(:,1)), 5)==1)'; % just testing coordinate transform is working
% imagesc(reshape(tmpFrame, newH, newW))

%% PCA...
% C = maskedM*maskedM'; imagesc(C)
% %%
% [U,S,V] = svd(C); 
% %%
% tmpFrame = VIDEOmatrix(:,1); 
% tmpFrame(mask==0) = 0; 
% indplot = 10:18
% figure(2)
% for i = indplot
%     subplot(3,3,i-indplot(1)+1)
%     tmpFrame(mask==1) = maskedM(:,1).*U(:,i); 
%     imagesc(reshape(tmpFrame, newH, newW))
% end
