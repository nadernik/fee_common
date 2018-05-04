function [indSeqSort, nColors, baselines] = cnmfe2raster(DataFolder, cnmfeFilePath, LabelCanon, moat, indSeqSort)
%%
if nargin<5
    indSeqSort = []; 
end
    load(cnmfeFilePath, 'neuron'); 
    load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs', 'SOUNDfs', 'CompSoundSONG', 'FnumBnum');
    if ~exist('SOUNDfs')
        SOUNDfs = 40000; 
    end
    
    mstart = []; 
    msegs = zeros(length(LabelCanon),2,0); 
    params.WantTheseLabels = LabelCanon;
    for li = 1:length(Labels)-length(LabelCanon)
        params.Method = 'labels'; 
        params.CheckTheseLabels = Labels(li:li+length(LabelCanon)-1); 
        if MotifCheck(params) & (segs(li,1)/40000-moat)*VIDEOfs> 0 & (segs(li,2)/40000+moat)*VIDEOfs<size(neuron.C,2)
            mstart = [mstart li];
            msegs = cat(3,msegs, segs(li:li+length(LabelCanon)-1,:)); 
        end
    end
    % find average dur of each syllable and gap
    DurSylCanon = mean(squeeze(diff(msegs,[],2)),2)/SOUNDfs; 
    DurGapCanon = mean(squeeze(diff([msegs(1:end-1,2) msegs(2:end,1)],[],2)),2)/SOUNDfs; 
    tmp = cumsum(reshape([DurSylCanon'; [DurGapCanon' 0]],1,2*length(DurSylCanon))); 
    DesiredSegTimes = [-moat 0 ...
        tmp(1:end-1)...
        sum(DurSylCanon)+sum(DurGapCanon)+moat];
    upFac = 30/5; 
    tCanon = (-moat*VIDEOfs*upFac:(sum(DurSylCanon)+sum(DurGapCanon)+moat)*VIDEOfs*upFac)/VIDEOfs/upFac; 
    % make a new matrix Nneurons X Nmotifs X Tmotif
    [Nneurons,TotalDur] = size(neuron.C);
%     mstart = mstart(1:3); %FOR DEBUGGINGs
%     tmp = find(FnumBnum(ceil(segs(:,1)*VIDEOfs/SOUNDfs),1)<=5); % FOR DEBUGGING
%     mstart(mstart>tmp(end)) = []; % FOR DEBUGGING
    Nmotifs = length(mstart); 
    Tmotif = length(tCanon); 
    ByMotif = zeros(Nneurons,Nmotifs,Tmotif);
    UpC = spline((1:TotalDur)/VIDEOfs, neuron.C, 1/VIDEOfs:1/VIDEOfs/upFac:(TotalDur)/VIDEOfs); 
    for mi = 1:length(mstart)
        tIndUnwarped = max(1,round((segs(mstart(mi),1)/SOUNDfs-moat)*VIDEOfs*upFac)):...
            min(round((segs(mstart(mi)+length(LabelCanon)-1,2)/SOUNDfs+moat)*VIDEOfs*upFac),size(UpC,2));
        Unwarped = UpC(:,tIndUnwarped);
        UnwarpedSegTimes = [-moat reshape(segs(mstart(mi):mstart(mi)+length(LabelCanon)-1,:)'-segs(mstart(mi),1),1,2*length(LabelCanon))/SOUNDfs ...
            (segs(mstart(mi)+length(LabelCanon)-1,2)-segs(mstart(mi),1))/SOUNDfs+moat];
        DesUnwarpedTimes = TimeWarp_elm(tCanon, DesiredSegTimes, UnwarpedSegTimes);
        for ni = 1:Nneurons
            if length(tIndUnwarped)>0
                ByMotif(ni,mi,:) = spline((tIndUnwarped/VIDEOfs/upFac-segs(mstart(mi),1)/SOUNDfs), Unwarped(ni,:),DesUnwarpedTimes);
            end
        end
        if mi == 1
            sampsong = CompSoundSONG(floor(tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac)); 
%             sampsong = 0*floor(tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac); 
        end
    end

    I = [];
    mproj = reshape(sum(neuron.A,2),300,400); imagesc(mproj)
    clf
    % for ni = 1:size(ByMotif,1)
    % %     plot(squeeze(sum(ByMotif(ni,:,:),2)), ); hold on
    % %     psth = squeeze(mean(ByMotif(ni,:,:),2));
    % %     I(ni) = anova1(squeeze(ByMotif(ni,:,:)),[],'off'); %(max(psth)-median(psth))/max(psth); 
    % %     I(ni) = sum(ByMotif(ni,:));
    %     subplot(2,1,1); imagesc(mproj); hold on; contour(reshape(neuron.A(:,ni),300,400), 'r'); colormap(flipud(gray))
    %     subplot(2,1,2); 
    %     imagesc(squeeze(ByMotif(ni,:,:)), [0 max(squeeze(ByMotif(ni,:)))]); hold on
    % %     colormap(flipud(gray)); clf
    %     shg
    %     I(ni) = input('Keep this neuron? 1 or 0');
    % end
    % % save(fullfile(dbasepath, 'selectedneurons'), 'I');

    
    if length(indSeqSort)==0
        [~,tmax] = max(squeeze(median(ByMotif(:,:,tCanon>-.05&tCanon<(tCanon(end)-moat)),2)),[],2);
        [~,indSeqSort] = sort(tmax); 
    end
    % indSeqSort(I<.5) = []; Nneurons = length(indSeqSort);
    neuron.C = neuron.C(indSeqSort,:); 
    neuron.A = neuron.A(:,indSeqSort); 
    Nneurons = size(neuron.C,1);
    clims = [0 10]; 
    h(1) = subplot('position', [.1 .8 .8 .1]);
    spectrogramELM(sampsong, SOUNDfs, .002, 1);
    axis off
    h(2) = subplot('position', [.1 .1 .8 .7]);
    
    AllMotifs = reshape(permute(ByMotif(indSeqSort,:,:),[2 1 3]),Nneurons*Nmotifs,length(tCanon)); 
    color_palet = 1-[[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
    color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
    nColors = color_palet(mod(1:(Nneurons),size(color_palet,1))+1,:); 
    satPrc = 98;
    baselinesByMotif = mean(AllMotifs,2);
    baselines = mean(reshape(baselinesByMotif,Nmotifs,Nneurons),1)'; % mean of each neuron within raster
    baselinesRepeated = reshape(repmat(baselines,1,Nmotifs)',Nmotifs*Nneurons,1); 
    AllMotifs = bsxfun(@minus, AllMotifs, baselinesByMotif); % renormalizing by each motif's baseline looks better
    AllMotifs(AllMotifs>prctile(AllMotifs(:),satPrc)) = prctile(AllMotifs(:),satPrc);
    ColoredAllMotifs = cat(3,...
        repmat(reshape(repmat(nColors(:,1)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs,...
        repmat(reshape(repmat(nColors(:,2)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs,...
        repmat(reshape(repmat(nColors(:,3)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs);
    image(1-ColoredAllMotifs/max(ColoredAllMotifs(:)),'xdata', tCanon+moat, 'ydata', .5+(0:Nneurons))
    cmap = flipud(bone); flipud(gray); 
    cmap(1,:) = ones(1,3); colormap(cmap); shg
    
    % jet coloring
%     imagesc(AllMotifs, 'xdata', tCanon+moat, 'ydata', .5+(0:Nneurons),...
%         [prctile(AllMotifs(:),50) prctile(AllMotifs(:),100)])
%     colormap jet
    
    xlabel('Time (s, warped)')
    ylabel('Neuron #')
    hold on

    for syli = 1:length(DesiredSegTimes)
        plot(DesiredSegTimes(syli)*ones(1,2)+moat, [.5 Nneurons+.5], 'k:')
        plot(DesiredSegTimes(syli)*ones(1,2)+moat, [.5 Nneurons+.5], 'k:')
    end

    shg
    linkaxes(h,'x')
    set(gca,'color','none','tickdir','out','ticklength', [0.01, 0.01])
    papersize = [4 5]
    set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
    tmp = sum(AllMotifs,1); tmp = tmp-min(tmp); tmp = tmp/max(tmp)*6; 
%     subplot(h(1)); hold on; plot(tCanon+moat,tmp, 'r')

    axis tight


    end