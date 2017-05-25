function selectedTraces(DataFolder, cnmfeFilePath, indSeqSort, nColors, ExtraMatrixToPlot, ExtraMatY, ExtraPlotYLabel)
%%
    
    if nargin<5; ExtraMatrixToPlot = []; end
    if nargin<6; ExtraMatY = 1:size(ExtraMatrixToPlot,1); end
    if nargin<7; ExtraPlotYLabel = ''; end
    
    % to make it faster, consider make song spectrogram ahead of time
    variableInfo = who('-file', fullfile(DataFolder, 'compiled.mat'));
    if ~ismember('SongSpec', variableInfo) 
        display('need to compute song spectrogram... only need to do this once... could take about a minute')
        load(fullfile(DataFolder, 'compiled.mat'), 'CompSoundSONG', 'SOUNDfs')
        display('loaded song')
        tic; [SongSpec,SpecTime,SpecF] = spectrogramELM(CompSoundSONG,SOUNDfs,.005, 0); toc
        SongSpec = 10*log10(SongSpec); 
        display('computed spectrogram')
        save(fullfile(DataFolder, 'compiled.mat'), 'SongSpec', 'SpecTime', 'SpecF', ...
            '-append');
        display('saved spectrogram')
    end
    AddGcampDataTimestamps(DataFolder); % compute

    
    % load song data
    global istart w pressed patches h SpecIm ExtraIm Tit npat ...
        slines1 slines2 dbase FnumBnum Timestamps; 

    load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs',...
            'SOUNDfs', 'SongSpec','SpecTime','SpecF', 'FnumBnum', 'Timestamps');
    load(fullfile(DataFolder, 'analysis.mat')); 
    SongSpec = SongSpec + eps; 
    SongSpec(SongSpec(:)<prctile(SongSpec(:),75)) = prctile(SongSpec(:),75);   
    display('loaded data')
    
    % load extracted neurons from path, or take variable from function
    % input
    if ischar(cnmfeFilePath)
        load(cnmfeFilePath, 'neuron'); 
        PlotC = neuron.C;
    else
        PlotC = cnmfeFilePath;
    end
    
    if ~exist('SOUNDfs')
        SOUNDfs = 40000; 
    end
    
    % for stripes between files
    borders = find((diff([0; FnumBnum(:,1)])~=0)|(diff([0; FnumBnum(:,1)])~=0))-1; 
    PlotC(:,borders(borders>0)) = nan; 
    
    clims = [0 prctile(PlotC(:),99)]; %[3 25]; 

    patches = {};
    istart = 1; 
    stepdur = 150; 
    npat = {}; 
    slines1 = {}; 
    slines2 = {}; 
    
    figure(1); clf; shg; 
    set(gcf, 'color', [1 1 1])
    InitializePlot();
    
    fpos = get(gcf, 'Position');
    set(gcf, 'WindowKeyPressFcn', @ButtonWasPressed, 'busyaction', 'cancel', 'interruptible', 'off')
    mTextBox = uicontrol('style','edit', 'callback', @TextboxCallback, 'Position', [fpos(3)-80 fpos(4)-40 60 20]);
    set(mTextBox,'String',num2str(istart));
    
    function ButtonWasPressed(hObject, eventdata, handles)
        KeyPressed = eventdata.Key; 
        switch KeyPressed
            case 'rightarrow'
                istart = min(istart+stepdur/2, size(PlotC,2)-stepdur);
                set(mTextBox,'String',num2str(istart));
                UpdatePlot()
            case 'leftarrow'
                istart = max(istart-stepdur/2,1);
                set(mTextBox,'String',num2str(istart));
                UpdatePlot()
        end
    end

    function TextboxCallback(source,callbackdata)
        istart = str2num(callbackdata.Source.String);
        UpdatePlot()
    end

    function InitializePlot
        % spectrogram plot
        h(1) = subplot('position', [.1 .85 .8 .05]); cla
        indSpec = find(SpecTime>=(istart/VIDEOfs) & SpecTime<((istart+stepdur)/VIDEOfs));
        Plot = SongSpec(:,indSpec);
        Time = (1:length(indSpec))*(SpecTime(2)-SpecTime(1)); 
        SpecIm = imagesc(Time,SpecF/1000,Plot); axis tight; 
        cmap = jet; %flipud(gray); 
        % to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
        cmap(1,:) = zeros(1,3);
        colormap(cmap);
        set(gca, 'ydir', 'normal')
        [~,nam,~] = fileparts(DataFolder);   
        Tit = title([nam '; '  Timestamps{FnumBnum(istart,1)} '; ' ...
            num2str(istart) '/' num2str(size(PlotC,2))], 'interpreter', 'none'); 
        SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
            segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
        SegsInFrame(SegsInFrame<0) = 0;
        SegsInFrame(SegsInFrame>stepdur/VIDEOfs) = stepdur/VIDEOfs;
        hold on
        for syli = 1:size(SegsInFrame,1)
            patches{syli} = patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
                [6 6 6.5 6.5], 'k');
        end
        axis off
        
        % traces plot
        h(2) = subplot('position', [.1 .1 .8 .75]);
        cla; hold on; 
        tmp = PlotC(indSeqSort,istart:istart+stepdur-1); 
        tmp1 = tmp(:,~isnan(sum(tmp,1))); 
        baselines = min(tmp1,[],2); 
        tmp = bsxfun(@minus, tmp, baselines); 
        tmp = bsxfun(@rdivide, (tmp-clims(1)), max(diff(clims), max(tmp,[],2)));
        tmp = 3*tmp/4; 
        tmp(isnan(tmp)) = 0; % file borders
        tmp = bsxfun(@plus, tmp, (1:size(tmp,1))');
        set(gca, 'colororder', 1-nColors)
        steps = 1:stepdur; 
        for i = size(tmp,1):-1:1
            npat{i} = patch(([1 steps stepdur])/VIDEOfs, [i tmp(i,:) i], ...
                1-nColors(i,:), 'edgecolor', 'none', 'facealpha', .75);
        end
        for syli = 1:size(SegsInFrame,1)
            subplot(h(2))
            slines1{syli} = plot(SegsInFrame(syli,1)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1]);
            slines2{syli} = plot(SegsInFrame(syli,2)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1]);
        end
        ylabel('Unit'); %set(gca, 'ytick', 1:size(PlotC,1))
        xlabel('Time (s)')
        xlim([1 stepdur]/VIDEOfs)
        
        % extra plot, if applicable
        if length(ExtraMatrixToPlot)>0
            plotheight = .3;
            set(h(2), 'position', [.1 .1+plotheight .8 .75-plotheight]);
            h(3) = subplot('position', [.1 .1 .8 plotheight]);
            ExtraIm = imagesc((1:stepdur)/VIDEOfs, ExtraMatY, ...
                ExtraMatrixToPlot(:,istart:istart+stepdur-1), ...
                [min(ExtraMatrixToPlot(:)) max(ExtraMatrixToPlot(:))]);
            xlabel('Time (s)'); ylabel(ExtraPlotYLabel); 
            set(gca, 'ydir', 'normal')
        end
        axis tight
        linkaxes(h,'x'); 
    end
    function UpdatePlot
        % spectrogram plot
        subplot(h(1))
        indSpec = find(SpecTime>=(istart/VIDEOfs) & SpecTime<((istart+stepdur)/VIDEOfs));
        Plot = SongSpec(:,indSpec);      
        SpecIm.CData = Plot; axis tight; 
        [~,nam,~] = fileparts(DataFolder);
        fnam = dbase.SoundFiles(FnumBnum(istart,1)).name; 
        Tit.String = ([nam '; '  Timestamps{FnumBnum(istart,1)} '; ' num2str(istart) '/' num2str(size(PlotC,2))]); 
        for i = 1:length(patches)
            delete(patches{i}); 
            delete(slines1{i});
            delete(slines2{i});
        end
        SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
            segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
        SegsInFrame(SegsInFrame<0) = 0;
        SegsInFrame(SegsInFrame>stepdur/VIDEOfs) = stepdur/VIDEOfs;
     
        for syli = 1:size(SegsInFrame,1)
            patches{syli} = patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
                [6 6 6.5 6.5], 'k');
        end
        
        % traces plot
        subplot(h(2));
        tmp = PlotC(indSeqSort,istart:istart+stepdur-1); 
        tmp1 = tmp(:,~isnan(sum(tmp,1))); 
        baselines = min(tmp1,[],2); 
        tmp = bsxfun(@minus, tmp, baselines); 
        tmp = bsxfun(@rdivide, (tmp-clims(1)), max(diff(clims), max(tmp,[],2)));
        tmp = 3*tmp/4; 
        tmp(isnan(tmp)) = 0; % file borders
        tmp = bsxfun(@plus, tmp, (1:size(tmp,1))');
        steps = 1:stepdur; 
        for i = size(tmp,1):-1:1
            npat{i}.Vertices = [[1 steps stepdur]'/VIDEOfs [i tmp(i,:) i]'];
        end
        for syli = 1:size(SegsInFrame,1)
            subplot(h(2))
            slines1{syli} = plot(SegsInFrame(syli,1)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1]);
            slines2{syli} = plot(SegsInFrame(syli,2)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1]);
        end
        
        % extra plot, if applicable
        if length(ExtraMatrixToPlot)>0
            ExtraIm.CData = ExtraMatrixToPlot(:,istart:istart+stepdur-1);
        end
        drawnow; 
    end
end