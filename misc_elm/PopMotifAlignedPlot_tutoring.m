clear all; clc

%% cage9_black255yellow411, used for birds 4202, 4238, 4503
% BirdNum = 4503; %
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx'; 
% wavname = '\\feebox6\shared\emackev\Tutors\cage9_black255yellow411.wav'; 
% segsname = '\\feebox6\shared\emackev\Tutors\cage9_black255yellow411_SegTimes.mat'; 
% twindow = [-.9 5];
% params.AllowedJitter = 1; 
%% 4108
% BirdNum = 4108; %
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx'; 
% wavname = '\\feebox6\shared\emackev\Tutors\Gray104bout.wav'; 
% segsname = '\\feebox6\shared\emackev\Tutors\Gray104bout_SegTimes.mat'; 
% twindow = [-.5 3.5];
% params.AllowedJitter = 1; 
%% 5709
% BirdNum = 5709; %
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx'; 
% wavname = '\\feebox6\shared\emackev\Tutors\GoodMotifRhythm\Cage23Black238.wav'; 
% segsname = '\\feebox6\shared\emackev\Tutors\GoodMotifRhythm\Cage23Black238_SegTimes.mat'; 
% twindow = [-.5 2];
% params.AllowedJitter = .4; 
%% 6006
% BirdNum = 6006; %
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx'; 
% wavname = '\\feebox5\emily\AcqGui\6006\2015-07-21-NIf\s1152\6006_d000452_20150721T141016chan0.wav'; 
% segsname = '\\feebox5\emily\AcqGui\6006\2015-07-21-NIf\s1152\6006_d000452_20150721T141016chan0_SegTimes.mat'; 
% twindow = [-.5 2.5];
% params.AllowedJitter = .2; 
%% 5739
% BirdNum = 5739; %
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx'; 
% wavname = '\\feebox5\emily\AcqGui\5739\2015-04-26-NIf\s819\5739_d000095_20150426T104346chan0.wav'; 
% segsname = '\\feebox5\emily\AcqGui\5739\2015-04-26-NIf\s819\5739_d000095_20150426T104346chan0_SegTimes.mat'; 
% twindow = [-.5 2.5];
% params.AllowedJitter = .4; 

%% 5476 only bird with this tutor
% BirdNum = 5476; %
% xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx'; 
% wavname = '\\feebox6\shared\emackev\Tutors\GoodMotifRhythm\Cage5Black6.wav'; 
% segsname = '\\feebox6\shared\emackev\Tutors\GoodMotifRhythm\Cage5Black6_SegTimes.mat'; 
% twindow = [-.5 7.5];
% params.AllowedJitter = 3; 

%% 6540, ... still have more to analyze
BirdNum = 6540; %
xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx'; 
wavname = '\\feebox6\shared\emackev\Tutors\GoodMotifRhythm\Cage31White126_filtered.wav'; 
segsname = '\\feebox6\shared\emackev\Tutors\GoodMotifRhythm\Cage31White126_filtered_SegTimes.mat'; 
twindow = [-.9 7];
params.AllowedJitter = 3; 
%% load relevant stuff
[TutorSong, TutorFs] = audioread(wavname); 

load(segsname);
params.WantTheseTimes = SEGTIMES-SEGTIMES(1,1); 
OtherSyls = 0:(size(SEGTIMES,1)-1); 

% choose whether to time-warp
TimeWarp = 0; 
MaxToPlot = 10; 

Title = [num2str(BirdNum)]; 

% load spreadsheet info
XLS = importdata(xlsname);
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
TUTORING = XLS.data.Sheet1(:,strmatch('tutoring?', Columns))==1; 
SINGLEUNIT = XLS.data.Sheet1(:,strmatch('quality (1 = bad multi, 2 = ok, 3 = single, 4 = good single)', Columns))>=3; 
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1;
PUTPROJ = XLS.data.Sheet1(:,strmatch('Put Proj?', Columns))==1;
HASH = XLS.data.Sheet1(:,strmatch('hash? (2  = unit)', Columns))>0;
birdID = XLS.data.Sheet1(:,strmatch('bird', Columns)); 

rows = [find(TUTORING&HASH&PUTPROJ&(birdID==BirdNum))];...
%     find(TUTORING&HASH&SINGLEUNIT&(~PUTPROJ)&(birdID==BirdNum))]; 
% rows = [find(TUTORING&HASH&PUTPROJ);...
%     find(TUTORING&HASH&SINGLEUNIT&(~PUTPROJ))]; % across all birds

%% compile spiketimes and segtimes
boutnum = 1; 
sylpatchesX = [];
sylpatchesY = [];
lastBoutByRowMinusOne = 1; lastBoutByRowMinusOne((1:length(rows))+1) = 0;
soundclip = {}; OffsetTime = []; 
spkT = []; 
spkRow = []; 
spkBout = [];
for rowi = 1:length(rows); 
    row = rows(rowi); 
    % load analysis file
    [dbase rowstr{rowi} pathname filename] = getDbase_elm(row, XLS, Columns);
    eventNum = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns));
    fs = dbase.Fs;
    usefile = []; 
    for file = 1:length(dbase.SegmentTimes)
        % compile syl times and titles, exclude unselected syls
        segIsSel = find(dbase.SegmentIsSelected{file});
        segTimes = dbase.SegmentTimes{file}(segIsSel,:)/fs; % whole file, just selected segs, in sec
        segTitles = dbase.SegmentTitles{file}(segIsSel); % whole file, just selected segs
        spiketimes = dbase.EventTimes{eventNum}{1,file}/fs; % whole file, in sec
        spiketimes = spiketimes(dbase.EventIsSelected{1,eventNum}{1,file}==1); % only keep selected spikes
        if length(segTitles)>0 % if file has any syllables
            SylIsD = 1:length(segTitles); % find candidate bouts (find each syl D, or in general, syl to align to)
            SylIsD = SylIsD((SylIsD+OtherSyls(end))<=length(segTitles) &...
                ((SylIsD+OtherSyls(1))>=1)); % make sure it's not too close to the edge of the file
            for bout = SylIsD % for each candidate bout
                params.CheckTheseTimes = segTimes(OtherSyls+bout,:) - segTimes(bout,1);
                params.Method = 'times'; 
                BoutMatches = MotifCheck(params); % check all the other syls match
                if BoutMatches ...
                         &&(boutnum-lastBoutByRowMinusOne(rowi))<MaxToPlot; % only MaxToPlot bouts per neuron
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
                    spks = spiketimes((spiketimes>(bTime+twindow(1))) & ...
                        (spiketimes<(bTime+twindow(2))))-bTime; 
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
    lastBoutByRowMinusOne(rowi+1) = boutnum;
    if length(usefile)>0 
        % extract an example spectrogram
        filename = fullfile(dbase.PathName,dbase.SoundFiles(usefile).name);
%         OffsetTime(rowi) = segTimes(1,1); 
        soundclip{rowi} = egl_AA_daq(filename,1); 
        soundclip{rowi} = soundclip{rowi}((1:length(soundclip{rowi}))>fs*(bTime+twindow(1)) & ...
            (1:length(soundclip{rowi}))<fs*(bTime+twindow(2)));
    else 
        soundclip{rowi} = []; 
    end
end
% take out empty rows
NoBoutsInd = find(cellfun(@(x) length(x)==0, soundclip)); 
soundclip(NoBoutsInd) = []; 
rows(NoBoutsInd) = []; 
rowstr(NoBoutsInd) = []; 
lastBoutByRowMinusOne(NoBoutsInd+1) = [];

%%
% plot
figure(7);clf; shg
color_palet = [[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
Colors = color_palet(mod(1:length(rows),size(color_palet,1))+1,:); 
mainplot = subplot('position', [.1 .1 .8 .7]);
hold all;
for syli = 1:size(sylpatchesX,1)
    patch(sylpatchesX(syli,:),sylpatchesY(syli,:),  .75*[1 1 1], 'edgecolor', 'none'); 
end
for rowi = 1:length(rows)
    row = rows(rowi); 
    if length(soundclip{rowi})>0; 
        subplot(mainplot)
        rowInd = find(spkRow == row); 
        [plotX plotY] = forRasterPlot(spkT(rowInd), spkBout(rowInd)); % adds nans for easy raster plot
        plot(plotX, plotY, 'Color', Colors(rowi,:))
%         if CTEST(row)
%             rowstr{rowi} = [rowstr{rowi} '_CTEST']; 
%         end
        text(twindow(1), lastBoutByRowMinusOne(rowi+1), rowstr{rowi}, 'interpreter', 'none', 'fontsize', 5, 'verticalalignment', 'top')
        shiftLastBBRow = [lastBoutByRowMinusOne]-1; 
        splot = subplot('position', [.1, .8, .8, .1]);
        [S,Time,F] = spectrogramELM(TutorSong,TutorFs, .002, 0); 
%         temp = get(gca, 'Children'); 
%         cdata = get(temp, 'Cdata');
%         xdata = get(temp, 'Xdata'); 
        cdata = 10*log10(S); 
        cdata(cdata<prctile(cdata(:),50)) = prctile(cdata(:),50);
        imagesc(Time - SEGTIMES(1,1),F, cdata); 
%         WhereBtMinAndMaxIsMedian = (prctile(cdata(:),50) - min(cdata(:)))/(max(cdata(:)) - min(cdata(:)));
%         if length(WhereBtMinAndMaxIsMedian) == 0; WhereBtMinAndMaxIsMedian = .5; end
        cmap = flipud(pink); colormap(cmap)
%         cmap = [repmat([1 1 1],round(64*WhereBtMinAndMaxIsMedian/(1-WhereBtMinAndMaxIsMedian)),1); cmap]; colormap(cmap)
        set(gca, 'ydir', 'normal'); axis off
    end
end
linkaxes([mainplot, splot], 'x')
title([Title])
subplot(mainplot)
set(gca, 'ytick', []);xlim(twindow)
xlabel('Time (s)', 'fontsize', 8)
box off; axis tight
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)

papersize = [8.5 min(11, lastBoutByRowMinusOne(end)*.15)];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 


%% Firing rate matrix
% for each row, find the mean FR for that row
dt = .002; 
smoothwin =  30; 
perpl = 150; % for tSNE, dt.01,sw15,perpl64
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
interneuronInd = (mean(FR,2)>10); %rows(interneuronInd) are the interneuron rows
projInd = PUTPROJ(rows); 
[~,sortorder] = sort(mean(FR,2), 'ascend'); % sort by firing rate
sortLabels = {}; for ti =1:length(rows); sortLabels{ti} = num2str(rows(sortorder(ti))); end 
% set(gca, 'xtick', 1:length(rows), 'xticklabels', sortLabels)
figure(4); clf

imagesc(rawFR(sortorder,:), 'xdata', Time)
xlim(twindow);

colormap(flipud(gray))
xlabel('Time (s)'); ylabel('Neuron #')
set(gca, 'ytick', 1:length(rows), 'yticklabels', sortLabels)
axis tight
xlim(twindow); 
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 6)
title(['FR matrix ' Title ])


% make dot colors
DotColors = .6*ones(length(Time),3); 
sylIDs = {'i' 'A' 'B' 'C' 'D' 'E' 'A' 'B' 'C' 'D' 'E' 'A' 'B' 'C' 'D' 'E' ...
    'A' 'B' 'C' 'D' 'E' 'A' 'B' 'C' 'D' 'E' 'i' 'A' 'B' 'C' 'D' 'E' 'A' 'B' 'C' 'D' 'E'}; 
uSylIDs = unique(sylIDs); 
% sylColors = flipud(lines(length(uSylIDs))); 
color_palet = [[0 0 1]; [1 0 0]; [0 1 0]; [0 1 1]; [1 1 0]; [1 0 1]; [.7 .4 1]; [0 1 0]; [1 0 0]; [.6 .8 .3]; [0 0 1]]; 
sylColors = color_palet(1:length(uSylIDs),:); 
for segi = 1:size(SEGTIMES,1)
    ind = find(Time>(SEGTIMES(segi,1)-0) & Time<SEGTIMES(segi,2));
    sylID = strmatch(sylIDs{segi}, uSylIDs); 
    C = sylColors(sylID,:); 
    C = C/max(C); 
    DotColors(ind,:) = ...
        (1*repmat(C, length(ind),1)).*...
        (.2+.8*repmat((1:length(ind))'/length(ind),1,3)); 
end
LineColors = gray(length(Time)); 
hold on
scatter(Time,ones(1,length(Time)), 'cdata', DotColors, 'markerfacecolor', 'flat')
%
figure(5); clf; hold on
tinduse = 1:length(Time);%find(sum(abs(diff(DotColors,2)),2)>0); %(Time>-.1)&(Time<6.4); %sum(abs(diff(DotColors,2)),2)>0; %1:length(Time);%sum(DotColors,2)>min(sum(DotColors,2)); %1:length(Time);%sum(DotColors,2)>min(sum(DotColors,2)); %1:length(Time);
ninduse = 1:size(FR,1); %projInd; %
msFR = bsxfun(@minus, FR(ninduse,tinduse), mean(FR(ninduse,tinduse),2));%zscore(FR(ninduse,tinduse)); %

% %% plot timextime corr mat
% clf; hold on
% imagesc(corr(msFR), 'xdata', Time, 'ydata', Time)
% axis tight
% lims = xlim; 
% SEGTIMES_startsatzero = SEGTIMES - SEGTIMES(1,1); 
% for segi = 1:length(SEGTIMES)
%     plot(lims, SEGTIMES_startsatzero(segi,1)*ones(1,2), 'k')
%     plot(SEGTIMES_startsatzero(segi,1)*ones(1,2), lims, 'k')
%     plot(lims, SEGTIMES_startsatzero(segi,2)*ones(1,2), 'r')
%     plot(SEGTIMES_startsatzero(segi,2)*ones(1,2), lims, 'r')
% end
% colormap parula; xlabel('Time (s)'); ylabel('Time (s)')
% 
% shg

%% dimensionality red
%
% for SVD
% [U,S,V] = svd(msFR);
% xdata = U(:,1)'*msFR;
% ydata = U(:,2)'*msFR;

% nnmf
% [W,H] = nnmf(FR(ninduse,:),3);
% xdata = H(1,:); 
% ydata = H(2,:); 

% mdscale
% [Y] = mdscale(1-corr(FR),3, 'criterion', 'stress');
% xdata = Y(:,1); 
% ydata = Y(:,2); 


% for tSNE
parameters.perplexity = perpl; 
parameters.num_tsne_dim = 2; 
[yData,betas,P,errors] = run_tSne((FR(ninduse,tinduse)+1)',parameters);
xdata = yData(:,1);
ydata = yData(:,2);

%
clf
tplot = subplot('position', [.1 .1 .8 .65])

% zdata = yData(:,3);
hold on
% plot(xdata,ydata, 'color', .8*[1 1 1]); 
scatter(xdata, ydata, 's','cdata', ...
    DotColors(tinduse,:), ...
    'sizedata', 100*sum(FR(ninduse,tinduse),1)/max(sum(FR(ninduse,tinduse),1)),...
    'markerfacecolor', 'flat')
scatter(xdata, ydata, 's', 'cdata',...
    LineColors(tinduse,:), ...
    'sizedata', 5,...
    'markerfacecolor', 'flat')
axis off; 


%
mplot = subplot('position', [.1 .75 .8 .1]); 
plot(Time,xdata); hold on; plot(Time,ydata); axis tight; axis off

splot = subplot('position', [.1 .85 .8 .05]); hold on
[Spec,Time1,F] = spectrogramELM(TutorSong,TutorFs, .002, 0); 
%         temp = get(gca, 'Children'); 
%         cdata = get(temp, 'Cdata');
%         xdata = get(temp, 'Xdata'); 
cdata = 10*log10(Spec); 
cdata(cdata<prctile(cdata(:),50)) = prctile(cdata(:),50);
imagesc(Time1 - SEGTIMES(1,1),F, cdata); 
set(gca, 'ydir', 'normal')
% showpts = ones(1,length(Time)); 
% showpts(ydata<0) = nan; 
% plot(Time(tinduse), 3000*showpts, 'r')
scatter(Time,5500*ones(1,length(Time)), '^', 'cdata', LineColors, 'markerfacecolor', 'flat')
scatter(Time,5700*ones(1,length(Time)), '^', 'cdata', DotColors, 'markerfacecolor', 'flat')
colormap(flipud(gray))
xlim(twindow)
ylim([min(F) max(F)])
axis off; shg
set(gcf, 'color', [1 1 1])
linkaxes([splot,mplot],'x')

% for movie thing
% subplot(tplot) 
% cc = plot(xdata(1), ydata(1), 'r*', 'markersize', 50);
% subplot(splot)
% dd = plot(Time(1), 3000, 'r^', 'markerfacecolor', 'r'); 
% for ti = 1:length(tinduse)
%     set(cc, 'xdata', xdata(ti), 'ydata', ydata(ti));
%     set(dd, 'xdata', Time(tinduse(ti))); 
%     pause(.01); 
% end

% subplot(splot); 
% tselected = ones(1,length(Time)); 
% tselected(xdata<7) = nan; 
% plot(Time,3000*tselected, '.')
%%
%1:length(Time);