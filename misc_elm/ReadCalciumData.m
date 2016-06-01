for row = [182:-1:181];
    display(row)
    clearvars -except row
    %% load and compile data 

    % from excel
    XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/CalciumData.xlsx');
    XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
    Columns = XLS.textdata.Sheet1(1,:);
    %SINGING = XLS.data.Sheet1(row,strmatch('Singing?', Columns))==1;
    birdname = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns))); 

    % if I've already compiled it, just load MATLAB
    if 0==length(char(XLS.textdata.Sheet1(row,strmatch('MatlabDatafilename', Columns))));
        % song from acq qui
        filename = char(XLS.textdata.Sheet1(row,strmatch('AcqGuiFilename', Columns))); 
        birdname = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns))); 
        [SOUNDdata SOUNDfs SOUNDabsstarttime label props] = egl_AA_daq(filename, 1); 
        SOUNDdur = numel(SOUNDdata)/SOUNDfs; 
        
        % sync channel from acqqui 
        filenamesync = filename; filenamesync(end-4) = '5';
        [SYNCdata SOUNDfs SOUNDabsstarttime label props] = egl_AA_daq(filenamesync, 1); 

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
            VIDEOdata(i,:,:) = imread([filename '.tif'], i, 'info', tiffInfo);
            if mod(i,50)==0; display(['loaded ' num2str(i) ' frames']); end
        end
        toc
        filename = fullfile('\\feebox6\shared\emackev\GCaMP',[birdname, 'GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS')])
        save(filename, 'SOUNDdata', 'SOUNDfs', 'SOUNDabsstarttime', 'SOUNDdur',...
            'VIDEOabsstarttime', 'VIDEOfs', 'tiffInfo', 'nFrames', 'VIDEOdur', ...
            'Mov', 'VIDEOdata', 'SYNCdata', '-v7.3')
        display('saved data')
    else
        filename1 = char(XLS.textdata.Sheet1(row,strmatch('InscopixFilename', Columns))); 
        VIDEOabsstarttime = datenum(filename1((end-14):end), 'yyyymmdd_HHMMSS');
        filename = fullfile('\\feebox6\shared\emackev\GCaMP',['GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS')])
        if 1~=XLS.data.Sheet1(row,strmatch('MatlabDatafilename', Columns)) 
            filename = char(XLS.textdata.Sheet1(row,strmatch('MatlabDatafilename', Columns))); 
        end
        load(filename); 
    end
    display('compiled data')
    %%
        % Calculating indices and time vectors for time alignment 
    secInDay = 24*60*60;
%     start_time = min(VIDEOabsstarttime,SOUNDabsstarttime); 
%     end_time = max(VIDEOabsstarttime+VIDEOdur/secInDay, SOUNDabsstarttime+SOUNDdur/secInDay); 
    
    %% Making movie

    

    figure(23); shg; set(gcf, 'color', [1 1 1])

    nMovFrames = size(VIDEOdata,1); %(end_time - start_time)*secInDay*VIDEOfs; 
    SpecWinInd = round((-.5:1/SOUNDfs:.5)*SOUNDfs); 
%     meanVIDEO = squeeze(median(VIDEOdata,1)); 
    AudBinWhenFrameStarts = find(diff(SYNCdata)>1); 
    if length(AudBinWhenFrameStarts)~=nMovFrames
        warning(['frame alignment mismatch, nMovFrames = ' num2str(nMovFrames) ...
            ', nAudFrames = ' num2str(length(AudBinWhenFrameStarts))]); 
    end

    %
    folder = '\\feebox6\shared\emackev\GCaMP';
    timestamp = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    filename = [birdname 'GCaMP' datestr(VIDEOabsstarttime, 'dd-mmm-yyyy-HH-MM-SS') 'Saved' timestamp];
    obj = vision.VideoFileWriter(fullfile(folder, [filename, '.avi']), 'AudioInputPort', 1);%,  'fps', 20);
    obj.FrameRate = 20; 
    % if doing raw
    subsamp = VIDEOdata(1:10000:end); 
    clims = [prctile(subsamp, .01) prctile(subsamp, 99.999)]; % not max to avoid dead pixels

    for framei = 1:nMovFrames
        Vind = framei; 
        Sind = AudBinWhenFrameStarts(framei); 
%         Vind = ceil(framei + (start_time - VIDEOabsstarttime)*secInDay*VIDEOfs);
%         Sind = ceil(framei*SOUNDfs/VIDEOfs + (start_time - SOUNDabsstarttime)*secInDay*SOUNDfs);
        Aud = zeros(round(SOUNDfs/VIDEOfs),2); 
        % plot image
        subplot(4,1,1:3); cla; 
        set(gca, 'ydir', 'reverse')
%             % If doing median
%             clims = [-100 200];
%             imagesc(squeeze(VIDEOdata(Vind,:,:))-meanVIDEO, clims)
%             hold on
%             umPerPixel = 900/1440; 
%             plot(50+[0 100]/umPerPixel, [50 50],  'color', [1 1 1])
%             text(mean(50+[0 100]/umPerPixel), [50], '100 um','color', [1 1 1],'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')

%             If doing raw
%             clims = [0 950];
        imagesc(squeeze(VIDEOdata(Vind,:,:)), clims)
        colormap gray; axis equal; axis off

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
        if framei<nMovFrames
            Aud = [SOUNDdata(Sind:(Sind+round(SOUNDfs/VIDEOfs)-1)) ...
                SOUNDdata(Sind:(Sind+round(SOUNDfs/VIDEOfs)-1))]; 
        end
        step(obj, F.cdata, Aud)
    end

    release(obj); 
    display('saved movie')
    sound(sin(1:1000)); 
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
