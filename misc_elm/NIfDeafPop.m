%% deafening population plot 
%% load spreadsheet info
clear all; clc
XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfDeaf6230.xlsx');
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
GoodFiles = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('LabeledFiles', Columns)), 'uniformoutput', 0); 
GoodFiles(2:end+1) = GoodFiles(1:end); % to make rows line up (first row is section headings)
% SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
rows = 2:size(XLS.data.Sheet1,1);
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1;

%% compile spiketimes
% params
twindow = [-.8 .8]; % for raster
tswindow = [-.5 .5]; % for spectrograms
AlignSyl = 'D'; 
TimeWarp = 0; 
OtherSyls = [-3:1]; % rel indices of other syls in bout
MeanSegTimes = zeros(length(OtherSyls)+2,2); 
oldMeanSegTimes = [-0.4278   -0.3663;
   -0.3264   -0.2753;
   -0.2427   -0.0755;
         0    0.0650;
    0.1061    0.4417]; 
DesiredSegTimes = [twindow(1) twindow(1); ...
    oldMeanSegTimes; ...
    twindow(2) twindow(2)]; 
% initialize boutnum and sylpatchesX,Y
boutnum = 1; 
sylpatchesX = [];
sylpatchesY = [];
lastBoutByRow = 0; 
soundclip = {};
spkT = []; 
spkRow = []; 
for row = rows
    % load analysis file
    [dbase rowstr{row} pathname filename] = getDbase_elm(row, XLS, Columns);
    eventNum = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns));
    fs = dbase.Fs;
    % initialize spkY_boutnum{row} and spkX_reltime{row}
    spkY_boutnum{row} = [];
    spkX_reltime{row} = [];
    for file = GoodFiles{row}
        if length(dbase.SegmentTitles{file})>0
        % find bouts (find each syllable D)
        SylIsD = find(cellfun(@(X) issame(X,AlignSyl), dbase.SegmentTitles{file}));
        spiketimes = dbase.EventTimes{eventNum}{1,file}/fs;
        for bout = SylIsD
            bTime = dbase.SegmentTimes{file}(bout,1)/fs;
            
            % segments.. add more entries to sylpatchesX and sylpatchesY
            if TimeWarp
                segtimes = DesiredSegTimes;
            else
                segtimes = dbase.SegmentTimes{file}/fs; 
                segtimes = segtimes((segtimes(:,1)>(bTime+twindow(1))) & ...
                    (segtimes(:,2)<(bTime+twindow(2))),:)-bTime; 
            end
            for syli = 1:size(segtimes,1)
                tmp = segtimes(syli,:); 
                sylpatchesX = [sylpatchesX; [tmp(1) tmp(1) tmp(2) tmp(2) tmp(1)]]; 
                sylpatchesY = [sylpatchesY; [boutnum+1 boutnum boutnum boutnum+1 boutnum+1]]; 
            end
            
            % spikes
            
            
            if TimeWarp
                ActualSegTimes = dbase.SegmentTimes{file}(bout + OtherSyls,:)/fs;
                ActualSegTimes = [bTime+twindow(1) bTime+twindow(1); ...
                    ActualSegTimes; ...
                    bTime+twindow(2) bTime+twindow(2)];
                MeanSegTimes = MeanSegTimes+ActualSegTimes-bTime; 
                spks = TimeWarp_elm(spiketimes((spiketimes>(bTime+twindow(1))) & ...
                    (spiketimes<(bTime+twindow(2)))), ActualSegTimes, DesiredSegTimes); 
            else
                spks = spiketimes((spiketimes>(bTime+twindow(1))) & ...
                    (spiketimes<(bTime+twindow(2))))-bTime; 
            end
            nSpks = length(spks); 
            % add more entries to spkY_boutnum{row} and spkX_reltime{row}
            [plotX plotY] = forRasterPlot(spks, boutnum*ones(nSpks,1));
            spkX_reltime{row} = [spkX_reltime{row}; plotX];
            spkY_boutnum{row} = [spkY_boutnum{row}; plotY]; 
            
            % compile all spike times
            spkT = [spkT; spks(:)]; 
            spkRow = [spkRow; row*ones(nSpks,1)]; 
            
            % increment boutnum
            boutnum = boutnum+1; 
            usefile = file;
        end
    end
    lastBoutByRow(row) = boutnum; 
    % extract an example spectrogram
    filename = fullfile(dbase.PathName,dbase.SoundFiles(usefile).name);
    soundclip{row} = egl_AA_daq(filename,1); 
    soundclip{row} = soundclip{row}((1:length(soundclip{row}))>fs*(bTime+tswindow(1)) & ...
        (1:length(soundclip{row}))<fs*(bTime+tswindow(2)));
    end
end
MeanSegTimes = MeanSegTimes/boutnum; 

%% plot
figure(7);clf; shg
color_palet = [[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
Colors = color_palet(mod(1:max(rows),size(color_palet,1))+1,:); 
mainplot = subplot('position', [.1 .1 .6 .8])
hold all;
for syli = 1:size(sylpatchesX,1)
    patch(sylpatchesX(syli,:),sylpatchesY(syli,:),  .95*[1 1 1], 'edgecolor', 'none'); 
end
for row = rows; 
    subplot(mainplot)
    plot(spkX_reltime{row}(:), spkY_boutnum{row}(:), 'Color', Colors(row,:))
    if CTEST(row)
        rowstr{row} = [rowstr{row} '_CTEST']; 
    end
    text(twindow(1), lastBoutByRow(row), rowstr{row}, 'interpreter', 'none', 'fontsize', 5, 'verticalalignment', 'top')
    subplot('position', [.7 .1+.8*(lastBoutByRow(row-1))/lastBoutByRow(end) .2 .8/lastBoutByRow(end)*(lastBoutByRow(row)-lastBoutByRow(row-1))]); 
    axis off
    displaySpecgramQuick(soundclip{row},fs); 
    cmap = flipud(pink); cmap = [repmat([1 1 1],300,1); cmap]; colormap(cmap)
    axis off
end
subplot(mainplot)
set(gca, 'ytick', []);
xlabel('Time (s)', 'fontsize', 8)
box off; axis tight
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
papersize = [8.5 11]
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%% making polar plot
colors = jet(max(rows)); 
omegas = .1
for omegai = 1:length(omegas)
figure(6); clf; hold all; 
omega = omegas(omegai);
theta = mod(spkT+min(spkT), omega)*2*pi/omega; 
plotspkT = spkT+min(spkT); plotspkT((find(diff(spkT)<0|diff(spkT)>.05))+1)=nan;
for ni = rows; %([1:4 6 19])
    ind = find(spkRow==ni); 
    plot(theta(ind),2+plotspkT(ind)+ni/length(rows)*.15, 'o')%randn(length(plotspkT(ind)),1)*.02)%, 'o', 'markerfacecolor', 'flat') 
%     polar(theta(ind),2+plotspkT(ind)+randn(length(plotspkT(ind)),1)*.02, '.') 

% 	set(a,'markerfacecolor', 'flat')%'color',colors(ni,:))
end
axis square
title(num2str(omega))
pause(.5); drawnow
shg
end
%% 
% for each row, find the mean IFR for that row
% plot that matrix
dt = .001; 
smoothwin = 5; 
Time = twindow(1):dt:twindow(2); 
FR = zeros(length(rows), length(Time)); 
for rowi = 1:length(rows);
    row = rows(rowi);
    spks = spkT(find(spkRow==row));
    nBouts = numel(find(diff(spks)<0))+1; 
    for si = 1:length(spks)
        FR(rowi,round(Time/dt)==round(spks(si)/dt)) = ...
            FR(rowi,round(Time/dt)==round(spks(si)/dt)) +1; 
    end
    FR(rowi,:) = FR(rowi,:)/nBouts; 
    FR(rowi,:) = smooth(FR(rowi,:) ,smoothwin); 
%     for ii = 1:length(ISIs)
%         if ISIs(ii)>0
%             IFR(rowi,Time>spkT(ii)&Time<spkT(ii+1)) = ...
%                 IFR(rowi,Time>spkT(ii)&Time<spkT(ii+1)) + 1/ISIs(ii); 
%         end
%     end
end
rawFR = FR; 
FR = bsxfun(@minus,FR, mean(FR,2)); 
FR = bsxfun(@rdivide,FR, std(FR,[],2));
[u,s,v] = svd(FR); 
figure(6); clf; hold all
plotspkT = spkT;%+min(spkT); plotspkT((find(diff(spkT)<0|diff(spkT)>.05))+1)=nan;
for ni = rows; %([1:4 6 19])
    ind = find(spkRow==ni); 
    tInd = ceil((spkT(ind)-min(Time))/dt);
    plot(v(tInd,1),v(tInd,2),'o')%randn(length(plotspkT(ind)),1)*.02)%, 'o', 'markerfacecolor', 'flat') 
%     polar(theta(ind),2+plotspkT(ind)+randn(length(plotspkT(ind)),1)*.02, '.') 

% 	set(a,'markerfacecolor', 'flat')%'color',colors(ni,:))
end
axis square
title(num2str(omega))
pause(.5); drawnow
shg

%%
figure(4); clf; hold on
imagesc(rawFR, 'xdata', Time)
xlim(tswindow);
for syli = 1:size(DesiredSegTimes,1)
    plot(DesiredSegTimes(syli,1)*[1 1], [.5 size(rawFR,1)+.5], ':', 'color', 'k'); 
    plot(DesiredSegTimes(syli,2)*[1 1],[.5 size(rawFR,1)+.5],  ':', 'color', 'k'); 

    patch(sylpatchesX(syli,:),(sylpatchesY(syli,:)-1)*.5+size(rawFR,1)+.5,  .5*[1 1 1], 'edgecolor', 'none');
end
colormap(flipud(gray))
xlabel('Time (s)'); ylabel('Neuron #')
axis tight
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
xlim(tswindow); 
title('FR matrix')
papersize = [6 4];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
shg
%
figure(5); clf; hold on
tind = Time>tswindow(1) & Time<tswindow(2);
FRms = bsxfun(@minus,rawFR(:,tind), mean(rawFR(:,tind),2)); % subtract mean of each neuron
% FRms = bsxfun(@minus,rawFR(:,tind), mean(rawFR(:,tind),1)); % subtract mean of each timepoint
% FRms = bsxfun(@rdivide,rawFR(:,tind), std(rawFR(:,tind),[],1)); 
corrmat = FRms'*FRms; 
imagesc(Time(tind), Time(tind), corrmat, [-max(corrmat(:)) max(corrmat(:))])
xlabel('Time (s)'), ylabel('Time (s)')
cmap = [(1:64)'/64  (1:64)'/64 ones(64,1); ...
    ones(64,1) (64:-1:1)'/64 (64:-1:1)'/64 ]
colormap(cmap)
axis square
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
title('FR matrix TimexTime Cov')
xlim(tswindow); ylim(tswindow)
for syli = 1:size(DesiredSegTimes,1)
    plot(tswindow, DesiredSegTimes(syli,1)*[1 1], ':', 'color', 'k'); 
    plot(tswindow, DesiredSegTimes(syli,2)*[1 1], ':', 'color', 'k'); 
    plot(DesiredSegTimes(syli,2)*[1 1], tswindow, ':', 'color', 'k');
    plot(DesiredSegTimes(syli,1)*[1 1], tswindow, ':', 'color', 'k');
    patch(sylpatchesX(syli,:),(sylpatchesY(syli,:)-1)*.01+tswindow(1),  .5*[1 1 1], 'edgecolor', 'none');
    patch((sylpatchesY(syli,:)-1)*.01+tswindow(1), sylpatchesX(syli,:),  .5*[1 1 1], 'edgecolor', 'none');
end
papersize = [6 6];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%%
figure(3)
plot(Time(tind),mean(corrmat),'k')
axis square
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
title('FR matrix TimexTime Cov')
xlim(tswindow); 
xlabel('Time (s)'), ylabel('average cov')

shg