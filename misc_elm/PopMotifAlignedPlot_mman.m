clear all; clc
%% 6664
BirdNum = 6664; %

Title = 'MMANMotif6664';
xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/MMANMotif6664.xlsx'; 

AlignSyl = 'A'; 
AllSylNames = {'A' 'B' 'C' 'D'}; % names of other syls in bout
NextSylBlank = 0; 
PrevSylBlank = 0; 
NextGapMin = 0; 

% %FOR ABC
% twindow = [-.1 .3]; % for raster
% tswindow = [-.03 .25]; % for spectrograms

%FOR ABCD
twindow = [-.15 .7]; % for raster
tswindow = [-.03 .6]; % for spectrograms

OtherSyls = (1:length(AllSylNames)) - strmatch(AlignSyl,AllSylNames); % rel indices of other syls in bout
MeanSegTimes = zeros(length(OtherSyls)+2,2); 
oldMeanSegTimes = [0,0.0653307692307609;0.0874692307692197,0.134671153846137;0.158973076923057,0.220478846153818; 0.3128    0.5222]; % for ABCD
% oldMeanSegTimes = [0,0.0653307692307609;0.0874692307692197,0.134671153846137;0.158973076923057,0.220478846153818];

% choose whether to time-warp
TimeWarp = 1; 
MaxToPlot = 8;  
maxbouts = 5; % didn't actually implement yet
%
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
    usefile = []; 
    for file = GoodFiles{row}
        % compile syl times and titles, exclude unselected syls
        segIsSel = find(dbase.SegmentIsSelected{file});
        segTimes = dbase.SegmentTimes{file}(segIsSel,:)/fs; % whole file, just selected segs, in sec
        segTitles = dbase.SegmentTitles{file}(segIsSel); % whole file, just selected segs
        spiketimes = dbase.EventTimes{eventNum}{1,file}/fs; % whole file, in sec
        spiketimes = spiketimes(dbase.EventIsSelected{1,eventNum}{1,file}==1); % only keep selected spikes
        if length(segTitles)>0 % if file has any syllables
            SylIsD = find(cellfun(@(X) issame(X,AlignSyl), segTitles)); % find candidate bouts (find each syl D, or in general, syl to align to)
            SylIsD = SylIsD((SylIsD+OtherSyls(1)-PrevSylBlank)>0&(SylIsD+OtherSyls(end)+NextSylBlank)...
                <=length(segTitles)); % make sure it's not too close to the edge of the file
            for bout = SylIsD % for each candidate bout
                if NextSylBlank
                    nextIsBlank = length(segTitles{OtherSyls(end)+bout+1})==0; 
                else
                    nextIsBlank = 1; 
                end
                if PrevSylBlank
                    prevIsBlank = length(segTitles{OtherSyls(1)+bout-1})==0; 
                else
                    prevIsBlank = 1; 
                end
                if OtherSyls(end)+bout < length(segTitles); 
                    NextOnset = segTimes(OtherSyls(end)+1+bout,1);
                else
                    NextOnset = dbase.FileLength(file)/fs;
                end
                nextGapLength = NextOnset - segTimes(OtherSyls(end)+bout,2); 
                if isequal(segTitles(OtherSyls+bout), AllSylNames) ... % check all the other syls match
                        && nextIsBlank ... % if required, check that next syl is blank
                        && prevIsBlank ... % if required, check that prev syl is blank
                        && (nextGapLength >= NextGapMin) ... % check that next gap is long enough
                        &&(boutnum-lastBoutByRow(row-1))<MaxToPlot; % only MaxToPlot bouts per neuron
                    bTime = segTimes(bout,1); % start time of syl you're aligning to
                    % compile this bout's segments.. add more entries to sylpatchesX and sylpatchesY
                    if TimeWarp
                        segtimes = DesiredSegTimes; % one bout of seg times
                    else
                        segtimes = segTimes; 
                        segtimes = segtimes((segtimes(:,2)>(bTime+twindow(1))) & ...
                            (segtimes(:,1)<(bTime+twindow(2))),:)-bTime; % just this bout
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
    
    lastBoutByRow(row) = boutnum;
    if length(usefile)>0 
        % extract an example spectrogram
        filename = fullfile(dbase.PathName,dbase.SoundFiles(usefile).name);
        soundclip{row} = egl_AA_daq(filename,1); 
        soundclip{row} = soundclip{row}((1:length(soundclip{row}))>fs*(bTime+tswindow(1)) & ...
            (1:length(soundclip{row}))<fs*(bTime+tswindow(2)));
    else 
        soundclip{row} = []; 
    end
end
MeanSegTimes = MeanSegTimes/boutnum; 
%
% consider: for each row pick the bouts with highest firing rates
% For each row
% for row = rows
%     bouts = unique(spkBout(spkRow == row)); 
%     fr = []; 
%     for bi = 1:length(bouts)
%         fr(bi) = sum(spkBout==bi); 
%     end
%     [~,sortind] = sort(fr, 'descend')
%     indkeepSpks = ismember(spkBout, bouts(sortind(1:min(maxbouts,length(sortind))))); 
%     lastBoutByRow(row) = lastBoutByRow(row) - sum((~indkeepSpks)&(spkRow==row)); 
%     inddiscardsyls = ismember(sylpatchesY(:,2), bouts(sortind((min(maxbouts,length(sortind))+1):end))); 
%     sylpatchesX(inddiscardsyls,:) = []; 
%     sylpatchesY(inddiscardsyls,:) = []; %fix this...
%     spkT((~indkeepSpks)&(spkRow==row)) = []; 
%     spkBout((~indkeepSpks)&(spkRow==row)) = []; 
%     spkRow((~indkeepSpks)&(spkRow==row)) = []; 
% 
% end
% for each bout, calculate fr
% keep only bouts with highest fr
% 

% plot
figure(7);clf; shg
color_palet = [[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
Colors = color_palet(mod(1:max(rows),size(color_palet,1))+1,:); 
mainplot = subplot('position', [.1 .1 .6 .8])
hold all;
for syli = 1:size(sylpatchesX,1)
    patch(sylpatchesX(syli,:),sylpatchesY(syli,:),  .75*[1 1 1], 'edgecolor', 'none'); 
end
for row = rows; 
    if length(soundclip{row})>0; 
        subplot(mainplot)
        rowInd = find(spkRow == row); 
        [plotX plotY] = forRasterPlot(spkT(rowInd), spkBout(rowInd)); % adds nans for easy raster plot
        plot(plotX, plotY, 'Color', Colors(row,:))
        if CTEST(row)
            rowstr{row} = [rowstr{row} '_CTEST']; 
        end
        text(twindow(1), lastBoutByRow(row), rowstr{row}, 'interpreter', 'none', 'fontsize', 5, 'verticalalignment', 'top')
        subplot('position', [.7 .1+.8*(lastBoutByRow(row-1)-1)/(lastBoutByRow(end)-1) ...
            .2 .8/(lastBoutByRow(end)-1)*(lastBoutByRow(row)-lastBoutByRow(row-1))]); 
        axis off
        displaySpecgramQuick(soundclip{row},fs); 
        temp = get(gca, 'Children'); 
        cdata = get(temp, 'Cdata');
        WhereBtMinAndMaxIsMedian = (prctile(cdata(:),50) - min(cdata(:)))/(max(cdata(:)) - min(cdata(:)));
%         if length(WhereBtMinAndMaxIsMedian) == 0; WhereBtMinAndMaxIsMedian = .5; end
        cmap = flipud(pink); cmap = [repmat([1 1 1],round(64*WhereBtMinAndMaxIsMedian/(1-WhereBtMinAndMaxIsMedian)),1); cmap]; colormap(cmap)
        axis off
    end
end
subplot(mainplot)
set(gca, 'ytick', []);
xlabel('Time (s)', 'fontsize', 8)
box off; axis tight; xlim(twindow);
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
Title = [Title '  ']; 
for syli = 1:length(AllSylNames)
    if issame(AllSylNames{syli}, AlignSyl)
        Title = [Title '.' AllSylNames{syli}];
    else
        Title = [Title AllSylNames{syli}];
    end
end
title([Title ', warp=' num2str(TimeWarp)])
papersize = [8 min(6, lastBoutByRow(end)*.15)];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
