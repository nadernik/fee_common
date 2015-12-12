clear all; clc
%% get bird-specific information
%%% FOR 5614
% Title = 'NIfMotif5614';
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfMotif5614.xlsx'; 
% 
% AlignSyl = 'B'; 
% OtherSyls = [-1:1]; % rel indices of all syls in bout
% AllSylNames = {'B' 'B' 'A'}; % names of other syls in bout
% 
% twindow = [-.5 .5]; % for raster
% tswindow = [-.3 .4]; % for spectrograms
% 
% MeanSegTimes = zeros(length(OtherSyls)+2,2); 
% oldMeanSegTimes = [  -0.1306   -0.0145; % run it once to determine these, or insert desired time warp times for each syl
%          0    0.1110;
%     0.1688    0.2759];
% 
% % choose whether to time-warp
% TimeWarp = 1; 
% MaxToPlot = 15; 

%%
%%% FOR 4202
% Title = 'NIfMotif4202';
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfMotif4202.xlsx'; 
% 
% AlignSyl = 'L'; 
% OtherSyls = [-2:0]; % rel indices of all syls in bout
% AllSylNames = {'Y' 'G' 'L'}; % names of other syls in bout
% 
% twindow = [-.4 .3]; % for raster
% tswindow = [-.4 .3]; % for spectrograms
% 
% MeanSegTimes = zeros(length(OtherSyls)+2,2); 
% oldMeanSegTimes = [-0.2028   -0.1516; % run it once to determine these, or insert desired time warp times for each syl
%    -0.1102   -0.0182;
%          0    0.1315];
% 
% % choose whether to time-warp
% TimeWarp = 0; 
% MaxToPlot = 10; 

%%

% %%% FOR 5739
% Title = 'NIfMotif5739';
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfMotif5739.xlsx'; 
% 
% AlignSyl = 'M'; 
% OtherSyls = [0:3]; % rel indices of all syls in bout
% AllSylNames = {'M' 'O' 'L' 'P'}; % names of other syls in bout
% 
% twindow = [-.2 .5]; % for raster
% tswindow = [-.2 .5]; % for spectrograms
% 
% MeanSegTimes = zeros(length(OtherSyls)+2,2); 
% oldMeanSegTimes = [0    0.0812; % run it once to determine these, or insert desired time warp times for each syl
%     0.0971    0.2028;
%     0.2404    0.3900;
%     0.4163    0.4718];
% 
% % choose whether to time-warp
% TimeWarp = 1; 
% MaxToPlot = 10; 

%%

%%% FOR 6230, DEAFENED BIRD motif
Title = 'NIfDeaf6230';
xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfDeaf6230.xlsx'; 

AlignSyl = 'D'; 
OtherSyls = [-3:1]; % rel indices of other syls in bout
AllSylNames = {'A' 'B' 'C' 'D' 'E'}; % names of other syls in bout

twindow = [-.8 .8]; % for raster
tswindow = [-.5 .4]; % for spectrograms

MeanSegTimes = zeros(length(OtherSyls)+2,2); 
oldMeanSegTimes = [-0.4292   -0.3686; % run it once to determine these, or insert desired time warp times for each syl
   -0.3235   -0.2736;
   -0.2419   -0.0766;
         0    0.0648;
    0.1051    0.4408];

% choose whether to time-warp
TimeWarp = 1; 
MaxToPlot = 10; 

%%

%%% FOR 6230, DEAFENED BIRD just extra syllable/call
% Title = 'NIfDeaf6230';
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfDeaf6230.xlsx'; 
% 
% AlignSyl = 'X'; 
% OtherSyls = [0]; % rel indices of other syls in bout
% AllSylNames = {'X'}; % names of other syls in bout
% 
% twindow = [-.1 .4]; % for raster
% tswindow = [-.1 .4]; % for spectrograms
% 
% MeanSegTimes = zeros(length(OtherSyls)+2,2); 
% oldMeanSegTimes = [0   .2781]; % run it once to determine these, or insert desired time warp times for each syl
% 
% 
% % choose whether to time-warp
% TimeWarp = 0; 
% MaxToPlot = 10; 

%%
% load spreadsheet info
XLS = importdata(xlsname);
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
GoodFiles = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('LabeledFiles', Columns)), 'uniformoutput', 0); 
GoodFiles(2:end+1) = GoodFiles(1:end); % to make rows line up (first row is section headings)
SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
rows = 2:size(XLS.data.Sheet1,1);
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1;

%% compile spiketimes and segtimes

% for time warping
DesiredSegTimes = [twindow(1) twindow(1); ...
    oldMeanSegTimes; ...
    twindow(2) twindow(2)]; 
DesSylpatchesX = [];
DesSylpatchesY = [];
for syli = 2:(size(DesiredSegTimes,1)-1)
    tmp = DesiredSegTimes(syli,:); 
    DesSylpatchesX = [DesSylpatchesX; [tmp(1) tmp(1) tmp(2) tmp(2) tmp(1)]]; 
    DesSylpatchesY = [DesSylpatchesY; [2 1 1 2 2]];
end
% initialize boutnum and sylpatchesX,Y
boutnum = 1; 
sylpatchesX = [];
sylpatchesY = [];
lastBoutByRow = 0; lastBoutByRow(rows) = 0;
soundclip = {};
spkT = []; 
spkRow = []; 
spkBout = [];
for row = rows
    % load analysis file
    [dbase rowstr{row} pathname filename] = getDbase_elm(row, XLS, Columns);
    eventNum = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns));
    fs = dbase.Fs;
    for file = GoodFiles{row}
        % compile syl times and titles, exclude unselected syls
        segIsSel = find(dbase.SegmentIsSelected{file});
        segTimes = dbase.SegmentTimes{file}(segIsSel,:)/fs; % whole file, just selected segs, in sec
        segTitles = dbase.SegmentTitles{file}(segIsSel); % whole file, just selected segs
        spiketimes = dbase.EventTimes{eventNum}{1,file}/fs; % whole file, in sec
        spiketimes = spiketimes(dbase.EventIsSelected{1,eventNum}{1,file}==1); % only keep selected spikes
        if length(segTitles)>0 % if file has any syllables
            SylIsD = find(cellfun(@(X) issame(X,AlignSyl), segTitles)); % find candidate bouts (find each syl D, or in general, syl to align to)
            SylIsD = SylIsD((SylIsD+OtherSyls(1))>0&(SylIsD+OtherSyls(end))<=length(segTitles)); % make sure it's not too close to the edge of the file
            for bout = SylIsD % for each candidate bout
                if isequal(segTitles(OtherSyls+bout), AllSylNames) ... % check all the other syls match
                        &&(boutnum-lastBoutByRow(row-1))<MaxToPlot; % only MaxToPlot bouts per neuron
                    bTime = segTimes(bout,1); % start time of syl you're aligning to
                    
                    % compile this bout's segments.. add more entries to sylpatchesX and sylpatchesY
                    if TimeWarp
                        segtimes = DesiredSegTimes; % one bout of seg times
                    else
                        segtimes = segTimes; 
                        segtimes = segtimes((segtimes(:,1)>(bTime+twindow(1))) & ...
                            (segtimes(:,2)<(bTime+twindow(2))),:)-bTime; % just this bout
                    end
                    for syli = 1:size(segtimes,1)
                        tmp = segtimes(syli,:); 
                        sylpatchesX = [sylpatchesX; [tmp(1) tmp(1) tmp(2) tmp(2) tmp(1)]]; 
                        sylpatchesY = [sylpatchesY; [boutnum+1 boutnum boutnum boutnum+1 boutnum+1]]; 
                    end

                    % compile this bout's spike times
                    if TimeWarp
                        ActualSegTimes = segTimes(bout + OtherSyls,:);
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
                    if length(spks) == 0
                        spks = nan; 
                    end
                    % compile all spike times
                    spkT = [spkT; spks(:)]; 
                    spkRow = [spkRow; row*ones(nSpks,1)]; 
                    spkBout = [spkBout; boutnum*ones(nSpks,1)];

                    % increment boutnum
                    boutnum = boutnum+1; 
                    usefile = file; % will use last bout as example spectrogram
                end
            end
        end
    end
    lastBoutByRow(row) = boutnum-1; 
    % extract an example spectrogram
    filename = fullfile(dbase.PathName,dbase.SoundFiles(usefile).name);
    soundclip{row} = egl_AA_daq(filename,1); 
    soundclip{row} = soundclip{row}((1:length(soundclip{row}))>fs*(bTime+tswindow(1)) & ...
        (1:length(soundclip{row}))<fs*(bTime+tswindow(2)));
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
    rowInd = find(spkRow == row); 
    [plotX plotY] = forRasterPlot(spkT(rowInd), spkBout(rowInd)); % adds nans for easy raster plot
    plot(plotX, plotY, 'Color', Colors(row,:))
    if CTEST(row)
        rowstr{row} = [rowstr{row} '_CTEST']; 
    end
    text(twindow(1), lastBoutByRow(row), rowstr{row}, 'interpreter', 'none', 'fontsize', 5, 'verticalalignment', 'top')
    subplot('position', [.7 .1+.8*(lastBoutByRow(row-1))/lastBoutByRow(end) .2 .8/lastBoutByRow(end)*(lastBoutByRow(row)-lastBoutByRow(row-1))]); 
    axis off
    displaySpecgramQuick(soundclip{row},fs); 
    temp = get(gca, 'Children'); 
    cdata = get(temp, 'Cdata');
    WhereBtMinAndMaxIsMedian = (prctile(cdata(:),50) - min(cdata(:)))/(max(cdata(:)) - min(cdata(:)));
    cmap = flipud(pink); cmap = [repmat([1 1 1],round(64*WhereBtMinAndMaxIsMedian/(1-WhereBtMinAndMaxIsMedian)),1); cmap]; colormap(cmap)
    axis off
end
subplot(mainplot)
set(gca, 'ytick', []);
xlabel('Time (s)', 'fontsize', 8)
box off; axis tight
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
title([Title ', timewarp=' num2str(TimeWarp)])
papersize = [8.5 11];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%% Firing rate matrix
% for each row, find the mean FR for that row
dt = .001; 
smoothwin = 5; %5*2.5; 
Time = twindow(1):dt:twindow(2); 
FR = zeros(length(rows), length(Time)); 
for rowi = 1:length(rows);
    row = rows(rowi);
    spks = spkT(find(spkRow==row));
    nBouts = numel(unique(spkBout(spkRow==row))); 
    for si = 1:length(spks)
        FR(rowi,round(Time/dt)==round(spks(si)/dt)) = ...
            FR(rowi,round(Time/dt)==round(spks(si)/dt)) +1; 
    end
    FR(rowi,:) = FR(rowi,:)/nBouts/dt; 
    FR(rowi,:) = conv(FR(rowi,:),gausswin(smoothwin)/sum(gausswin(smoothwin)),'same'); 
end
rawFR = FR; 
interneuronInd = (mean(FR,2)>50); %rows(interneuronInd) are the interneuron rows
[~,sortorder] = sort(mean(FR,2), 'ascend'); % sort by firing rate
for ti =1:length(rows); sortLabels{ti} = num2str(rows(sortorder(ti))); end 
% set(gca, 'xtick', 1:length(rows), 'xticklabels', sortLabels)
%% plot the firing rate matrix and timextime correlation matrix
figure(4); clf
MatW = .6; MatH = MatW*papersize(1)/papersize(2)
gg = subplot('position', [(1-MatW)/2 MatH+.2 MatW (1-.3-MatH)]); hold on
imagesc(rawFR(sortorder,:), 'xdata', Time)
xlim(tswindow);
for syli = 2:(size(DesiredSegTimes,1)-1)
    plot(DesiredSegTimes(syli,1)*[1 1], [.5 size(rawFR,1)+.5], 'k:'); 
    plot(DesiredSegTimes(syli,2)*[1 1],[.5 size(rawFR,1)+.5],  'k:'); 
    patch(DesSylpatchesX(syli-1,:),(DesSylpatchesY(syli-1,:)-1)*.5+size(rawFR,1)+.5, .5*[1 1 1],'edgecolor', 'none');
end
colormap(gg,flipud(gray))
xlabel('Time (s)'); ylabel('Neuron #')
set(gca, 'ytick', 1:length(rows), 'yticklabels', sortLabels)
axis tight
xlim(tswindow); 
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 6)
title(['FR matrix ' Title ', timewarp=' num2str(TimeWarp)])

shg
% plot FR TimexTime corr matrix
hh = subplot('position', [(1-MatW)/2 .1 MatW MatH]); cla; hold on
tind = Time>tswindow(1) & Time<tswindow(2);
FRms = bsxfun(@minus,rawFR(:,tind), mean(rawFR(:,tind),2)); % subtract mean of each neuron
% FRms = bsxfun(@minus,rawFR(:,tind), mean(rawFR(:,tind),1)); % subtract mean of each timepoint
% FRms = bsxfun(@rdivide,FRms, std(FRms,[],2)); % divide by std of each neuron

corrmat = FRms'*FRms; %FRms(interneuronInd,:)'*FRms(interneuronInd,:); 
diag = sum(corrmat.*eye(size(corrmat))); 
diagA = repmat(diag',1,size(corrmat,1)); 
diagB = repmat(diag,size(corrmat,1),1); 
corrmat = corrmat./(sqrt(diagA.*diagB)); 
newsortT = sortbyCorr1(corrmat); 
[~,unsort] = sort(newsortT); 
imagesc(Time(tind), Time(tind), corrmat(newsortT,newsortT), [-max(corrmat(:)) max(corrmat(:))])

xlabel('Time (s)'), ylabel('Time (s)')
cmap = [(1:64)'/64  (1:64)'/64 ones(64,1); ...
    ones(64,1) (64:-1:1)'/64 (64:-1:1)'/64];
colormap(hh,cmap)
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 6)
title([Title 'FR matrix TimexTime Cov, timewarp=' num2str(TimeWarp)])
xlim(tswindow); ylim(tswindow)
sylcol = .6*[1 0 1]; 
for syli = 2:(size(DesiredSegTimes,1)-1)
    plot(tswindow, DesiredSegTimes(syli,1)*[1 1], 'color', sylcol);
    plot(tswindow, DesiredSegTimes(syli,2)*[1 1], 'color', sylcol);
    plot(DesiredSegTimes(syli,2)*[1 1], tswindow, 'color', sylcol);
    plot(DesiredSegTimes(syli,1)*[1 1], tswindow, 'color', sylcol);
    patch(DesSylpatchesX(syli-1,:),(DesSylpatchesY(syli-1,:)-1)*.01+tswindow(1),  sylcol, 'edgecolor', 'none');
    patch((DesSylpatchesY(syli-1,:)-1)*.01+tswindow(1), DesSylpatchesX(syli-1,:),  sylcol, 'edgecolor', 'none');
end
linkaxes([hh gg], 'x')
papersize = [4 5];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 

%% svd on fr
[u,s,v] = svd(FRms); 
figure(6); clf
hold on
plot(Time(tind),bsxfun(@plus,v(:,1:5), .1*(1:5))); 
ylims = ylim; 
for syli = 2:(size(DesiredSegTimes,1)-1)
    plot(DesiredSegTimes(syli,2)*[1 1], ylims, ':', 'color', 'k');
    plot(DesiredSegTimes(syli,1)*[1 1], ylims, ':', 'color', 'k');
    patch(DesSylpatchesX(syli-1,:),(DesSylpatchesY(syli-1,:)-1)*diff(ylims)*.05+ylims(2),  .5*[1 1 1], 'edgecolor', 'none');
end
%% corr mat
figure(10); clf
MatW = .6; MatH = MatW*papersize(1)/papersize(2)
tmp = subplot('position', [(1-MatW)/2 MatH+.2 MatW (1-.3-MatH)]); hold on
imagesc(rawFR(newsort,:), 'xdata', Time)
xlim(tswindow);
for syli = 2:(size(DesiredSegTimes,1)-1)
    plot(DesiredSegTimes(syli,1)*[1 1], [.5 size(rawFR,1)+.5], 'k:'); 
    plot(DesiredSegTimes(syli,2)*[1 1],[.5 size(rawFR,1)+.5],  'k:'); 
    patch(DesSylpatchesX(syli-1,:),(DesSylpatchesY(syli-1,:)-1)*.5+size(rawFR,1)+.5, .5*[1 1 1],'edgecolor', 'none');
end
colormap(tmp,flipud(gray))
xlabel('Time (s)'); ylabel('Neuron #')
set(gca, 'ytick', 1:length(rows), 'yticklabels', sortLabels)
axis tight
xlim(tswindow); 
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
title(['FR matrix ' Title ', timewarp=' num2str(TimeWarp)])

subplot('position', [(1-MatW)/2 .1 MatW MatH]); cla; hold on
% [~,sortind] = sort(u(:,1)); 
% imagesc(FRms(sortind,:))
corrmat = FRms*FRms';
% corrmat = bsxfun(@rdivide,corrmat, sum(corrmat.*eye(size(corrmat)))); 
diag = sum(corrmat.*eye(size(corrmat))); 
diagA = repmat(diag(:),1,size(corrmat,1)); 
diagB = repmat(diag(:)',size(corrmat,1),1); 
corrmat = corrmat./(sqrt(diagA.*diagB)); 
% corrmat = bsxfun(@rdivide,corrmat', sqrt(sum(corrmat.*eye(size(corrmat)))); 


newsort = sortbyCorr1(corrmat); 

imagesc(corrmat(newsort,newsort), [-1 1])
cmap = [(1:64)'/64  (1:64)'/64 ones(64,1); ...
    ones(64,1) (64:-1:1)'/64 (64:-1:1)'/64];
colormap(cmap)
axis tight
title(['FR sorted neuronxneuron ' Title ', timewarp=' num2str(TimeWarp)])
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 6)
for ti =1:length(rows); sortLabels{ti} = num2str(rows(newsort(ti))); end 
set(gca, 'ytick', 1:size(corrmat,1), 'yticklabel', sortLabels, 'xtick', 1:size(corrmat,1), 'xticklabel', sortLabels)
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%% calculating spectrums and autocorrelations for each row

Fs = 1/dt;                    % Sampling frequency
T = dt;                     % Sampling period
zpadfac = 5; 
t = tswindow(1):(1/Fs):(tswindow(1) + (tswindow(end)-tswindow(1))*zpadfac);  % Time vector
if mod(length(t),2)~=0
    t(end+1) = t(end) + 1/Fs;
end
SPECTRUMS = [];
TIMESIGNAL = [];
AC = [];
for rowi = 1:length(rows)
    row = rows(rowi);
    S = 0*t; 
    S(1:size(FRms,2)) = FRms(rowi,:);
%     S(t>tswindow(end)) = 0; 
%     S = S/length(find(unique(spkBout(spkRow==row))))*Fs;
%     S = conv(S, gausswin(smoothwin)/sum(gausswin(smoothwin)), 'same');
%     S(t<tswindow(end)) = S(t<tswindow(end))-mean(S(t<tswindow(end)));
    L = length(t);          
    Y = fft(S);
    P2 = abs(Y/L).^2;
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    SPECTRUMS(rowi,:) = P1; 
    TIMESIGNAL(rowi,:) = S; 
    % autocorrelations
    % find bouts for this row
    rowBouts = unique(spkBout(spkRow==row)); 
    % for each bout, calculate the autocorrelation 
    maxlag = round(.3*Fs); 
    tAC = (-maxlag:maxlag)*dt; 
    tmpAC = zeros(length(rowBouts),length(tAC)); 
    for bi = 1:length(rowBouts)
        bout = rowBouts(bi);
        spks = spkT(spkBout==bout); 
        tmpFR = histc(spks,Time(tind));
        tmpFR = conv(tmpFR,gausswin(smoothwin)/sum(gausswin(smoothwin)),'same');
        tmpAC(bi,:) = xcorr(tmpFR-mean(tmpFR), maxlag, 'coeff');
    end
    % compile the average autocorrelation
    AC(rowi,:) = mean(tmpAC);
end

%% plotting spectrums
rowcolors = (lines(length(rows))+1)/2; 
figure(1); clf; shg
subplot(4,1,1); hold on
set(gca, 'colororder', rowcolors)
plot(t,fliplr(bsxfun(@plus, TIMESIGNAL(sortorder,:)', 200*(1:size(TIMESIGNAL,1))))); %.8*[1 1 1])
set(gca, 'ytick', (1:length(rows))*200, 'yticklabels', sortLabels)
axis tight
% plot(t,mean(TIMESIGNAL), 'k')
ylims = ylim; 
for syli = 2:(size(DesiredSegTimes,1)-1)
%     plot(tswindow, DesiredSegTimes(syli,1)*[1 1], ':', 'color', 'k'); 
%     plot(tswindow, DesiredSegTimes(syli,2)*[1 1], ':', 'color', 'k'); 
    plot(DesiredSegTimes(syli,2)*[1 1], ylims, ':', 'color', 'k');
    plot(DesiredSegTimes(syli,1)*[1 1], ylims, ':', 'color', 'k');
    patch(DesSylpatchesX(syli-1,:),(DesSylpatchesY(syli-1,:)-1)*diff(ylims)*.05+ylims(2),  .5*[1 1 1], 'edgecolor', 'none');
%     patch((DesSylpatchesY(syli-1,:)-1)*.01+tswindow(1), DesSylpatchesX(syli-1,:),  .5*[1 1 1], 'edgecolor', 'none');
end
xlim(tswindow)
ylabel('row #'); 
set(gca,'color','none','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
title([Title ', spike power spectrum, timewarp=' num2str(TimeWarp)])

f1(1) = subplot(4,1,3); hold on
normSPEC = bsxfun(@rdivide, SPECTRUMS, sum(SPECTRUMS,2));
set(gca, 'colororder', rowcolors)
plot(f,flipud(normSPEC(sortorder,:))); %.8*[1 1 1])
plot(f,mean(normSPEC), 'k')
ylabel('normalized power'); 
set(gca,'color','none','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 6)
% title([Title ', spike power spectrum, timewarp=' num2str(TimeWarp)])

f1(2) = subplot(4,1,4)
imagesc(normSPEC(sortorder,:), 'xdata', f, 'ydata', (1:length(rows)))
xlabel('f (Hz)'); ylabel('row #')
% plot(f,bsxfun(@plus, normSPEC', .002*(1:size(normSPEC,1))))
linkaxes(f1,'x')
xlim([0 100])
set(gca, 'ytick', (1:length(rows)), 'yticklabels', sortLabels)
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
set(gca, 'ydir', 'normal')


tmp = subplot(4,1,2); hold on
ACplot = AC; 
% ACplot = bsxfun(@rdivide, ACplot, sum(abs(ACplot),2)) % so colors are brighter
% ACplot(:,abs(tAC)<(smoothwin*dt))=0; % set to nan anything within gaussian smoothing window from 0
ACplot(:,tAC==0)=0; % set time 0 to nan
imagesc(tAC,1:length(rows),ACplot(sortorder,:), max(abs(ACplot(:)))*[-1 1])
set(gca, 'ytick', (1:length(rows)), 'yticklabels', sortLabels)

% set(gca, 'colororder', rowcolors)
% spreadfac = .03;
% plot(tAC, fliplr(bsxfun(@plus, ACplot(sortorder,:)', spreadfac*(1:length(rows)))))
% set(gca, 'ytick', spreadfac*(1:length(rows)), 'yticklabels', sortLabels)
colorbar
axis tight
colormap(tmp,cmap)
set(gca, 'ydir', 'normal')
xlabel('Time (s)')
ylabel('row #')
xlim([0 max(tAC)])
papersize = [4 10];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
set(gca,'color','none','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 6)
%%
figure(12);clf
plot(Time(tind),mean(FR(:,tind),1))
%%


