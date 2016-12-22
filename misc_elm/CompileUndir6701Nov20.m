% 6701 prepost caf montage Nov 18 & 21 (precaf), Nov 29 & 30 (postcaf)

dbasepath = 'E:\ProcessedCalciumData\6701_Nov20'; 

load(fullfile(dbasepath, 'analysis.mat')); 
Y = [];
CompSoundSONG = [];
CompSpecSONG = [];
segs = []; 
FnumBnum = []; 
Labels = {};
moat = 3; 
save(fullfile(dbasepath, 'compiled'), 'Y', 'CompSoundSONG', 'CompSpecSONG',...
   '-v7.3')
ForMOCO = zeros(0,300,400);
for filei = 1:length(dbase.SegmentTimes)
    segtimes = dbase.SegmentTimes{filei}(dbase.SegmentIsSelected{filei}==1,:); 
    seglabels = dbase.SegmentTitles{filei}(dbase.SegmentIsSelected{filei}==1);
    load(fullfile(dbasepath, dbase.SoundFiles(filei).name), 'VIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
    % SONG
    if sum(dbase.SegmentIsSelected{filei}==1)>0
        bouts = SegsToBouts(segtimes, moat*SOUNDfs, length(SOUND)); 
        for bi = 1:size(bouts,1)
            useframes = round(bouts(bi,1)/SOUNDfs*VIDEOfs):...
                round(bouts(bi,2)/SOUNDfs*VIDEOfs); % which movie frames we're using
            useframes(useframes<=0) = []; useframes(useframes>nFrames) = []; 
            usebins = (1:floor(length(useframes)*40000/30))+AudBinWhenFrameStarts(useframes(1));% which audio bins we're using... 40000/30 has slight rounding error..
            if length(useframes)>0
                Y1 = permute(VIDEO(useframes,:,:),[2 3 1]); 
                Y = cat(3,Y,Y1); 
                % add sound clip to align w useframes
%                 roundingshift = round(AudBinWhenFrameStarts(useframes(1))+1) - bouts(bi,1);
                segs = [segs; ...
                    (segtimes((segtimes(:,1)>=usebins(1))&(segtimes(:,2)<=usebins(end)),:) ...
                    -usebins(1) + length(CompSoundSONG))];
%                     segtimes((segtimes(:,1)>bouts(bi,1))&(segtimes(:,2)<bouts(bi,2)),:) ...
%                     - bouts(bi,1)...
%                     + length(CompSoundSONG)...
%                     - roundingshift]; 
                Labels = [Labels seglabels((segtimes(:,1)>bouts(bi,1))&(segtimes(:,2)<bouts(bi,2)))];
                CompSoundSONG = [CompSoundSONG; SOUND(usebins)];
%               CompSoundSONG = [CompSoundSONG; SOUND(round((AudBinWhenFrameStarts(useframes(1)))+1):...
%                 (round(AudBinWhenFrameStarts(useframes(end)))+floor(SOUNDfs/VIDEOfs)))];
                CompSpecSONG = cat(1,CompSpecSONG,SPEC(useframes,:,:));
                FnumBnum = [FnumBnum; repmat([filei bi filei<=7],length(useframes),1)];
                display(['SONG file ' num2str(filei) ' bout ' num2str(bi)])
            end
            ForMOCO(end+1,:,:) = squeeze(max(VIDEO(useframes,:,:),[],1)); 
        end
    end
    save(fullfile(dbasepath, 'compiled'), 'ForMOCO','Y', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs',...
       '-v7.3'); % also saved background subtracted CompVidSONG
end
CompVidSONG = permute(Y,[3 1 2]); % back sub
save(fullfile(dbasepath, 'compiled'), 'ForMOCO','Y', 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs', ...
       '-v7.3'); % also saved CompVidSONG
% ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, [], [], 0)

%% save video
% clear all
% dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf';
% load(fullfile(dbasepath, 'compiled_moco'))
% % CompVidSONG = permute(Y,[3 1 2]);
% ShowCaVid(CompVidSONG(1:5771,:,:),CompSoundSONG,CompSpecSONG(1:5771,:,:),[],[],0);% 'E:\ProcessedCalciumData\6701_prepostcaf\compiled_moco_vid.avi', [], 0)
%% save highpass filter video
% clearvars -except CompVidSONG CompSoundSONG CompSpecSONG
% for k = 2:size(CompVidSONG,1)
%     A = squeeze(CompVidSONG(k,:,:));
%     A = abs(A-imgaussfilt(A,15));
% end

%% save tiff
load(fullfile(dbasepath, 'compiled'), 'ForMOCO')

V = ForMOCO;
A = squeeze(V(1,:,:));
A = abs(A-imgaussfilt(A,15));
imwrite(A/max(A(:)), fullfile(dbasepath, 'compiledForMOCO.tif'))
for k = 2:size(V,1)
    A = squeeze(V(k,:,:));
    A = abs(A-imgaussfilt(A,15));
    imwrite(A/max(A(:)), fullfile(dbasepath, 'compiledForMOCO.tif'), 'writemode', 'append');
end

%% CNMFE
% run CNMFEscript on openmind
%% plot raster
clear all; close all

% for prepost moco
% dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\ForOpenMind\cnmfe_results_moco';
% load(saveherecnmfe, 'neuron'); 
% load(fullfile(dbasepath, 'compiled_moco.mat'), 'Labels', 'segs', 'VIDEOfs', 'CompSoundSONG');

% for Nov 20 data
dbasepath = 'E:\ProcessedCalciumData\6701_Nov20'; 
saveherecnmfe = 'C:\Users\emackev\Documents\ForOpenMind\cnmfe_results';
load(saveherecnmfe, 'neuron'); 
load(fullfile(dbasepath, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs', 'CompSoundSONG');

% find full motifs
LabelCanon = {'A' 'B' 'C' 'D' 'E'}; 
SOUNDfs = 40000; 
% VIDEOfs = 20; 
moat = 1; 
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
Nmotifs = length(mstart); 
Tmotif = length(tCanon); 
ByMotif = zeros(Nneurons,Nmotifs,Tmotif);
UpC = spline((1:TotalDur)/VIDEOfs, neuron.C, 1/VIDEOfs:1/VIDEOfs/upFac:(TotalDur)/VIDEOfs); 
% UpC(3,round(segs(:)/SOUNDfs*VIDEOfs*upFac))=100; % for debugging
for mi = 1:length(mstart)
    tIndUnwarped = max(1,round((segs(mstart(mi),1)/SOUNDfs-moat)*VIDEOfs*upFac)):...
        min(round((segs(mstart(mi)+length(LabelCanon)-1,2)/SOUNDfs+moat)*VIDEOfs*upFac),size(UpC,2));
    Unwarped = UpC(:,tIndUnwarped);
    UnwarpedSegTimes = [-moat reshape(segs(mstart(mi):mstart(mi)+length(LabelCanon)-1,:)'-segs(mstart(mi),1),1,2*length(LabelCanon))/SOUNDfs ...
        (segs(mstart(mi)+length(LabelCanon)-1,2)-segs(mstart(mi),1))/SOUNDfs+moat];
%     warpedSpiketimes = TimeWarp_elm(Spiketimes, ActualSegTimes, DesiredSegTimes)
    DesUnwarpedTimes = TimeWarp_elm(tCanon, DesiredSegTimes, UnwarpedSegTimes);
    for ni = 1:Nneurons
        if length(tIndUnwarped)>0
            ByMotif(ni,mi,:) = spline((tIndUnwarped/VIDEOfs/upFac-segs(mstart(mi),1)/SOUNDfs), Unwarped(ni,:),DesUnwarpedTimes);
        end
    end
    if mi == 2
        sampsong = CompSoundSONG(floor((tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac))); 
    end
%     clf; subplot(4,1,1); displaySpecgramQuick(CompSoundSONG(tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac), SOUNDfs)
%     subplot(4,1,2:4); imagesc(squeeze(ByMotif(:,mi,:))); colormap(flipud(gray)); pause
    %     ByMotif(:,mi,:) = neuron.C(:,
end
% imagesc reshaped matrix, and/or average matrix
% GravCent = bsxfun(@rdivide, sum(squeeze(median(ByMotif,2)).*repmat(tCanon,Nneurons,1),2),...
%     sum(squeeze(median(ByMotif,2)),2)); 
% [~,ind] = sort(GravCent);

% exclude bad (noisy) motifs
% exclude bad (non song-locked) neurons
% figure
% I = [];
% mproj = reshape(sum(neuron.A,2),300,400); imagesc(mproj)
% clf
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
% save(fullfile(dbasepath, 'selectedneurons'), 'I');

premotifdur = .5;%.05
[~,tmax] = max(squeeze(median(ByMotif(:,:,tCanon>-premotifdur&tCanon<(tCanon(end)-moat)),2)),[],2);
[~,indSeqSort] = sort(tmax); 
% indSeqSort(I<.5) = []; Nneurons = length(indSeqSort);
neuron.C = neuron.C(indSeqSort,:); 
neuron.A = neuron.A(:,indSeqSort); 
clims = [0 10]; 
h(1) = subplot('position', [.1 .8 .8 .1]);
spectrogramELM(sampsong, SOUNDfs, .002, 1);
axis off
h(2) = subplot('position', [.1 .1 .8 .7]);
AllMotifs = reshape(permute(ByMotif(indSeqSort,:,:),[2 1 3]),Nneurons*Nmotifs,length(tCanon)); 
color_palet = 1-[[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
nColors = color_palet(mod(1:(Nneurons),size(color_palet,1))+1,:); 
satPrc = 95;
AllMotifs(AllMotifs>prctile(AllMotifs(:),satPrc)) = prctile(AllMotifs(:),satPrc);
% AllMotifs(AllMotifs<0) = 0; 
ColoredAllMotifs = cat(3,...
    repmat(reshape(repmat(nColors(:,1)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs,...
    repmat(reshape(repmat(nColors(:,2)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs,...
    repmat(reshape(repmat(nColors(:,3)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs);
image(1-ColoredAllMotifs/max(ColoredAllMotifs(:)),'xdata', tCanon+moat, 'ydata', .5+(0:Nneurons))
xlabel('Time (s, warped)')
ylabel('Neuron #')
% axis off
hold on
% set(gca, 'ytick', [])
% for ni = 1:Nneurons
%     text(0, Nmotifs*(indSeqSort(ni)-.5),num2str(indSeqSort(ni)), 'verticalalignment', 'middle',...
%         'horizontalalignment', 'right','color', nColors(indSeqSort(ni),:))
%     plot(tCanon+moat, tCanon*0 + Nmotifs*ni, 'r')
% end
for syli = 1:length(DesiredSegTimes)
    plot(DesiredSegTimes(syli)*ones(1,2)+moat, [.5 Nneurons+.5], 'k:')
    plot(DesiredSegTimes(syli)*ones(1,2)+moat, [.5 Nneurons+.5], 'k:')
end
shg
linkaxes(h,'x')
cmap = flipud(bone); flipud(gray); 
cmap(1,:) = ones(1,3); colormap(cmap); shg
set(gca,'color','none','tickdir','out','ticklength', [0.01, 0.01])
set(gcf, 'papersize', [8.5 11], 'paperposition', [0 0 8.5 11])
tmp = sum(AllMotifs,1); tmp = tmp-min(tmp); tmp = tmp/max(tmp)*6; 
subplot(h(1)); hold on; plot(tCanon+moat,tmp, 'r')
% imagesc(squeeze(median(ByMotif,2)))
% decide how to sort
% colormap(flipud(gray))
axis tight
figure; hold all
imagesc(reshape(sum(neuron.A,2),300,400), [0 max(neuron.A(:))]); colormap gray
for ni = 1:Nneurons
    tmp = reshape(neuron.A(:,(ni)),300,400);
    [C,hh] = contour(tmp,1, 'color',1-nColors((ni),:));
    text(mean(C(1,:)), mean(C(2,:)), num2str((ni)),'color',1-nColors((ni),:), ...
       'verticalalignment', 'middle',...
        'horizontalalignment', 'center')
end
% clear all; close all; clc
set(gca, 'ydir', 'reverse')
axis image; axis off
%% backsub movie
clear all; close all; 
dbasepath = 'E:\ProcessedCalciumData\6701_Nov20'; 
saveherecnmfe = 'C:\Users\emackev\Documents\ForOpenMind\cnmfe_results';
load(saveherecnmfe, 'neuron'); 
load(fullfile(dbasepath, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs', 'CompSoundSONG', 'CompSpecSONG', 'Y');

% neuron.A = [];
% Ybg = neuron.localBG(Y); 
% Ysignal = Y-reshape(Ybg,300,400,size(Ybg,2)); 
Ysignal = reshape(neuron.A*neuron.C, 300,400, size(neuron.C,2));
CompVidSONG = permute(Ysignal,[3 1 2]); % back sub
ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, fullfile(dbasepath, 'reconstructed.avi'), [], 0)

% save(fullfile(dbasepath, 'compiled'), 'Y', 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels',...
%        '-v7.3');
%% go through raw data
figure(1); clf; shg
stepdur = 180;
SOUNDfs = 40000; 

% for Nov 20 data
dbasepath = 'E:\ProcessedCalciumData\6701_Nov20'; 
saveherecnmfe = 'C:\Users\emackev\Documents\ForOpenMind\cnmfe_results';
load(saveherecnmfe, 'neuron'); 
load(fullfile(dbasepath, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs', 'CompSoundSONG', 'FnumBnum');

% for prepostmoco
% dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\ForOpenMind\cnmfe_results_moco';
% load(saveherecnmfe, 'neuron'); 
% load(fullfile(dbasepath, 'compiled_moco.mat'), 'Labels', 'segs', 'VIDEOfs', 'CompSoundSONG', 'FnumBnum');

PlotC = neuron.C;

% for stripes between files
borders = find((diff([0; FnumBnum(:,1)])~=0)|(diff([0; FnumBnum(:,1)])~=0))-1; 
PlotC(:,borders(borders>0)) = nan; 

istart = 1; 
while istart<size(PlotC,2)% = 1:stepdur/2:size(PlotC,2)
    sampsong = CompSoundSONG(ceil(istart*SOUNDfs/VIDEOfs:(istart+stepdur)*SOUNDfs/VIDEOfs)); 
    h(1) = subplot('position', [.1 .85 .8 .05]);cla
    spectrogramELM(sampsong, SOUNDfs, .002, 1); title(num2str(istart)); 
    SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
        segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
    hold on
    for syli = 1:size(SegsInFrame,1)
        patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
            [6 6 6.5 6.5], 'k')
    end
    
    axis off
    h(2) = subplot('position', [.1 .1 .8 .75]);cla; hold on; 
    tmp = PlotC(indSeqSort,istart:istart+stepdur-1); tmp(tmp>prctile(ByMotif(:),satPrc)) = prctile(ByMotif(:),satPrc);
    ColoredC = cat(3,...
        PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,1),1,stepdur),...
        PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,2),1,stepdur),...
        PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,3),1,stepdur));
    image(1-ColoredC/max(ColoredAllMotifs(:)), 'xdata', (1:stepdur)/VIDEOfs); 
    colormap(flipud(gray))
    set(gca, 'ydir', 'reverse'); ylabel('neuron')
    xlabel('Time (s)')
    linkaxes(h,'x'); 
%     ylim([0 20])
    axis tight
    drawnow; shg;%pause; 
    
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