%% bigram analysis for deafened bird
%% load metadata, specify which sequences to compare
clear all; clc
Title = 'NIfDeaf6230';
xlsname = 'C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfDeaf6230.xlsx'; 
XLS = importdata(xlsname);
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
GoodFiles = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('LabeledFiles', Columns)), 'uniformoutput', 0); 
GoodFiles(2:end+1) = GoodFiles(1:end); % to make rows line up (first row is section headings)
SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
rows = 2:size(XLS.data.Sheet1,1);
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1;

% first sequence
AlignSyl = 'C'; 
AllSylNames = {'A' 'B' 'C' 'D' 'E'}; % names of other syls in bout
NextSylBlank = 0;  
PrevSylBlank = 0; 
NextGapMin = 0; 
OtherSyls = (1:length(AllSylNames)) - strmatch(AlignSyl,AllSylNames); % rel indices of other syls in bout
save('temp1.mat', ... % save the sequence specification
    'AlignSyl', 'AllSylNames', 'OtherSyls',...
    'NextSylBlank', 'PrevSylBlank', 'NextGapMin'); 

% other sequence
AlignSyl = 'C'; 
AlignOffsets = 1; % 0 = onsets, 1 = offsets
AllSylNames = {'A' 'B' 'C'}; % names of other syls in bout
NextSylBlank = 1;  
PrevSylBlank = 0; 
NextGapMin = 0; 
OtherSyls = (1:length(AllSylNames)) - strmatch(AlignSyl,AllSylNames); % rel indices of other syls in bout
save('temp2.mat', ... % save the sequence specification
    'AlignSyl', 'AllSylNames','OtherSyls',...
    'NextSylBlank', 'PrevSylBlank', 'NextGapMin'); 

twindow = [-.4 .6]; % for raster
% tswindow = [-.3 .8]; % for spectrograms


MaxToPlot = 100; 
%% for each sequence, compile spkRow, spkT, spkBout

for seqi = 1:2
    load(['temp' num2str(seqi)]) % contains the sequence specification
% initialize boutnum and sylpatchesX,Y
boutnum = 1; 
sylpatchesX = [];
sylpatchesY = [];
lastBoutByRow = 0; lastBoutByRow(rows) = 0;
soundclip = {};
spkT = []; 
spkRow = []; 
spkBout = [];
MeanSegTimes = zeros(length(AllSylNames),2);
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
            SylIsD = SylIsD((SylIsD+OtherSyls(1)-PrevSylBlank)>0&(SylIsD+OtherSyls(end))...
                <=length(segTitles)); % make sure it's not too close to the edge of the file
            for bout = SylIsD % for each candidate bout
                if NextSylBlank & (length(segTitles)>OtherSyls(end)+bout)
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
                    bTime = segTimes(bout,1+AlignOffsets); % start time of syl you're aligning to
                    % compile this bout's segments.. add more entries to sylpatchesX and sylpatchesY
                    segtimes = segTimes; 
                    segtimes = segtimes((segtimes(:,1)>(bTime+twindow(1))) & ...
                        (segtimes(:,2)<(bTime+twindow(2))),:)-bTime; % just this bout
                    MeanSegTimes = MeanSegTimes + segTimes(bout + OtherSyls,:)-bTime; 

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
%                     usefile = file; % will use last bout as example spectrogram
                end
            end
        end
    end
    lastBoutByRow(row) = boutnum;
%     if length(usefile)>0 
%         % extract an example spectrogram
%         filename = fullfile(dbase.PathName,dbase.SoundFiles(usefile).name);
%         soundclip{row} = egl_AA_daq(filename,1); 
%         soundclip{row} = soundclip{row}((1:length(soundclip{row}))>fs*(bTime+tswindow(1)) & ...
%             (1:length(soundclip{row}))<fs*(bTime+tswindow(2)));
%     else 
%         soundclip{row} = []; 
%     end
end
MeanSegTimes = MeanSegTimes/boutnum; 
SPK{seqi} = struct('spkT', spkT, 'spkRow', spkRow, 'spkBout', spkBout,...
    'MeanSegTimes', MeanSegTimes);
end

%% plot the comparison
figure(3); clf
useRows = intersect(unique(SPK{1}.spkRow),unique(SPK{2}.spkRow));
dt = .002; 
smoothwin = 10; 
Time = twindow(1):dt:twindow(2); 
Colors = [0 0 0; 1 0 0]; 
h = []; 
% restrict to rows w data from both sequences
for rowi = 1:length(useRows)
    subplot('position', [.1 .1+.8*(rowi-1)/length(useRows) .8 .8/length(useRows)])
    hold on
    for seqi = 1:2
        % find the bouts
        boutID = unique(SPK{seqi}.spkBout(SPK{seqi}.spkRow==useRows(rowi))); 
        FR{seqi} = []; 
        for bi = 1:length(boutID)
            ind = (SPK{seqi}.spkBout == boutID(bi)) & (SPK{seqi}.spkRow == useRows(rowi)); 
            FR{seqi} (bi,:) = conv(hist(SPK{seqi}.spkT(ind), Time), gausswin(smoothwin), 'same'); 
        end
        errorpatch_asym(Time,median(FR{seqi} ,1), ...
            prctile(FR{seqi} , 5, 1), prctile(FR{seqi} , 95, 1), ...
            Colors(seqi,:), Colors(seqi,:)); 
%         plot(Time,FR, ...
%             'Color', Colors(seqi,:)); 

    end
    for ti = 1:length(Time)
        [h(ti),p,ks2stat] = kstest2(FR{1}(:,ti),FR{2}(:,ti), 'alpha', .05);
    end
    lims = ylim; 
    plot([0 0], lims)
    for syli = 1:length(SPK{1}.MeanSegTimes)
        tmp = SPK{1}.MeanSegTimes(syli,:); 
        if syli<=length(SPK{2}.MeanSegTimes)
            tmpc = [1 0 0]; 
        else
            tmpc = [0 0 0];
        end
        patch([tmp(1) tmp(1) tmp(2) tmp(2) tmp(1)], ...
            [lims(2)*.9 lims(2) lims(2) lims(2)*.9 lims(2)*.9], ...
            'k', 'edgecolor', tmpc)
    end
    patch([Time Time(end) Time(1)],[h 0 0]*lims(2),'g', 'facealpha', .3, 'edgecolor', 'none')
    text(twindow(1), lims(2), rowstr{useRows(rowi)}, ...
        'verticalalignment', 'top', 'horizontalalignment', 'left',...
        'interpreter', 'none', 'fontsize', 6)
    if rowi==1
        set(gca, 'ytick', [], 'color', 'none'); 
        xlabel('Time (s)')
    else
        axis off
    end
    
end
% for each row, make a subplot, plot median and IQR FR for each sequence

papersize = [8.5 11];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%%
% load spreadsheet info


%% compile spiketimes and segtimes
% 
% 
% % plot
% figure(7);clf; shg
% color_palet = [[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
% color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
% Colors = color_palet(mod(1:max(rows),size(color_palet,1))+1,:); 
% mainplot = subplot('position', [.1 .1 .6 .8])
% hold all;
% for syli = 1:size(sylpatchesX,1)
%     patch(sylpatchesX(syli,:),sylpatchesY(syli,:),  .75*[1 1 1], 'edgecolor', 'none'); 
% end
% for row = rows; 
%     if length(soundclip{row})>0; 
%         subplot(mainplot)
%         rowInd = find(spkRow == row); 
%         [plotX plotY] = forRasterPlot(spkT(rowInd), spkBout(rowInd)); % adds nans for easy raster plot
%         plot(plotX, plotY, 'Color', Colors(row,:))
%         if CTEST(row)
%             rowstr{row} = [rowstr{row} '_CTEST']; 
%         end
%         text(twindow(1), lastBoutByRow(row), rowstr{row}, 'interpreter', 'none', 'fontsize', 5, 'verticalalignment', 'top')
%         subplot('position', [.7 .1+.8*(lastBoutByRow(row-1)-1)/(lastBoutByRow(end)-1) ...
%             .2 .8/(lastBoutByRow(end)-1)*(lastBoutByRow(row)-lastBoutByRow(row-1))]); 
%         axis off
%         displaySpecgramQuick(soundclip{row},fs); 
%         temp = get(gca, 'Children'); 
%         cdata = get(temp, 'Cdata');
%         WhereBtMinAndMaxIsMedian = (prctile(cdata(:),50) - min(cdata(:)))/(max(cdata(:)) - min(cdata(:)));
% %         if length(WhereBtMinAndMaxIsMedian) == 0; WhereBtMinAndMaxIsMedian = .5; end
%         cmap = flipud(pink); cmap = [repmat([1 1 1],round(64*WhereBtMinAndMaxIsMedian/(1-WhereBtMinAndMaxIsMedian)),1); cmap]; colormap(cmap)
%         axis off
%     end
% end
% subplot(mainplot)
% set(gca, 'ytick', []);xlim(twindow)
% xlabel('Time (s)', 'fontsize', 8)
% box off; axis tight
% set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
% Title = [Title '  ']; 
% for syli = 1:length(AllSylNames)
%     if issame(AllSylNames{syli}, AlignSyl)
%         Title = [Title '.' AllSylNames{syli}];
%     else
%         Title = [Title AllSylNames{syli}];
%     end
% end
% title([Title ', warp=' num2str(TimeWarp)])
% papersize = [8.5 min(11, lastBoutByRow(end)*.15)];
% set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
% 
