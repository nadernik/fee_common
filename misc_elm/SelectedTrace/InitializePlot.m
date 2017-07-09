
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
        Tit = title([nam '; ' ...
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
%        tmp1 = tmp(:,~isnan(sum(tmp,1))); % not including file borders. line126
%        baselines = min(tmp1,[],2); 
%        tmp = bsxfun(@minus, tmp, baselines); 
%        tmp = bsxfun(@rdivide, (tmp-clims(1)), max(diff(clims), max(tmp,[],2)));
%        tmp = 3*tmp/4; 
        tmp(isnan(tmp)) = 0; % file borders
%        tmp = bsxfun(@plus, tmp, (1:size(tmp,1))');
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