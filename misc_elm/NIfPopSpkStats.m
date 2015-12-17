% NIf cell type characterization

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
Title = 'SINGING&HASH&SINGLEUNIT'; 
rows = find(eval(Title));
% [~,sortInd] = sort(Age(rows), 'ascend'); 
% rows = rows(sortInd); 
desDurRange = [.04 .12]; % only plot syllables of this duration range
desMinPrevAndNextGap = [0 0]; % 0 for no restriction
desMaxPrevAndNextGap = [Inf Inf]; % inf for no restriction
AlignSylType = 'song'; 
twindow = [-.3 .3]; % for raster
MeanSegTimes = zeros(3,2); 
oldMeanSegTimes = [twindow(1)*[1 1]; % run it once to determine these, or insert desired time warp times for each syl
    0 .07;
    twindow(2)*[1 1]];

TimeWarp = 0; % choose whether to time-warp
MaxToPlot = 200; % how many syllables to calculate (maxbouts, below, is how many will be plotted...)
maxbouts = 12; % how many syllables to actually plot (choosen randomly)

%%
fs = 40000;
% decide time bins
Maxlag = .5; 
ISItbins = logspace(-3.5,log10(Maxlag), 200); 
smwinISI = 9; % # of bins
Autocorrtbins = ISItbins; %0:1/fs:Maxlag; 
smwinAC =  9; % # of bins, each bin is 1/fs
% initialize
ISI_Sing = zeros(length(rows),length(ISItbins)); 
ISI_NonSing = zeros(length(rows),length(ISItbins)); 
% HighFRSing = zeros(length(rows),1); 
% MidFRSing = zeros(length(rows),1); 
Autocorr_Sing = zeros(length(rows),length(Autocorrtbins)); 
Autocorr_NonSing = zeros(length(rows),length(Autocorrtbins)); 
nSpksSong = []; 
nSpksSong = []; 
for rowi = 1:length(rows)
    row = rows(rowi)
    [dbase rowstr{rowi} pathname filename] = getDbase_elm(row, XLS, Columns);
    rowstrShort{rowi} = [num2str(row)]; 
    if CTEST(row)
        rowstrShort{rowi} = [rowstrShort{rowi} 'CT']; 
    end
    fs = dbase.Fs;
    % getting the relevant info from NIfUnits spreadsheet
    eventNum = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns)); 
    chanNum = XLS.data.Sheet1(row,strmatch('electrode #', Columns))+1;
    TutorSylNames = eval(XLS.textdata.Sheet1{row,strmatch('T syl names', Columns)});
    SongSylNames = eval(XLS.textdata.Sheet1{row,strmatch('song syl names', Columns)});
    listISIsong{rowi} = []; 
    listISInonsong{rowi} = []; 
    flsISIsong{rowi} = [];
    flsISInonsong{rowi} = [];
    sDiffs = [];
    nsDiffs = [];
    for file = 1:length(dbase.SegmentIsSelected); 
         % compile syl times and titles, exclude unselected syls
        segTimes = dbase.SegmentTimes{file}/fs; % whole file, just selected segs, in sec
        segTitles = dbase.SegmentTitles{file}; % whole file, just selected segs
        isSongSyl = [];
        for segi = 1:size(segTimes,1)
            isSongSyl(segi) = sum(cellfun(@(x) (issame(x,segTitles{segi})|((length(x)==0)&(length(segTitles{segi})==0))), SongSylNames, 'UniformOutput', 1))>0 ...
                & dbase.SegmentIsSelected{file}(segi);
        end
        spiketimes = dbase.EventTimes{eventNum}{1,file}/fs; % whole file, in sec
        spiketimes = spiketimes(dbase.EventIsSelected{1,eventNum}{1,file}==1); % only keep selected spikes
        
        % figure out which spikes are during singing and nonsinging
        if length(spiketimes)>0 % if there are any spikes in the file
            if sum(isSongSyl)>0 % if there are any song syllables
                SongSegTimes = segTimes(isSongSyl==1,:); SongSegTimes = sort(SongSegTimes(:))'; 
                edges = [-Inf, mean([SongSegTimes(2:end); SongSegTimes(1:end-1)]), +Inf];
                songSegInd = discretize(spiketimes,edges);
                ClosestSongOnsetOrOffset = SongSegTimes(songSegInd); 
            else
                ClosestSongOnsetOrOffset = Inf*spiketimes'; 
            end
            if size(segTimes,1)>0 % if there are any syllables
                AllSegTimes = sort(segTimes(:))'; 
                edges = [-Inf, mean([AllSegTimes(2:end); AllSegTimes(1:end-1)]), +Inf];
                SegInd = discretize(spiketimes,edges);
                ClosestOnsetOrOffset = AllSegTimes(SegInd); 
            else
                SegInd = 0*spiketimes'; 
                ClosestOnsetOrOffset = Inf*spiketimes'; 
            end
            
            % Find song ISIs, excluding song ISIs between bouts
            SongInd = abs(spiketimes'-(ClosestSongOnsetOrOffset))<.2; % within 200ms of song syllables
            SongSpiketimes = spiketimes(SongInd);
            songSegInd = songSegInd(SongInd); 
            sISI = diff(SongSpiketimes); 
            sISI = sISI(diff(SongSegTimes(songSegInd))<.3); % no gaps of more than 300ms (only include within-bout isis)
            
            % Find nonsong ISIs, excluding nonsong ISIs that skip around bouts
            NonSongInd = (abs(spiketimes'-ClosestOnsetOrOffset)>.1) & ... 100ms away from any segment
                (abs(spiketimes'-ClosestSongOnsetOrOffset)>.2); % 200ms away from any song segments
            NonSongSpiketimes = spiketimes(NonSongInd); 
            SegInd = SegInd(NonSongInd); 
            nsISI = diff(NonSongSpiketimes); 
            nsISI = nsISI(diff(SegInd)<2); % if skipped over a syllable, don't count that isi 
            
            % compile ISIs
            sISI = sISI(sISI<=Maxlag); 
            nsISI = nsISI(nsISI<=Maxlag); 
            listISIsong{rowi} = [listISIsong{rowi}; sISI];
            flsISIsong{rowi} = [flsISIsong{rowi}; file*ones(length(sISI),1)];
            listISInonsong{rowi} = [listISInonsong{rowi}; nsISI]; 
            flsISInonsong{rowi} = [flsISInonsong{rowi}; file*ones(length(nsISI),1)];
            
            % compile all pairwise diffs... consider also excluding between-bout song ISIs and skip-bout nonsong ISIs
            tmp = bsxfun(@minus,SongSpiketimes, SongSpiketimes'); % all positive pairwise spike diffs
            tmp = tmp((tmp>0) & (tmp<Maxlag)); 
            sDiffs = [sDiffs; tmp]; 
            
            tmp = triu(bsxfun(@minus,NonSongSpiketimes, NonSongSpiketimes')'); % all positive pairwise spike diffs
            tmp = tmp((tmp>0) & (tmp<Maxlag)); 
            nsDiffs = [nsDiffs; tmp]; 
        end
    end
    
    % store autocorrelation functions
    sDiffsForAC{rowi} = sDiffs; 
    nsDiffsForAC{rowi} = nsDiffs; 
    if length(sDiffs)>5e3 % to avoid out of memory errors
        indsd = randperm(length(sDiffs)); 
        indsd = indsd(1:1e3); 
        sDiffs = sDiffs(indsd); 
    end
    if length(nsDiffs)>5e3 % to avoid out of memory errors
        indsd = randperm(length(nsDiffs)); 
        indsd = indsd(1:1e3); 
        nsDiffs = nsDiffs(indsd); 
    end
    
    Autocorr_Sing(rowi,:) = histc(sDiffs, Autocorrtbins); 
    Autocorr_Sing(rowi,:) = smooth(Autocorr_Sing(rowi,:)/max(length(listISIsong{rowi}),1)./diff([1/fs Autocorrtbins]), smwinAC); 
    Autocorr_NonSing(rowi,:) = histc(nsDiffs, Autocorrtbins); 
    Autocorr_NonSing(rowi,:) = smooth(Autocorr_NonSing(rowi,:)/max(length(listISInonsong{rowi}),1)./diff([1/fs Autocorrtbins]), smwinAC); 
    
    % store ISI dists
    minspikes = 20; 
    ISI_Sing(rowi,:) = smooth(histc(listISIsong{rowi}, ISItbins),smwinISI); 
    if sum(ISI_Sing(rowi,:))>minspikes % if there are at least minspikes spikes
        ISI_Sing(rowi,:) = ISI_Sing(rowi,:)/sum(ISI_Sing(rowi,:));
    else
        ISI_Sing(rowi,:) = nan * ISI_Sing(rowi,:); 
        Autocorr_Sing(rowi,:) = nan * Autocorr_Sing(rowi,:); 
    end
    
    ISI_NonSing(rowi,:) = smooth(histc(listISInonsong{rowi}, ISItbins),smwinISI); 
    if sum(ISI_NonSing(rowi,:))>minspikes % if there are at least minspikes spikes
        ISI_NonSing(rowi,:) = ISI_NonSing(rowi,:)/sum(ISI_NonSing(rowi,:)); 
    else
        ISI_NonSing(rowi,:) = nan * ISI_NonSing(rowi,:);
        Autocorr_NonSing(rowi,:) = nan * Autocorr_NonSing(rowi,:); 
    end
    
    % remember how many spikes per row
    nSpksSong(rowi) = length(listISIsong{rowi}); 
    nSpksNonSong(rowi) = length(listISInonsong{rowi});
    display(['row' num2str(row) 'ss' num2str(nSpksNonSong(rowi)) 'nss' num2str(nSpksSong(rowi))])
end
%% Looking at data across files, to look for for outlier files.
subplot(2,1,1); 

for rowi = 1:length(rows)
    row = rows(rowi);
    figure(7); clf; hold on; shg
    
    subplot(2,1,1); hold all
    plot(flsISInonsong{rowi}+.1*randn(size(flsISInonsong{rowi},1),1), listISInonsong{rowi}, 'k.'); 
    set(gca, 'yscale', 'log'); %ylim([1e-4 1.5])
%     distributionPlot(log(listISInonsong{rowi}), 'groups', flsISInonsong{rowi}, 'addSpread', 0,'showMM', 0, 'colormap', .8*[1 1 1])
%     plot(flsISInonsong{rowi}+.1*randn(size(flsISInonsong{rowi},1),1), log(listISInonsong{rowi}), 'k.'); 
%     set(gca, 'ytick', log(yticks), 'yticklabel', yticklabels); 
    
    xlabel('file#'); ylabel('ISI (ms)')
    title('non singing')
    
    subplot(2,1,2); hold all
    plot(flsISIsong{rowi}+.1*randn(size(flsISIsong{rowi},1),1), listISIsong{rowi}, 'r.'); 
    set(gca, 'yscale', 'log'); %ylim([1e-4 1.5])
%     distributionPlot(log(listISIsong{rowi}), 'groups', flsISIsong{rowi}, 'addSpread', 0,'showMM', 0, 'colormap', .8*[1 1 1])
%     plot(flsISIsong{rowi}+.1*randn(size(flsISIsong{rowi},1),1), log(listISIsong{rowi}), 'r.'); 
%     set(gca, 'ytick', log(yticks), 'yticklabel', yticklabels); 
    xlabel('file#'); ylabel('ISI (ms)')
    title('singing')
    suptitle(num2str(row))
    shg
    waitforbuttonpress 
end
%%
clf
minlag = .0005; 
ylim([minlag Maxlag])
set(gca, 'yscale', 'log')
yticklabels = get(gca, 'yticklabel'); 
yticks = get(gca, 'ytick'); 
plInds = {PUTPROJ(rows) ~PUTPROJ(rows)};
plTitls = {'Put Proj' 'Others'};
figure(3); clf; hold all
figure(4); clf; hold all
divFactor = .2; % for setting bin width
for pli = 1:2
    figure(3); % ISIs
    subplot(1,2,pli); 
    hold all
    title(plTitls{pli})
    ind = plInds{pli}
    distributionPlot(cellfun(@(x) (x),listISInonsong(ind), 'uniformoutput', 0),  ...
        'showMM', 0, 'color', .7*[1 1 1], 'histori', 'right', 'addSpread', 0, ...
        'widthDiv', [2 2], 'xNames', rowstrShort(ind), 'histOpt', 2, ...
        'xyOri', 'flipped', 'divFactor', divFactor)
    hold on
    drawnow
    distributionPlot(cellfun(@(x) (x),listISIsong(ind), 'uniformoutput', 0),  ...
        'showMM', 0, 'color', [1 .6 .6], 'histori', 'left', 'addSpread', 0, ...
        'widthDiv', [2 1], 'xNames', rowstrShort(ind), 'histOpt', 2, ...
        'xyOri', 'flipped', 'divFactor', divFactor)
%     xlim(([minlag Maxlag]))
%     xlabel('lag (s)'); grid on
    set(gca, 'xtick', log(yticks), 'xticklabel', yticklabels)%, 'xticklabelrotation', 90)
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 8)
    xlabel('ISI (s)'); grid on
    xlim(log([minlag Maxlag]))
    
    figure(4); % autocorrelations
    subplot(1,2,pli); 
    hold all
    title(plTitls{pli});
    ind = plInds{pli};
    distributionPlot(cellfun(@(x) log(x),nsDiffsForAC(ind), 'uniformoutput', 0),  ...
        'showMM', 0, 'color', .7*[1 1 1], 'histori', 'right', 'addSpread', 0, ...
        'widthDiv', [2 2], 'xNames', rowstrShort(ind), 'histOpt', 2, ...
        'xyOri', 'flipped', 'divFactor', divFactor)
    hold on
    distributionPlot(cellfun(@(x) log(x),sDiffsForAC(ind), 'uniformoutput', 0),  ...
        'showMM', 0, 'color', [1 .6 .6], 'histori', 'left', 'addSpread', 0, ...
        'widthDiv', [2 1], 'xNames', rowstrShort(ind), 'histOpt', 2, ...
        'xyOri', 'flipped', 'divFactor', divFactor)
%     xlim(([minlag Maxlag]))
%     xlabel('lag (s)'); grid on
    set(gca, 'xtick', log(yticks), 'xticklabel', yticklabels)%, 'xticklabelrotation', 90)
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 8)
    xlabel('lag (s)'); grid on
    xlim(log([minlag Maxlag]))
end
figure(3); shg; 
tmp = suptitle('ISI, single units, \color[rgb]{.7 .7 .7}Nonsinging, \color[rgb]{1 .6 .6}Singing')
set(tmp, 'fontsize', 8)
set(gcf, 'papersize', [4 10], 'paperposition', [0 0 4 10], 'color', 'w')
figure(4); shg; 
tmp = suptitle('Autocorrelation, single units, \color[rgb]{.7 .7 .7}Nonsinging, \color[rgb]{1 .6 .6}Singing')
set(tmp, 'fontsize', 8)
set(gcf, 'papersize', [4 10], 'paperposition', [0 0 4 10], 'color', 'w')


%%
figure(5); clf; hold all
figure(6); clf; hold all
indProj = PUTPROJ(rows); 
Colors = lines(4); 

Mats = {ISI_Sing ISI_NonSing ISI_Sing ISI_NonSing};
MatsAC = {Autocorr_Sing Autocorr_NonSing Autocorr_Sing Autocorr_NonSing}; 
Inds = {indProj indProj ~indProj ~indProj}; 
Titles = {'Proj Singing' 'Proj Nonsinging' 'Nonproj Singing' 'Nonproj Nonsinging'}; 

for linei = 1:4

    figure(5) % ISIs
    Mat = Mats{linei}; 
    MatAC = MatsAC{linei}; 
    Ind = Inds{linei}&(~isnan(sum(Mat,2))); 
    Mat = Mat(Ind,:);
    MatAC = MatAC(Ind,:);
    tmpRows = rows(Ind);
    for ti =1:length(tmpRows); 
        sortLabels{ti} = num2str(tmpRows(ti)); 
        if CTEST(tmpRows(ti))
            sortLabels{ti} = [sortLabels{ti} 'CT']; 
        end
    end 

    
    subplot(4,2,linei*2-1); hold on
    plot(ISItbins, Mat(:,:), 'color', (Colors(linei,:)+1)/2); 
    plot(ISItbins,median(Mat), 'color', Colors(linei,:), 'linewidth', 1.5); 
%     errorpatch_asym(ISItbins,median(Mat(Ind,:)), prctile(Mat(Ind,:),25), prctile(Mat(Ind,:),75), Colors(linei,:), (Colors(linei,:)+1)/2);
    ylim([0 .025]); xlim([ISItbins(1) ISItbins(end)])
    title(Titles{linei})
    set(gca, 'xscale', 'log'); xlabel('ISI (s)'); ylabel('p')
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 7)
    
    subplot(4,2,linei*2); hold on
    imagesc(Mat, [0 .025]); axis tight; xlabel('ISI (s)');
    xticks = [86 length(ISItbins)];
    for ti =1:length(xticks); xlabels{ti} = ['10^{' num2str(.1*round(10*log10(ISItbins(xticks(ti))))) '}']; end 
    set(gca, 'ytick', 1:length(tmpRows), 'yticklabel', sortLabels, 'xtick', xticks, 'xticklabel',xlabels)
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 4)

    figure(6) % Autocorrelations
    subplot(4,2,linei*2-1); hold on
    plot(Autocorrtbins, MatAC(:,:), 'color', (Colors(linei,:)+1)/2); 
    plot(Autocorrtbins,median(MatAC), 'color', Colors(linei,:), 'linewidth', 1.5); 
    title(Titles{linei})
    set(gca, 'xscale', 'log');     
    xlabel('Lag (s)'); ylabel('p (Hz)')
    ylim([0 300]); xlim([Autocorrtbins(1) Autocorrtbins(end)])
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 4)
    
    subplot(4,2,linei*2); hold on
    imagesc(MatAC,[0 300]); axis tight; xlabel('Lag (s)');
    xticks = [86 length(ISItbins)];
    for ti =1:length(xticks); xlabels{ti} = ['10^{' num2str(.1*round(10*log10(ISItbins(xticks(ti))))) '}']; end 
    set(gca, 'ytick', 1:length(tmpRows), 'yticklabel', sortLabels, 'xtick', xticks, 'xticklabel',xlabels)
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 4)

end
figure(5); suptitle ('ISI (log bins), single units')
papersize = [8.5 11];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
figure(6); suptitle('Autocorrelation, single units')
papersize = [8.5 11];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%% scatter plot
clf; hold on
Colors = [.8*[1 1 1]; [1 .7 .7]; [1 .5 .5]]; 
SingMFR = cellfun(@(x) length(x)/sum(x),...
    listISIsong);
NonMFR = cellfun(@(x) length(x)/sum(x),...
    listISInonsong);
scatter(SingMFR,NonMFR, 'o', 'cdata', Colors(1+CTEST(rows)+PUTPROJ(rows),:), 'markerfacecolor', 'flat'); 
for rowi = 1:length(rows)
    text(SingMFR(rowi), NonMFR(rowi), num2str(rows(rowi)), ...
        'color', .5*Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:), ...
        'fontsize', 5, 'horizontalalignment', 'center', 'verticalalignment', 'middle')
end
set(gca, 'xscale', 'log', 'yscale', 'log')
tmp = [min(NonMFR) max(SingMFR)]; 
plot(tmp,tmp, 'k'); axis tight
xlabel('Singing Firing Rate (Hz)'); ylabel('Nonsinging Firing Rate (Hz)')
set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 8)
papersize = [5 5];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 

%%
% figure(8); 
% imagesc(ISI_NonSing); 
% for ti =1:length(rows); sortLabels{ti} = [num2str(rows(ti)) 'p' num2str(PUTPROJ(rows(ti)))]; end 
% set(gca, 'ytick', 1:length(rows), 'yticklabels', sortLabels)
% %%
% Colors = jet(2); 
% M = [ISI_Sing ISI_NonSing]; 
% indUsing = ~isnan(sum(M,2)); 
% rowsForSvd = rows(indUsing); 
% M = M(indUsing,:); 
% M = bsxfun(@minus, M, mean(M,2));
% [u,s,v] = svd(M); 
% scatter(M*v(:,1),M*v(:,2), 'cdata',Colors(1+PUTPROJ(rowsForSvd),:), 'markerfacecolor', 'flat');
% legend('a', 'b')