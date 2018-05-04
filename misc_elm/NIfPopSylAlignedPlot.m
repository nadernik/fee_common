clear all; clc
[XLS, Columns] = loadNIfSpreadsheet_elm(); 
SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
TUTORING = XLS.data.Sheet1(:,strmatch('tutoring?', Columns))==1;
ASUBSONG = XLS.data.Sheet1(:,strmatch('art subsong?', Columns))==1;
SINGLEUNIT = XLS.data.Sheet1(:,strmatch('quality (1 = bad multi, 2 = ok, 3 = single, 4 = good single)', Columns))>=3; 
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1;
PUTPROJ = XLS.data.Sheet1(:,strmatch('Put Proj?', Columns))==1;
HASH = XLS.data.Sheet1(:,strmatch('hash? (2  = unit)', Columns))>0;
UNITINHASH = XLS.data.Sheet1(:,strmatch('hash? (2  = unit)', Columns))==2;
hashLat = XLS.data.Sheet1(:,strmatch('latency (ms)', Columns));
hashLatJitt = XLS.data.Sheet1(:,strmatch('LatJitt (us)', Columns));
SYLSEL = XLS.data.Sheet1(:,strmatch('maybe Syl selective?', Columns))==1;
ISOLATE = XLS.data.Sheet1(:,strmatch('isolate', Columns))==1;
% Age
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
day = [0; cellfun(@(X) datenum(X(1:end-4)), XLS.textdata.Sheet1(2:end,strmatch('day', Columns)))];
Age = day - birthday; 
% Histology
Electrode = XLS.data.Sheet1(:,strmatch('electrode #', Columns));
GoodHistvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('hist. confidence', Columns)), 'uniformoutput', 0); 
GoodHistvec(2:end+1) = GoodHistvec(1:end); % to make rows line up (first row is section headings)
Dvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('[D_E1, D_E2, D_E3]', Columns)), 'uniformoutput', 0); 
Dvec(2:end+1) = Dvec(1:end); % to make rows line up (first row is section headings)
for rowi = 2:size(XLS.textdata.Sheet1,1)
    goodHist(rowi) = GoodHistvec{rowi}(Electrode(rowi)); 
    elecPosition(rowi) = Dvec{rowi}(Electrode(rowi)); 
end
% for coloring by bird id
birdID = XLS.data.Sheet1(:,strmatch('bird', Columns)); 
[~,~,birdnum] = unique(birdID); 
birdColors = lines(length(unique(birdnum))); 
SUBSONG = zeros(size(XLS.data.Sheet1,1),1); SUBSONG(strmatch('subsong', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
PROTOSYLLABLE = zeros(size(XLS.data.Sheet1,1),1); PROTOSYLLABLE(strmatch('protosyllable', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
DIFF = zeros(size(XLS.data.Sheet1,1),1); DIFF(strmatch('diff', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
%% choose what rows to use
Title = 'TUTORING&HASH&SINGLEUNIT'; 
rows = find(eval(Title));
[~,sortInd] = sort(Age(rows), 'ascend'); 
rows = rows(sortInd); 
desDurRange = [.04 .12]; % only plot syllables of this duration range
desMinPrevAndNextGap = [0 0]; % 0 for no restriction
desMaxPrevAndNextGap = [Inf Inf]; % inf for no restriction
AlignSylType = 'tutor'; 
twindow = [-.3 .3]; % for raster
MeanSegTimes = zeros(3,2); 
oldMeanSegTimes = [twindow(1)*[1 1]; % run it once to determine these, or insert desired time warp times for each syl
    0 .07;
    twindow(2)*[1 1]];

TimeWarp = 0; % choose whether to time-warp
MaxToPlot = 200; % how many syllables to calculate (maxbouts, below, is how many will be plotted...)
maxbouts = 12; % how many syllables to actually plot (choosen randomly)
%% compile spike and syl times


% for time warping
DesiredSegTimes = [oldMeanSegTimes]; 
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
lastBoutByRow = 0;
soundclip = {};
spkT = []; 
spkRow = []; 
spkBout = [];

for rowi = 1:length(rows)
    row = rows(rowi)
    % load analysis file
    [dbase rowstr{rowi} pathname filename] = getDbase_elm(row, XLS, Columns);
%     if CTEST(row)
%         rowstr{rowi} = [rowstr{rowi} '_CTEST']; 
%     end
%     rowstr{rowi} = [rowstr{rowi} '_Age', num2str(Age(row))]; 
    fs = dbase.Fs;
    % getting the relevant info from NIfUnits spreadsheet
    eventNum = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns)); 
    chanNum = XLS.data.Sheet1(row,strmatch('electrode #', Columns))+1;
    TutorSylNames = eval(XLS.textdata.Sheet1{row,strmatch('T syl names', Columns)});
    SongSylNames = eval(XLS.textdata.Sheet1{row,strmatch('song syl names', Columns)});
    for file = 1:length(dbase.SegmentIsSelected); 
        % compile syl times and titles, exclude unselected syls
        segIsSel = find(dbase.SegmentIsSelected{file});
        segTimes = dbase.SegmentTimes{file}(segIsSel,:)/fs; % whole file, just selected segs, in sec
        segTitles = dbase.SegmentTitles{file}(segIsSel); % whole file, just selected segs
        spiketimes = dbase.EventTimes{eventNum}{1,file}/fs; % whole file, in sec
        spiketimes = spiketimes(dbase.EventIsSelected{1,eventNum}{1,file}==1); % only keep selected spikes
        if length(segTitles)>0 % if file has any syllables
            for bout = 1:length(segTitles) % for each candidate syl
                isSongSyl = sum(cellfun(@(x) (issame(x,segTitles{bout})|((length(x)==0)&(length(segTitles{bout})==0))), SongSylNames, 'UniformOutput', 1))>0;
                isTutorSyl = sum(cellfun(@(x) (issame(x,segTitles{bout})|((length(x)==0)&(length(segTitles{bout})==0))), TutorSylNames, 'UniformOutput', 1))>0;
                if bout>1
                    PrevGap = segTimes(bout,1)-segTimes(bout-1,2);
                else
                    PrevGap = segTimes(bout,1); 
                end
                if bout<length(segTitles)-1
                    NextGap = segTimes(bout+1,1)-segTimes(bout,2);
                else
                    NextGap = dbase.FileLength(file)/fs-segTimes(bout,2); 
                end
                if ((boutnum-lastBoutByRow(max(1,rowi-1)))<MaxToPlot) ... % only MaxToPlot bouts per neuron
                        &&(PrevGap>desMinPrevAndNextGap(1)) ... % prev gap isn't too small
                        &&(PrevGap<desMaxPrevAndNextGap(1)) ... % prev gap isn't too big
                        &&(NextGap>desMinPrevAndNextGap(2)) ... % next gap isn't too small
                        &&(NextGap<desMaxPrevAndNextGap(2)) ... % prev gap isn't too small
                        &&((isequal('song', AlignSylType)&&isSongSyl)||(isequal('tutor', AlignSylType)&&isTutorSyl)) ... % check that it's the right syltype
                        &&((diff(segTimes(bout,:)))>=desDurRange(1))&&((diff(segTimes(bout,:)))<=desDurRange(2)) % syl is of desired duration
                    bTime = segTimes(bout,1); % start time of syl you're aligning to
                    
                    % compile this bout's segments.. add more entries to sylpatchesX and sylpatchesY
                    if TimeWarp
                        segtimes = DesiredSegTimes; % one bout of seg times
                    else
                        segtimes = segTimes; 
                        segtimes = segtimes((segtimes(:,2)>(bTime+twindow(1))) & ...
                            (segtimes(:,1)<(bTime+twindow(2))),:)-bTime; % just this bout
                        segtimes(:,1) = max(segtimes(:,1), twindow(1)); 
                        segtimes(:,2) = min(segtimes(:,2), twindow(2)); 
                    end
                    for syli = 1:size(segtimes,1)
                        tmp = segtimes(syli,:); 
                        sylpatchesX = [sylpatchesX; [tmp(1) tmp(1) tmp(2) tmp(2) tmp(1)]]; 
                        sylpatchesY = [sylpatchesY; [boutnum+1 boutnum boutnum boutnum+1 boutnum+1]]; 
                    end

                    % compile this bout's spike times
                    if TimeWarp
                        ActualSegTimes = segTimes(bout,:);
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
                    

                    % compile all spike times
                    if length(spks) == 0
                        spks = nan; 
                    end
                    nSpks = length(spks); 
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
    lastBoutByRow(rowi) = boutnum-1; 
%     % extract an example spectrogram
%     filename = fullfile(dbase.PathName,dbase.SoundFiles(usefile).name);
%     soundclip{row} = egl_AA_daq(filename,1); 
%     soundclip{row} = soundclip{row}((1:length(soundclip{row}))>fs*(bTime+tswindow(1)) & ...
%         (1:length(soundclip{row}))<fs*(bTime+tswindow(2)));
end
MeanSegTimes = MeanSegTimes/boutnum; 

%%

%% plot
figure(7);clf; shg
color_palet = [[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
Colors = color_palet(mod(1:length(rows),size(color_palet,1))+1,:); 
mainplot = subplot('position', [.1 .1 .8 .8])
hold all;

% will restrict to maxbouts random bouts
lastBoutByRowr = lastBoutByRow;


cumbout = 0; 
boutTranslation = 1:max(unique(spkBout)); 
for rowi = 1:length(rows); 
    row = rows(rowi)
    subplot(mainplot)
    rowInd = find(spkRow == row); 
    [rowBouts,ia,ic] = unique(spkBout(rowInd)); 
    
    % to plot rates with highest firing
    srate = [];
    for bi = 1:length(rowBouts)
        candspks = spkT(spkBout==bi&spkT>-.1&spkT<.05); 
        ISIs = [diff(candspks); 100]; % adding 100 in case there are fewer than 2 spikes
        srate(bi) = 1./min(ISIs); 
    end
    [~,PlotBoutInd] = sort(srate, 'descend'); 
    PlotBouts =rowBouts(PlotBoutInd); 
    
%     PlotBouts = rowBouts(randperm(length(rowBouts))); % to plot random bouts
    PlotBouts = PlotBouts(1:min(maxbouts,length(PlotBouts))); 
    [~,~,boutTranslation(PlotBouts)] = unique(PlotBouts); 
    boutTranslation(PlotBouts) = boutTranslation(PlotBouts) + cumbout; 
    indKeep = ismember(spkBout, PlotBouts); 
    tmpInd = find(ismember(sylpatchesY(:,2), PlotBouts)); 
    for syli = 1:length(tmpInd)
        newY = boutTranslation(sylpatchesY(tmpInd(syli),2)); 
        patch(sylpatchesX(tmpInd(syli),:),...
            newY*[0 1 1 0 0]+ (newY+1)*[1 0 0 1 1],  ...
            .9*[1 1 1], 'edgecolor', 'none'); 
    end
    [plotX plotY] = forRasterPlot(spkT(indKeep), boutTranslation(spkBout(indKeep))); % adds nans for easy raster plot
    plot(plotX, plotY, 'Color', Colors(rowi,:), 'linewidth', 1)
    cumbout = cumbout + length(PlotBouts);
    lastBoutByRowr(rowi) = cumbout; 
%     plot(twindow, (lastBoutByRowr(rowi)+1)*[1 1], 'k')

    text(twindow(1), lastBoutByRowr(rowi)+1, rowstr{rowi}, 'interpreter', 'none', 'fontsize', 5, 'verticalalignment', 'top')
end
% for syli = 1:size(sylpatchesXr,1)
%     patch(sylpatchesXr(syli,:),sylpatchesYr(syli,:),  .95*[1 1 1], 'edgecolor', 'none'); 
% end
subplot(mainplot)
set(gca, 'ytick', []);
xlabel('Time (s)', 'fontsize', 8)
box off; axis tight
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
title([Title, ' NIf, ', AlignSylType, ', timewarp=' num2str(TimeWarp), ', SylDurRange=[' num2str(desDurRange) ']'])
papersize = [8.5 11];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
