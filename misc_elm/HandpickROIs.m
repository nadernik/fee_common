function neuron = HandpickROIs(VIDEO,SOUND,SPEC, filename, params, showcontour)

if nargin<4
    filename = []; 
end
if nargin<5 || length(params)==0
    params.SOUNDfs = 40000;
    params.specTime = -.5:(1/params.SOUNDfs):.5;
    params.F = linspace(507.8125, 5976.6, 141);
    params.VIDEOfs = 20;
    params.AudBinWhenFrameStarts = 0:2000:ceil(size(VIDEO,1)/params.VIDEOfs*params.SOUNDfs); 
    params.AudBinWhenFrameEnds =  params.AudBinWhenFrameStarts + 2000; 
end
if nargin<6
    showcontour = 0; 
end
SOUNDfs = params.SOUNDfs; 
specTime = params.specTime; 
F = params.F; 
VIDEOfs = params.VIDEOfs; 
AudBinWhenFrameStarts = params.AudBinWhenFrameStarts;
AudBinWhenFrameEnds = params.AudBinWhenFrameEnds;
tSound = (0:AudBinWhenFrameEnds(end))/SOUNDfs;

if length(filename) == 0;
    savevid = 0;
else
    savevid = 1; 
end

maxproj = squeeze(max(VIDEO,[],1));
figure; 
clims =  [min(maxproj(:)) prctile(maxproj(:),99.9)]
imagesc(maxproj,clims); colormap gray
axis equal; axis off
hold on

answer = inputdlg({'FileName',...
    '0:load; 1:overwrite'},'',1,...
    {'E:\ProcessedCalciumData\ROIs\ROIsSep21b6719.mat','0'}); % input dialog box
if isempty(answer)
    return
end
MakeNewRois = eval(answer{2}); % array of files to be analyzed, convert from string to number
FileName = answer{1}; % array of files to be analyzed, convert from string to number


if MakeNewRois
    clicking = 1; 
    x = []; 
    y = []; 
    i = 1; 
    while clicking
        [x(i),y(i)] = ginput(1);
        plot(x(i),y(i), 'r.') 
        if x(i)<0 | y(i)<0
            x = x(1:end-1); y = y(1:end-1); 
            clicking = 0;
        end
        i = i+1;
    end
    ROIx = x; 
    ROIy = y; 
    save(FileName,'ROIx', 'ROIy')
else
    load(FileName); 
end

clf; colormap gray
imagesc(maxproj, clims)
hold on; axis equal; axis off
umPerPixel = 900/400; 
plot(50+[0 100]/umPerPixel, [50 50],  'color', [1 1 1])
text(mean(50+[0 100]/umPerPixel), [50], '100 um','color', [1 1 1],'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
roicolors = lines(length(ROIx));
[y x] = size(maxproj); 
[X1,X2] = meshgrid(1:x,1:y);
% PlaceBlob = zeros(y,x,length(ROIx));
vecV = reshape(VIDEO,size(VIDEO,1),y*x); 
neuron.A = zeros(x*y, length(ROIx)); 
for roi = 1:length(ROIx)
    indROI = find(sqrt((X1(:)-ROIx(roi)).^2 + (X2(:)-ROIy(roi)).^2)<10/umPerPixel);
    neuron.A(indROI,:,:) = 1; 
    tr(:,roi) = sum(vecV(:,indROI),2)/numel(indROI); 
%     PlaceBlob(:,:,roi) = reshape(mvnpdf([X1(:) X2(:)], [ROIx(roi) ROIy(roi)], ...
%         20/umPerPixel*eye(2)),y,x); 
%     contour(squeeze(PlaceBlob(:,:,roi)), 1, 'color',roicolors(roi,:));
    
    tmp = zeros(1,y*x); tmp(indROI) = 1; contour(reshape(tmp,y,x), 'color',roicolors(roi,:));
    text(ROIx(roi),ROIy(roi),num2str(roi),'color', 'm', 'horizontalalignment', 'center'); 
end
neuron.C = tr'; 
% stROI = permute(repmat(PlaceBlob, 1,1,1,size(VIDEO,1)),[4,1,2,3]); 
% stVid = repmat(VIDEO,1,1,1,length(ROIx));
% tr = squeeze(sum(sum(stROI.*stVid,2),3));
figure; 
h = subplot(4,1,1)
spectrogramELM(SOUND,SOUNDfs, .005, 1);
axis off
g = subplot(4,1,2:4)
toplot = bsxfun(@plus, tr, (1:size(tr,2))/.02); 
plot((1:length(tr))/VIDEOfs, toplot)
% imagesc(tr','xdata', (1:length(tr))/VIDEOfs)
% colormap(flipud(gray))
% set(gca, 'clim', [0 .5]); 
linkaxes([h g],'x')
xlabel('Time (s)')
set(gca, 'ytick', [], 'fontsize', 14, 'xtick', [6:10], 'xticklabel', arrayfun(@num2str, 0:4, 'uniformoutput', 0))
% ylabel('Neuron #')
% %% example events for each roi
% % TimesToAlign = [21 21.86 22.76 24.12 25.01 26.15 27.66]'
% % plot(tSound,SOUND); % pick syl boundaries
% clf; hold on
% uFac = 10; 
% tOld = ((1:1:size(tr,1))/VIDEOfs);
% tNew = (1:1/uFac:size(tr,1))/VIDEOfs; 
% trUpsample = spline(tOld,tr',tNew)';
% % plot(tOld,tr'); hold on; plot(tNew,trUpsample)
% 
% 
% for roi = 4; %1:length(ROIx)
%     win =  -400:400; 
%     thres = prctile(tr(:,roi),97);%mean(tr(:,roi)) + 2*std(tr(:,roi)); %prctile(tr(:,roi),95);
%     Events = find(trUpsample(2:end,roi)>thres & trUpsample(1:end-1,roi)<thres)+1; 
%     Events(((Events+win(1))<=0) | ((Events+win(end))>=size(trUpsample,1))) = []; % threshold crossings
%     % for each event
%     starts = find(trUpsample(:,roi)<=prctile(trUpsample(:,roi),50));
%     ends = find(trUpsample(:,roi)>=thres);
%     for ei = 1:length(Events)
%         eStart = starts(starts<Events(ei)); 
%         eEnd = ends(ends>Events(ei)); 
%         if length(eEnd)>0&length(eStart)>0
%             eStart = eStart(end)-Events(ei);
%             eEnd = eEnd(1)-Events(ei); 
%             plot(eEnd/VIDEOfs/uFac, trUpsample(eEnd+Events(ei),roi),'o','color',roicolors(roi,:), 'markerfacecolor',roicolors(roi,:))
%             plot(eStart/VIDEOfs/uFac, trUpsample(eStart+Events(ei),roi),'o','color',roicolors(roi,:))
%         end
%     end
%     plotme = repmat(Events,1,length(win)) + repmat(win,length(Events),1); 
%     tmp = trUpsample(:,roi);
%     plot(win/VIDEOfs/uFac,(tmp(plotme)),'color',roicolors(roi,:))
%     
% %     win =  -50:50;
% %     Events = floor(TimesToAlign*VIDEOfs); %
% %     Rems = Events - (TimesToAlign*VIDEOfs);
% %     plotme = repmat(Events,1,length(win)) + repmat(win,length(Events),1); 
% %     tmp = tr(:,roi);
% %     for ei = 1:size(plotme,1)
% %         plot(win/VIDEOfs-Rems(ei)/VIDEOfs,tmp(plotme(ei,:)),'color',roicolors(roi,:))
% %     end
% 
% %     errorpatch_asym(win/VIDEOfs+roi/2, prctile(tmp(plotme),50), prctile(tmp(plotme),25), ...
% %         prctile(tmp(plotme),75),roicolors(roi,:),roicolors(roi,:))
% end
% xlabel('Time (s)'); ylabel('df/f')
% axis tight
% shg
% %% for row 929,
% % baseline = median(trUpsample(1:Events(1),roi)); 
% M = median(tmp(plotme)); M = M-mean(M(win>-uFac*VIDEOfs*.4 & win<-uFac*VIDEOfs*.2)); M(win<-uFac*VIDEOfs*.4) = 0;
% plot(win/VIDEOfs/uFac,M, 'k', 'linewidth', 4); shg
% %%
% clf
% T = (0:1/uFac/VIDEOfs:4); 
% pulses = double(mod(T, .2)==0); 
% pulses((T<1) | (T>3)) = 0; pulses = pulses.*(rand(1,length(pulses))>.4);
% plot(T,conv(pulses, M, 'same'))
% hold on
% plot(T,pulses/100 - 1/100)
% shg
% xlabel('time (s)'); 
% ylabel('estimated df/f')