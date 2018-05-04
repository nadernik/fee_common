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
% GoodHistvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('hist. confidence', Columns)), 'uniformoutput', 0); 
% GoodHistvec(2:end+1) = GoodHistvec(1:end); % to make rows line up (first row is section headings)
% Dvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('[D_E1, D_E2, D_E3]', Columns)), 'uniformoutput', 0); 
% Dvec(2:end+1) = Dvec(1:end); % to make rows line up (first row is section headings)
% for rowi = 2:size(XLS.textdata.Sheet1,1)
%     goodHist(rowi) = GoodHistvec{rowi}(Electrode(rowi)); 
%     elecPosition(rowi) = Dvec{rowi}(Electrode(rowi)); 
% end
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
% [~,sortInd] = sort(Age(rows), 'ascend'); 
% rows = rows(sortInd); 
% desDurRange = [.04 .12]; % only plot syllables of this duration range
% desMinPrevAndNextGap = [0 0]; % 0 for no restriction
% desMaxPrevAndNextGap = [Inf Inf]; % inf for no restriction
% AlignSylType = 'song'; 
% twindow = [-.3 .3]; % for raster
% MeanSegTimes = zeros(3,2); 
% oldMeanSegTimes = [twindow(1)*[1 1]; % run it once to determine these, or insert desired time warp times for each syl
%     0 .07;
%     twindow(2)*[1 1]];
% 
% TimeWarp = 0; % choose whether to time-warp
% MaxToPlot = 200; % how many syllables to calculate (maxbouts, below, is how many will be plotted...)
% maxbouts = 12; % how many syllables to actually plot (choosen randomly)

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
Autocorr_Sing = zeros(length(rows),length(Autocorrtbins)); 
Autocorr_NonSing = zeros(length(rows),length(Autocorrtbins)); 
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
    sDiffsForAC{rowi} = []; 
    nsDiffsForAC{rowi} = [];
    TotalSongTime(rowi) = 0; 
    TotalSilentTime(rowi) = 0; 
    nSongSpks(rowi) = 0;
    nSilentSpks(rowi) = 0; 
    for file = 1:length(dbase.SegmentIsSelected); 
         % compile syl times and titles, exclude unselected syls
        segTimes = dbase.SegmentTimes{file}/fs; % whole file, just selected segs, in sec
        segTitles = dbase.SegmentTitles{file}; % whole file, just selected segs
        filelength = dbase.FileLength(file)/fs; 
        isSongSyl = [];
        % divide the file into song bouts and nonsong bouts
        moatSong = .15; % time around song syllables that is still counted as song
        moatNonsong = .15; % time around all syllables that still doesn't count as silence
        CurrentlySong = 0; 
        for segi = 1:size(segTimes,1)
            % SHOULD BE CALLED IS TUTOR SYL, BUT KEPT NAMES THE SAME...
            isSongSyl(segi) = sum(cellfun(@(x) (issame(x,segTitles{segi})|...
                ((length(x)==0)&(length(segTitles{segi})==0))), ...
                TutorSylNames, 'UniformOutput', 1))>0 ...
                & dbase.SegmentIsSelected{file}(segi);
        end
        
        % find song bouts
        SongBouts = segTimes(isSongSyl==1,:); 
        if size(SongBouts,1)>0
            Gaps = [[0; SongBouts(:,2)+moatSong] [SongBouts(:,1)-moatSong; filelength]]; 
            Gaps((Gaps(:,2)-Gaps(:,1))<0,:) = [];
            SongBouts = [[0; Gaps(:,2)] [Gaps(:,1); filelength]]; 
            SongBouts(SongBouts(:,2)==0|SongBouts(:,1) == filelength,:) = [];
        end
        
        % find silent bouts
        if size(segTimes,1)>0
            SilentBouts = [[0; segTimes(:,2)+moatNonsong] [segTimes(:,1)-moatNonsong; filelength]]; 
            SilentBouts((SilentBouts(:,2)-SilentBouts(:,1))<0,:) = [];  
        else
            SilentBouts = [0 filelength]; 
        end
        
        % find spike times in the whole file
        spiketimes = dbase.EventTimes{eventNum}{1,file}/fs; % whole file, in sec
        spiketimes = spiketimes(dbase.EventIsSelected{1,eventNum}{1,file}==1); % only keep selected spikes
        
        % compile isis for song bouts
        for songbi = 1:size(SongBouts,1)
            SongSpiketimes = spiketimes(spiketimes>SongBouts(songbi,1) & spiketimes<SongBouts(songbi,2)); 
            TotalSongTime(rowi) = TotalSongTime(rowi) + diff(SongBouts(songbi,:)); 
            nSongSpks(rowi) = nSongSpks(rowi) + length(SongSpiketimes); 
            sISI = diff(SongSpiketimes); 
            sISI = sISI(sISI<Maxlag); 
            listISIsong{rowi} = [listISIsong{rowi}; sISI];
            flsISIsong{rowi} = [flsISIsong{rowi}; file*ones(length(sISI),1)];
            tmp = bsxfun(@minus,SongSpiketimes, SongSpiketimes'); % all positive pairwise spike diffs
            tmp = tmp((tmp>0) & (tmp<Maxlag)); 
            sDiffsForAC{rowi} = [sDiffsForAC{rowi}; tmp]; % for autocorrelation
        end
        
        % compile isis for silent bouts
        for silentbi = 1:size(SilentBouts,1)
            NonSongSpiketimes = spiketimes(spiketimes>SilentBouts(silentbi,1) & spiketimes<SilentBouts(silentbi,2)); 
            TotalSilentTime(rowi) = TotalSilentTime(rowi) + diff(SilentBouts(silentbi,:)); 
            nSilentSpks(rowi) = nSilentSpks(rowi) + length(NonSongSpiketimes); 
            nsISI = diff(NonSongSpiketimes); 
            nsISI = nsISI(nsISI<Maxlag); 
            listISInonsong{rowi} = [listISInonsong{rowi}; nsISI];
            flsISInonsong{rowi} = [flsISInonsong{rowi}; file*ones(length(nsISI),1)];
            tmp = bsxfun(@minus,NonSongSpiketimes, NonSongSpiketimes'); % all positive pairwise spike diffs
            tmp = tmp((tmp>0) & (tmp<Maxlag)); 
            nsDiffsForAC{rowi} = [nsDiffsForAC{rowi}; tmp]; % for autocorrelation
        end
        
    end

    % store ISI dists and autocorrelation functions
    minspikes = 20; 
    if length(listISIsong{rowi})>minspikes % if there are at least minspikes spikes
        ISI_Sing(rowi,:) = smooth(histc(listISIsong{rowi}, ISItbins),smwinISI);
        ISI_Sing(rowi,:) = ISI_Sing(rowi,:)/sum(ISI_Sing(rowi,:));
        Autocorr_Sing(rowi,:) = histc(sDiffsForAC{rowi}, Autocorrtbins); 
        Autocorr_Sing(rowi,:) = smooth(Autocorr_Sing(rowi,:)/max(length(listISIsong{rowi}),1)./diff([1/fs Autocorrtbins]), smwinAC); 
    else
        ISI_Sing(rowi,:) = nan(1,size(ISI_Sing,2)); 
        Autocorr_Sing(rowi,:) = nan(1,size(Autocorr_Sing,2)); 
    end
    
    if length(listISInonsong{rowi})>minspikes % if there are at least minspikes spikes
        ISI_NonSing(rowi,:) = smooth(histc(listISInonsong{rowi}, ISItbins),smwinISI); 
        ISI_NonSing(rowi,:) = ISI_NonSing(rowi,:)/sum(ISI_NonSing(rowi,:)); 
        Autocorr_NonSing(rowi,:) = histc(nsDiffsForAC{rowi}, Autocorrtbins); 
        Autocorr_NonSing(rowi,:) = smooth(Autocorr_NonSing(rowi,:)/max(length(listISInonsong{rowi}),1)./diff([1/fs Autocorrtbins]), smwinAC); 
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
    title('non tutoring')
    
    subplot(2,1,2); hold all
    plot(flsISIsong{rowi}+.1*randn(size(flsISIsong{rowi},1),1), listISIsong{rowi}, 'r.'); 
    set(gca, 'yscale', 'log'); %ylim([1e-4 1.5])
%     distributionPlot(log(listISIsong{rowi}), 'groups', flsISIsong{rowi}, 'addSpread', 0,'showMM', 0, 'colormap', .8*[1 1 1])
%     plot(flsISIsong{rowi}+.1*randn(size(flsISIsong{rowi},1),1), log(listISIsong{rowi}), 'r.'); 
%     set(gca, 'ytick', log(yticks), 'yticklabel', yticklabels); 
    xlabel('file#'); ylabel('ISI (ms)')
    title('tutoring')
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
MaxToPlot = 3e3; % otherwise distributionPlot won't plot anything when there's too much data. row156 is first to fail I think.
for pli = 1:2
    figure(3); % ISIs
    subplot(1,2,pli); 
    hold all
    title(plTitls{pli})
    ind = plInds{pli}
    distributionPlot(cellfun(@(x) log(x(randsample(end,min(end,MaxToPlot)))),listISInonsong(ind), 'uniformoutput', 0),  ...
        'showMM', 0, 'color', .7*[1 1 1], 'histori', 'right', 'addSpread', 0, ...
        'widthDiv', [2 2], 'xNames', rowstrShort(ind), 'histOpt', 2, ...
        'xyOri', 'flipped', 'divFactor', divFactor)
    hold on
    drawnow
    distributionPlot(cellfun(@(x) log(x(randsample(end,min(end,MaxToPlot)))),listISIsong(ind), 'uniformoutput', 0),  ...
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
    distributionPlot(cellfun(@(x) x(randsample(end,min(end,MaxToPlot))),nsDiffsForAC(ind), 'uniformoutput', 0),  ...
        'showMM', 0, 'color', .7*[1 1 1], 'histori', 'right', 'addSpread', 0, ...
        'widthDiv', [2 2], 'xNames', rowstrShort(ind), 'histOpt', 2, ...
        'xyOri', 'flipped', 'divFactor', divFactor)
    hold on
    distributionPlot(cellfun(@(x) x(randsample(end,min(end,MaxToPlot))),sDiffsForAC(ind), 'uniformoutput', 0),  ...
        'showMM', 0, 'color', [1 .6 .6], 'histori', 'left', 'addSpread', 0, ...
        'widthDiv', [2 1], 'xNames', rowstrShort(ind), 'histOpt', 2, ...
        'xyOri', 'flipped', 'divFactor', divFactor)
    xlim(([minlag Maxlag]))
    xlabel('lag (s)'); grid on
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 8)
%     set(gca, 'xtick', log(yticks), 'xticklabel', yticklabels)%, 'xticklabelrotation', 90)
%     xlabel('lag (s)'); grid on
%     xlim(log([minlag Maxlag]))
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
%% scatter plot of mean firing rate singing and nonsinging
alp = .05; % alpha for confidence intervals
Colors = [.6*[1 1 1]; [1 .6 .6]; [1 0 0]];
SpkMin = 20; % don't plot conf intervals if fewer than SpkMin spks
% Colors = [[1 1 1]; [1 .8 .8]; [1 0 0]];

% confidence interval on mean rate, assuming poisson
% https://en.wikipedia.org/wiki/Poisson_distribution#Parameter_estimation
SingMFR = nSongSpks./TotalSongTime;
SingLFR = .5*chi2inv(alp/2, 2*nSongSpks)./TotalSongTime; %SingMFR+1.96*sqrt(SingMFR/TotalSongTime);
SingUFR = .5*chi2inv(1-alp/2, 2*nSongSpks+2)./TotalSongTime;%SingMFR-1.96*sqrt(SingMFR/TotalSongTime);
NonMFR = nSilentSpks./TotalSilentTime;
NonLFR = .5*chi2inv(alp/2, 2*nSilentSpks)./TotalSilentTime; %NonMFR+1.96*sqrt(NonMFR/TotalSilentTime);
NonUFR = .5*chi2inv(1-alp/2, 2*nSilentSpks+2)./TotalSilentTime; %NonMFR-1.96*sqrt(NonMFR/TotalSilentTime);
PXFR = [SingLFR(:) SingUFR(:) SingUFR(:) SingLFR(:) SingLFR(:)]; 
PYFR = [NonLFR(:) NonLFR(:) NonUFR(:) NonUFR(:) NonLFR(:)]; 

% confidence interval on CV
% http://www.hindawi.com/journals/jps/2013/324940/
SingCV = cellfun(@(x) std(x)/mean(x), listISIsong); % CV of song ISI distribution
Ns = cellfun(@(x) length(x), listISIsong); % number of song ISIs
SingLCV = SingCV.*sqrt(Ns)./sqrt(chi2inv(1-alp/2, Ns)); 
SingUCV = SingCV.*sqrt(Ns)./sqrt(chi2inv(alp/2, Ns)); 
NonCV = cellfun(@(x) std(x)/mean(x), listISInonsong); % CV of nonsong ISI distribution
Nns = cellfun(@(x) length(x), listISInonsong); % number of nonsong ISIs
NonLCV = NonCV.*sqrt(Nns)./sqrt(chi2inv(1-alp/2, Nns)); 
NonUCV = NonCV.*sqrt(Nns)./sqrt(chi2inv(alp/2, Nns)); 
PXCV = [SingLCV(:) SingUCV(:) SingUCV(:) SingLCV(:) SingLCV(:)]; 
PYCV = [NonLCV(:) NonLCV(:) NonUCV(:) NonUCV(:) NonLCV(:)]; 


figure(8); clf; hold on % mean FR
for rowi = 1:length(rows)
    if min(length(listISInonsong{rowi}),length(listISIsong{rowi}))<SpkMin
%         plot(PX(rowi,:), PY(rowi,:), ':', 'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
    else
        plot(PXFR(rowi,:), PYFR(rowi,:), 'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
    end
    text(SingMFR(rowi), NonMFR(rowi), num2str(rows(rowi)), ...
        'color', .7*Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:), ...
        'fontsize', 5, 'horizontalalignment', 'center', 'verticalalignment', 'middle',...
        'fontweight', 'bold')
end
tmp = [min(NonLFR) max(SingUFR)]; 
plot(tmp,tmp, 'k'); axis square; axis tight
set(gca, 'xscale', 'log', 'yscale', 'log')
tmptl = suptitle({'Single units, 95% confidence interval on mean firing rates, tutoring and nontutoring'})
set(tmptl, 'verticalalignment', 'top', 'fontsize', 12)
xlabel('Tutoring Firing Rate (Hz)'); ylabel('Nontutoring Firing Rate (Hz)')
papersize = [6 6];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 

figure(9); clf; hold on % CV
for rowi = 1:length(rows)
    if min(length(listISInonsong{rowi}),length(listISIsong{rowi}))<SpkMin
%         plot(PX(rowi,:), PY(rowi,:), ':', 'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
    else
        plot(PXCV(rowi,:), PYCV(rowi,:), 'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
    end
    text(SingCV(rowi), NonCV(rowi), num2str(rows(rowi)), ...
        'color', .7*Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:), ...
        'fontsize', 5, 'horizontalalignment', 'center', 'verticalalignment', 'middle',...
        'fontweight', 'bold')
end
tmp = [min(NonLCV) max(SingUCV)]; 
plot(tmp,tmp, 'k'); axis square; axis tight
tmptl = suptitle({'Single units, 95% confidence interval on ISI CV, tutoring and nontutoring'})
set(tmptl, 'verticalalignment', 'top', 'fontsize', 12)
xlabel('Tutoring CV'); ylabel('Nontutoring CV')
papersize = [6 6];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 


% params for psth
p.sylType = 'tutor';
p.makeFig = 0;
p.PSTHaxisMax = []; % [] to leave automatic
p.alignTo = 'onset'; 
p.sortBy = 'syldur'; % syldur or gapdur
p.XLS = XLS; 
p.Columns = Columns; 
p.rasterRange = [-.15 .15];
% p.plotRange = [-.2 .3]; 
p.psthdt = .001; 
smoothwin = 19; %boxcar smoothing window. smoothwin must be odd. 1 is no smoothing.
p.smoothwin = smoothwin; 
psthbins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 

figure(10); clf; hold on % CV
xlims = ([min(SingMFR) max(SingMFR)]); 
ylims = ([min(SingCV) max(SingCV)])
set(gca, 'xscale', 'log')
% xlim(xlims); ylim(ylims)
MarkerSize = .03; 
for rowi = 1:length(rows)
    row = rows(rowi)
    if length(listISIsong{rowi})<SpkMin%||(Age(row)>=60)
%         plot(PX(rowi,:), PY(rowi,:), ':', 'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
    else
        % get psthTheta (time, scaled bt -pi and pi, then add pi/2 so 0 is up) and psthR (rates, scaled bt 0 and 1)
        psthTheta = fliplr(psthbins*pi/p.rasterRange(2)) + pi/2; 
        psthR = smooth(analyzeRow(row, p, 'PSTH'), smoothwin)';
        psthR = MarkerSize*psthR/SingMFR(rowi); 
        baselineR = 0*psthR + MarkerSize*NonMFR(rowi)/SingMFR(rowi); 
        % make it circular, 
        psthX = psthR.*cos(psthTheta); 
        psthY = psthR.*sin(psthTheta); 
        baselineX = baselineR.*cos(psthTheta); 
        baselineY = baselineR.*sin(psthTheta); 
        % plot baseline, PSTH, and line at 0
        patch(exp(baselineX + log(SingMFR(rowi))),baselineY+SingCV(rowi), ...
            (Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:)+1)/2, ...
            'edgecolor', 'none')
        plot(exp(psthX + log(SingMFR(rowi))),psthY+SingCV(rowi), ... 
            'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
        plot(SingMFR(rowi)*[1 1], SingCV(rowi)+[0 3*MarkerSize], ...
            'color', birdColors(birdnum(rows(rowi)),:), ...
            'linewidth', 1)
        RelAge = (Age(rows(rowi))-40)/50; % relative age bt 40 and 90
        plot(SingMFR(rowi)*[1 1], SingCV(rowi)+[0 3*MarkerSize*RelAge], ... 
            'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:), ...
            'linewidth', 1)
        text(SingMFR(rowi), SingCV(rowi)+3*MarkerSize, num2str(rows(rowi)), ...
            'color', 'k', ...%.7*Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:), ...
            'fontsize', 5, 'horizontalalignment', 'center', 'verticalalignment', 'bottom',...
            'fontweight', 'bold')
    end
    drawnow
end
xlim([.5 400]); ylim([.5 2.8])
% axis tight
% axis square
% xlim([min(SingMFR) max(SingMFR)]); ylim([min(SingCV) max(SingCV)])
tmptl = suptitle({['Single units, circular PSTH, aligned to onsets, \pm' num2str(p.rasterRange(2)) ...
    's, filled circle is nontutoring baseline, '...
    'colored line is age bt 40 and 90']})
set(tmptl, 'verticalalignment', 'bottom', 'fontsize', 8)
xlabel('Tutoring Firing Rate (Hz)'); ylabel('Tutoring ISI CV')
papersize = [10 4];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 

% set stuff that's common to multiple figures
for figi = 8:10
    figure(figi)
%     grid on
    set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 6)
    tmpx = xlim; tmpy = get(gca, 'ytick') 
    text(tmpx(1), tmpy(end), ['\color[rgb]{' num2str(Colors(1,:)) '} Unidentified \newline' ...
        '\color[rgb]{' num2str(Colors(2,:)) '} Putative Projector \newline' ...
        '\color[rgb]{' num2str(Colors(3,:)) '} Collision Tested \newline'], ...
        'verticalalignment', 'top');
    shg
end
%% scatter plot of ISI CV singing & nonsinging
% clf; hold on
% Colors = [.6*[1 1 1]; [1 .6 .6]; [1 0 0]];
% % Colors = [[1 1 1]; [1 .8 .8]; [1 0 0]];
% spkslop = 20; 
% alp = .05; 
% 
% 
% 
% % scatter(SingMFR,NonMFR,  TotalSilentTime, 'o','cdata', Colors(1+CTEST(rows)+PUTPROJ(rows),:), 'markerfacecolor', 'flat'); 
% for rowi = 1:length(rows)
% %     patch(PX(rowi,:), PY(rowi,:), 1,...
% %         'edgecolor', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:), ...
% %         'facecolor', 'none')
%     toounconfident = .8; 
%     if diff(PX(rowi,1:2))>toounconfident || diff(PY(rowi,2:3))>toounconfident
% %         plot(PX(rowi,:), PY(rowi,:), ':', 'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
%     else
%         plot(PX(rowi,:), PY(rowi,:), 'color', Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:))
%     end
%     text(SingMFR(rowi), NonMFR(rowi), num2str(rows(rowi)), ...
%         'color', .7*Colors(1+CTEST(rows(rowi))+PUTPROJ(rows(rowi)),:), ...
%         'fontsize', 5, 'horizontalalignment', 'center', 'verticalalignment', 'middle',...
%         'fontweight', 'bold')
% end
% % set(gca, 'xscale', 'log', 'yscale', 'log')
% tmp = [min(NonLFR) max(SingUFR)]; 
% plot(tmp,tmp, 'k'); axis square; axis tight
% tmptl = suptitle({'Single units, 95% confidence interval on ISI CVs singing and nonsinging'})
% tmpx = xlim; tmpy = ylim; 
%  %, 'color', Colors(1,:), 'fontweight', 'bold')
% % text(tmpx(1), .9*tmpy(2), '    Putative Projector', 'color', Colors(2,:), 'fontweight', 'bold')
% % text(tmpx(1), .85*tmpy(2), '    Collision Tested', 'color', Colors(3,:), 'fontweight', 'bold')
% set(tmptl, 'verticalalignment', 'top', 'fontsize', 12)
% xlabel('Singing CV'); ylabel('Nonsinging CV')
% set(gca,'color','w','tickdir','out','ticklength',[0.015 0.015], 'fontsize', 8)
% papersize = [6 6];
% set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
% shg
