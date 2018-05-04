function coloredTraces(DataFolder, cnmfeFilePath, indSeqSort, nColors)
%%
    load(cnmfeFilePath, 'neuron'); 
    load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs',...
        'SOUNDfs', 'CompSoundSONG', 'FnumBnum');
    
%     VIDEOfs = 30; 
%     warning('overwriting videofs.... remember to go back to original')
    
    if ~exist('SOUNDfs')
        SOUNDfs = 40000; 
    end
    
    % go through raw data
    clf; shg
    stepdur = 90; %180;

    PlotC = neuron.C;

    % for stripes between files
    borders = find((diff([0; FnumBnum(:,1)])~=0)|(diff([0; FnumBnum(:,1)])~=0))-1; 
    PlotC(:,borders(borders>0)) = nan; 
    
    
    clims = [0 prctile(neuron.C(:),95)]; %[3 25]; %99

    istart = 1; 
    while istart<size(PlotC,2)
        sampsong = CompSoundSONG(ceil(istart*SOUNDfs/VIDEOfs:(istart+stepdur)*SOUNDfs/VIDEOfs)); 
        h(1) = subplot('position', [.1 .85 .8 .05]);cla; hold on
        h(2) = subplot('position', [.1 .1 .8 .75]);cla; hold on
        
        subplot(h(1))
        spectrogramELM(sampsong, SOUNDfs, .002, 1); title([num2str(istart) '; file ' num2str(FnumBnum(istart,1))]); 
        SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
            segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
        hold on
        axis off
        
        % plotting neural activity
        subplot(h(2))
        tmp = PlotC(indSeqSort,istart:istart+stepdur-1); 
        tmp1 = tmp(:,~isnan(sum(tmp,1))); 
        baselines = median(tmp1,2); % overwriting given baselines
        tmp = bsxfun(@minus, tmp, baselines); 
        tmp(tmp<clims(1)) = clims(1); 
        tmp(tmp>clims(2)) = clims(2); 
        tmp = (tmp-clims(1))/diff(clims); 
       
        % colored neurons
        ColoredC = cat(3,...
            tmp.*repmat(nColors(:,1),1,stepdur),...
            tmp.*repmat(nColors(:,2),1,stepdur),...
            tmp.*repmat(nColors(:,3),1,stepdur));
        image(1-ColoredC, 'xdata', (1:stepdur)/VIDEOfs); 
        colormap(flipud(gray))
        
        % jet coloring
%         imagesc(tmp, 'xdata',(1:stepdur)/VIDEOfs,...
%             [prctile(tmp(:),50) prctile(tmp(:),100)])
%         colormap jet
        for syli = 1:size(SegsInFrame,1)
            subplot(h(1))
            patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
                [6 6 6.5 6.5], 'k')
            subplot(h(2))
            plot(SegsInFrame(syli,1)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1])
            plot(SegsInFrame(syli,2)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1])
        end
        set(gca, 'ydir', 'reverse'); ylabel('neuron')
        xlabel('Time (s)')
        linkaxes(h,'x'); 
        axis tight
        drawnow; shg;
        waitforbuttonpress;
        pressed=double(get(gcf,'CurrentCharacter')); 
        if length(pressed)>0
            switch pressed
                case 29% right
                    istart = min(istart+stepdur/2, size(PlotC,2));
                case 28 % left
                    istart = max(istart-stepdur/2,1);
            end 
        end
    end
end