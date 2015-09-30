function [PSTH plotX plotY allDur]  = PSTH_elm(dbase, p)
% makes a PSTH, with option to plot, from a dbase.
% Outputs: 
% PSTH                  alignment, bin size, etc set using p (see below)
% plotX                 for plotting rasters, see below
% plotY                 for plotting rasters, see below
% allDur                list of durations of all the syllables
% 
% plot(plotX, plotY, 'k') to get raster plot
%   Third row of plotX and plotY are NaNs, 
%   so there are no lines between spikes. 
%   plotX(1,:) will be all the spike times. plotY(1,:) will be the
%   syllable number that each spike happened on. 
% 
% Options to set:
% p.eventNum            spike event number in dbase
% p.sylType             'tutor' 'song' 'artificialsubsong' or 'specified'
% p.sylName             specify syllable(s) to align to, Only used when p.sylType = 'specified'
% p.sortBy              'syldur' or 'gapdur'
% p.alignTo             'onset' or 'offset'
% p.makeFig             0 or 1
% p.rasterRange         xlim in s
% p.psthdt              in s
% p.TutorSylNames       cell array of tutor syllable names
% p.SongSylNames        cell array of song syllable names
% p.ASubSylNames        cell array of artificial subsong syllable names
% 
% Additional options to set if you're plotting (p.makeFig = 1):
% p.MaxToPlot           maximum number of syllables to plot in raster
% p.plotRange           xlim in s
% p.figNum              handle of figure to plot in
% p.panel (optional)    # (1-4) of subplot if you want to plot in
% p.smoothwin           smooth by this many psth bins
% p.fontsize            for plots
% p.PSTHaxisMax         [] to leave automatic
% p.papersize           [w h]Third row of plotX 
% p.rowstr              title of plot


% get info from dbase: 
fs = dbase.Fs;

% extract spike times relative to syllable onsets. 
% X (time) and Y (row) info to plot each spike. 
plotX = zeros(3,0);
plotY = zeros(3,0);
plotDur = zeros(3,0);
plotID = zeros(3,0);
% calculating onset-aligned spike times in a way that's easy to plot
sylSoFar = 0; 
nFiles = length(dbase.SegmentTimes);
for filei = 1:nFiles
    Syls = 1:size(dbase.SegmentTimes{1,filei},1); 
    isSelected = dbase.SegmentIsSelected{1,filei};
    if length(isSelected) == 0 
        isSelected = zeros(1,0); % need to make sure size of empty vectors is consistent
    end 
    % also find indices of syllables with desired label
    switch p.sylType
        case 'tutor'
            isTutorSyl = zeros(1,length(Syls));
            for syli = 1:length(Syls)
                label = dbase.SegmentTitles{1,filei}{syli}; 
                isTutorSyl(syli) = sum(cellfun(@(x) (issame(x,label)|((length(x)==0)&(length(label)==0))), p.TutorSylNames, 'UniformOutput', 1))>0;
            end
            Syls = Syls((isSelected==1)&(isTutorSyl==1)); 
        case 'song'
            isSongSyl = zeros(1,length(Syls));
            for syli = 1:length(Syls)
                label = dbase.SegmentTitles{1,filei}{syli}; 
                isSongSyl(syli) = sum(cellfun(@(x) (issame(x,label)|((length(x)==0)&(length(label)==0))), p.SongSylNames, 'UniformOutput', 1))>0;
            end
            Syls = Syls((isSelected==1)&(isSongSyl==1));
        case 'artificialsubsong'
            isASubSyl = zeros(1,length(Syls));
            for syli = 1:length(Syls)
                label = dbase.SegmentTitles{1,filei}{syli}; 
                isASubSyl(syli) = sum(cellfun(@(x) (issame(x,label)|((length(x)==0)&(length(label)==0))), p.ASubSylNames, 'UniformOutput', 1))>0;
            end
            Syls = Syls((isSelected==1)&(isASubSyl==1));
        case 'specified'
            isSpecified = zeros(1,length(Syls));
            SylName = p.sylName; 
            for syli = 1:length(Syls)
                label = dbase.SegmentTitles{1,filei}{syli}; 
                isSpecified(syli) = sum(cellfun(@(x) (issame(x,label)|((length(x)==0)&(length(label)==0))), SylName, 'UniformOutput', 1))>0;
            end
            Syls = Syls((isSelected==1)&(isSpecified==1));
    end
    nSyls = length(Syls); 
    
    % prep for assigning durations
    
    % find duration
    switch p.sortBy
        case 'syldur'
            durprep = diff(dbase.SegmentTimes{1,filei}(Syls,:)')'/fs;
            durColor = [1 .9 1];
        case 'gapdur'
            durColor = [.9 .9 1]; 
            switch p.alignTo
                case 'onset' % sort by gap preceding this onset
                    if numel(Syls)>0
                        GapList = [[1; dbase.SegmentTimes{1,filei}(Syls,2)] ...
                            [dbase.SegmentTimes{1,filei}(Syls,1); dbase.FileLength(filei)]];
                        durprep = diff(GapList(1:(end-1),:)')'/fs;
                    else
                        durprep = []; 
                    end
                case 'offset' % sort by gap following this offset
                    if numel(Syls)>0
                        GapList = [[1; dbase.SegmentTimes{1,filei}(Syls,2)] ...
                            [dbase.SegmentTimes{1,filei}(Syls,1); dbase.FileLength(filei)]];
                        durprep = diff(GapList(2:end,:)')'/fs;
                    else
                        durprep = []; 
                    end
            end
    end
    
    
    for syli = 1:nSyls
        syl = Syls(syli); 
        % find syllable onset/offset time
        switch p.alignTo
            case 'onset'
                OnsetTime = dbase.SegmentTimes{1,filei}(syl,1)/fs; 
            case 'offset'
                OnsetTime = dbase.SegmentTimes{1,filei}(syl,2)/fs; 
        end
        % find spike events in time window
        allSpt = dbase.EventTimes{1,p.eventNum}{1,filei}/fs; % for testing: (1:syli)*.01+OnsetTime; %
        spInd = ((allSpt - OnsetTime)>(p.rasterRange(1)-p.psthdt/2))&((allSpt - OnsetTime)<(p.rasterRange(2)+p.psthdt/2));
        Spt = allSpt(spInd)-OnsetTime; 
        nSpt = length(Spt);
        if nSpt >0
            Spt2 = [repmat(Spt(:),1,2),NaN*ones(nSpt,1)]'; 
            plotX = [plotX Spt2]; 
            tmpy = bsxfun(@times,(ones(nSpt,3)),[sylSoFar+syli sylSoFar+syli+1 NaN])';
            plotY = [plotY tmpy]; 
        else % add a row of NaNs for syllables with no spikes at all
            nSpt = 1;
            Spt2 = NaN*ones(3,1); 
            plotX = [plotX Spt2]; 
            tmpy = bsxfun(@times,(ones(nSpt,3)),[sylSoFar+syli sylSoFar+syli+1 NaN])';
            plotY = [plotY tmpy]; 
        end
        Dur = durprep(syli); 
        tmpDur = Dur*(ones(3,nSpt)); 
        plotDur = [plotDur tmpDur];
        tmpID = (sylSoFar+syli)*(ones(3,nSpt)); 
        plotID = [plotID tmpID];
        allDur(sylSoFar+syli) = Dur; 
    end
    sylSoFar = sylSoFar+nSyls;
end

bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
[nHist,xHist] = hist(plotX(1,:),bins); % histogram with bin centers specified by bins 
nHist = nHist/length(allDur); % divide by total number of syllables
PSTH = nHist/p.psthdt; % now it's in units of Hz; 

% making a matrix of the raster (may be slower, but may want this format) 
% Recall plotX(1,:) contains all the spike times. plotY(1,:) indicates the
% syllable number that each spike happened on.
% 
% 
% rasterMatrix = zeros(sylSoFar, length(bins)); 
% for spikei = 1:size(plotX,2)
%     if ~isnan(plotX(1,spikei)) % nans are placeholders for syllables with no spikes.
%         rasterMatrix(plotY(1,spikei), ceil((plotX(1,spikei)-bins(1)+psthdt/2)/psthdt)) = ...
%             rasterMatrix(plotY(1,spikei), ceil((plotX(1,spikei)-bins(1)+psthdt/2)/psthdt)) + 1; 
%     end
% end

% Alternate way to calculate, using rasterMatrix (same exact
% answer)
%         nHist = sum(rasterMatrix,1);
%         nHist = nHist/size(rasterMatrix,1); 
%         PSTH = nHist/psthdt; 

% plotting...
if p.makeFig
    % restrict to a max number of syls to plot
    sylPlotInd = randperm(sylSoFar); 
    [~,invsort] = sort(sylPlotInd); 
    sylPlotInd = sylPlotInd(1:min(p.MaxToPlot,sylSoFar)); % these are the syllables I'm keeping
    spikePlotInd = ismember(plotY(1,:),sylPlotInd);

    ResplotY(1,:) = invsort(plotY(1, spikePlotInd)); 
    ResplotY(2,:) = invsort(plotY(1, spikePlotInd))+1;
    ResplotY(3,:) = plotY(3, spikePlotInd);
    plotY1 = ResplotY; 

    plotX1 = plotX(:, spikePlotInd); 
    plotDur = plotDur(:, spikePlotInd); 
    plotID = repmat(plotY1(1,:),3,1); 
    allDur1 = allDur(sylPlotInd); 

    % sorting by syllable duration
    [~,plotPerm] = sort(plotDur(1,:)); 
    plotXsorted = plotX1(:,plotPerm); 
    sylPerm = unique(plotID(1,plotPerm),'stable'); 
    [~,invsort] = sort(sylPerm); 
    plotYsorted(1,:) = invsort(plotY1(1,plotPerm)); 
    plotYsorted(2,:) = invsort(plotY1(1,plotPerm))+1;
    plotYsorted(3,:) = plotY1(3,:); 
    % making syl duration lines and patches
    switch (issame(p.alignTo, 'onset')&&issame(p.sortBy, 'syldur'))||...
        (issame(p.alignTo, 'offset')&&issame(p.sortBy, 'gapdur'))
        case 1
            durlineX = repmat(allDur1(sylPerm),2,1); 
        case 0
            durlineX = -repmat(allDur1(sylPerm),2,1); 
    end
    durlineX = durlineX(:);
    durlineX(durlineX<p.plotRange(1)) = p.plotRange(1); 
    durlineX(durlineX>p.plotRange(end)) = p.plotRange(end); 
    durlineY = repmat(1:length(allDur1),2,1); 
    durlineY = durlineY(:); durlineY = [durlineY(2:end); length(allDur1)+1];
    durPatchX = [0; durlineX; 0; 0]; 
    durPatchY = [1; durlineY; length(allDur1)+1; 1];

    figure(p.figNum); 
    if ~isfield(p, 'panel')
        h = subplot(4,1,1); cla
    else 
        [A1, A2] = Subplot_convert(p.panel);
        h = subplot('position', A1); cla
    end
    hold on
    indplot = bins>p.plotRange(1) & bins<p.plotRange(end); 
    b = bar(bins(indplot),smooth(PSTH(indplot), p.smoothwin), 'histc'); 
    axis tight; box off
    plot([0 0], [0 max(PSTH)], 'b')
    set(b, 'FaceColor', [0 0 0])
    ylabel('Rate (Hz)', 'fontsize', p.fontsize)
    if numel(p.PSTHaxisMax)>0
        ylim([0 p.PSTHaxisMax]);
    end
    set(gca, 'xtick', [])
    set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize', p.fontsize)
    if issame(p.sylType, 'specified')
        try
            sname = char(p.sylName); 
        catch
            sname = '[]';
        end
        titlestr = [p.rowstr '(' sname(:)' ')'];
    else
        titlestr = [p.rowstr '(' p.sylType ')'];
    end
    if ~isfield(p, 'panel')
        title(titlestr, 'fontsize', p.fontsize, 'interpreter', 'none')
        g = subplot(4,1,2:4); cla
    else 
        [A1, A2] = Subplot_convert(p.panel);
        g = subplot('position', A2); cla
        if p.panel == 4
            tmp = suptitle(strrep(titlestr,'_','\_'));
            set(tmp, 'FontSize', p.fontsize)
        end
    end
    hold on; 
    ylabel('Syllable #', 'fontsize', p.fontsize); xlabel('Time (ms)', 'fontsize', p.fontsize)
    patch(durPatchX, durPatchY, durColor, 'EdgeColor', 'none')
    plot(plotXsorted,plotYsorted,'k', 'linewidth', 1)
    switch p.alignTo
        case 'onset'
            plot(durlineX,durlineY, 'b') % syl offset
            plot([0 0], [1 length(allDur1)+1], 'r') % syl onset
        case 'offset'
            plot(durlineX,durlineY, 'r') % syl onset
            plot([0 0], [1 length(allDur1)+1], 'b') % syl offset
    end
    ylim([1 length(allDur1)+2])
    box off;
    set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize', p.fontsize)
    xlim(p.plotRange)
    linkaxes([h g], 'x')
    set(gcf, 'papersize', p.papersize, 'paperposition', [0 0 p.papersize(1) p.papersize(2)])
end