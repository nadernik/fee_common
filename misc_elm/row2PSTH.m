function PSTH = row2PSTH(row, p)

% collect params from p
rasterRange = p.rasterRange; 
psthdt = p.psthdt;
XLS = p.XLS; % XLS = importdata('C:/Users/emackev/Dropbox/MackeviciusLabPresentations/NIfUnits.xlsx'); XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.

% getting the relevant info from NIfUnits spreadsheet
Columns = XLS.textdata.Sheet1(1,:);
bird = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns)));
day = XLS.textdata.Sheet1{row,strmatch('day', Columns)};
depth = XLS.textdata.Sheet1{row,strmatch('folder', Columns)};
feeboxFolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
if strmatch('feebox4',feeboxFolder)
    feeboxFolder = 'Z:\emackev\AcqGui\';
end
if strmatch('feebox5',feeboxFolder)
    feeboxFolder = 'Q:\AcqGui\';
end
filename = ['analysis' depth(2:end)];
eventNum = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns)); 
TutorSylNames = eval(XLS.textdata.Sheet1{row,strmatch('T syl names', Columns)});
SongSylNames = eval(XLS.textdata.Sheet1{row,strmatch('song syl names', Columns)});
ASubSylNames = eval(XLS.textdata.Sheet1{row,strmatch('AS syl names', Columns)}); 

% load analysis file
load(fullfile(feeboxFolder, bird, day, depth, filename));

plotX = zeros(3,0);
plotY = zeros(3,0);
plotDur = zeros(3,0);
plotID = zeros(3,0);

fs = dbase.Fs;

% calculating onset-aligned spike times in a way that's easy to plot
nFiles = length(dbase.SegmentTimes); 
sylSoFar = 0; 
for filei = 1:nFiles
    Syls = 1:size(dbase.SegmentTimes{1,filei},1); 
    isSelected = dbase.SegmentIsSelected{1,filei};
    if length(isSelected) == 0 
        isSelected = zeros(1,0); % need to make sure size of empty vectors is consistent
    end 
    % also find indices of syllables with desired label
    isSongSyl = zeros(1,0); % need to make sure size of empty vectors is consistent
    isTutorSyl = zeros(1,0);
    isASubSyl = zeros(1,0);
    for syli = 1:length(Syls)
        label = dbase.SegmentTitles{1,filei}{syli}; 
        isSongSyl(syli) = sum(cellfun(@(x) (issame(x,label)|((length(x)==0)&(length(label)==0))), SongSylNames, 'UniformOutput', 1))>0;
        isTutorSyl(syli) = sum(cellfun(@(x) (issame(x,label)|((length(x)==0)&(length(label)==0))), TutorSylNames, 'UniformOutput', 1))>0;
        isASubSyl(syli) = sum(cellfun(@(x) (issame(x,label)|((length(x)==0)&(length(label)==0))), ASubSylNames, 'UniformOutput', 1))>0;
    end
    switch p.sylType
        case 'tutor'
            Syls = Syls((isSelected==1)&(isTutorSyl==1)); 
        case 'song'
            Syls = Syls((isSelected==1)&(isSongSyl==1)); 
        case 'artificialsubsong'
            Syls = Syls((isSelected==1)&(isASubSyl==1)); 
    end
    nSyls = length(Syls); 
    for syli = 1:nSyls
        syl = Syls(syli); 
        % find syllable onset time
        OnsetTime = dbase.SegmentTimes{1,filei}(syl,1)/fs; 
        % find spike events in time window
        allSpt = dbase.EventTimes{1,eventNum}{1,filei}/fs; % for testing: (1:syli)*.01+OnsetTime; %
        spInd = ((allSpt - OnsetTime)>(rasterRange(1)-psthdt/2))&((allSpt - OnsetTime)<(rasterRange(2)+psthdt/2));
        Spt = allSpt(spInd)-OnsetTime; 
        nSpt = length(Spt);
        if nSpt >0
            Spt2 = [repmat(Spt(:),1,2),NaN*ones(nSpt,1)]'; 
            plotX = [plotX Spt2]; 
            tmpy = bsxfun(@times,(ones(nSpt,3)),[sylSoFar+syli sylSoFar+syli+1 NaN])';
            plotY = [plotY tmpy]; 
        else
            nSpt = 1;
            Spt2 = NaN*ones(3,1); 
            plotX = [plotX Spt2]; 
            tmpy = bsxfun(@times,(ones(nSpt,3)),[sylSoFar+syli sylSoFar+syli+1 NaN])';
            plotY = [plotY tmpy]; 
        end
        % find syl duration
        Dur = diff(dbase.SegmentTimes{1,filei}(syl,:))/fs;
        tmpDur = Dur*(ones(3,nSpt)); 
        plotDur = [plotDur tmpDur];
        tmpID = (sylSoFar+syli)*(ones(3,nSpt)); 
        plotID = [plotID tmpID];
        allDur(sylSoFar+syli) = Dur; 
    end
    sylSoFar = sylSoFar+nSyls;
end

% sorting by syllable duration
[~,plotPerm] = sort(plotDur(1,:)); 
plotXsorted = plotX(:,plotPerm); 
sylPerm = unique(plotID(1,plotPerm),'stable'); 
[~,invsort] = sort(sylPerm); 
plotYsorted(1,:) = invsort(plotY(1,plotPerm)); 
plotYsorted(2,:) = invsort(plotY(1,plotPerm))+1;
plotYsorted(3,:) = plotY(3,:); 

% psth
bins = rasterRange(1):psthdt:rasterRange(2);  
[nHist,xHist] = hist(plotX(1,:),bins); % histogram with bin centers specified by bins 
nHist = nHist/length(allDur); % divide by total number of syllables
PSTH = nHist/psthdt; % now it's in units of Hz; 

% plotting...
if p.makeFig
    % making syl duration lines and patches
    durlineX = repmat(allDur(sylPerm),2,1); 
    durlineX = durlineX(:);
    durlineY = repmat(1:length(allDur),2,1); 
    durlineY = durlineY(:); durlineY = [durlineY(2:end); length(allDur)+1];
    durPatchX = [0; durlineX; 0; 0]; 
    durPatchY = [1; durlineY; length(allDur)+1; 1];

    figure(p.figNum); clf
    set(gcf, 'papersize', [6 4], 'paperposition', [0 0 6 4])
    h = subplot(4,1,1); hold on
    b = bar(bins,PSTH, 'histc'); axis tight; box off
    plot([0 0], [0 max(PSTH)], 'b')
    set(b, 'FaceColor', [0 0 0])
    ylabel('Rate (Hz)')
    set(gca, 'xtick', [])
    set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',8)

    g = subplot(4,1,2:4);
    hold on; 
    ylabel('Syllable'); xlabel('Time (ms)')
    patch(durPatchX, durPatchY, [1 .9 1], 'EdgeAlpha', 0)
    plot(plotXsorted,plotYsorted,'k')
    plot(durlineX,durlineY, 'r') % syl offset
    plot([0 0], [1 length(allDur)], 'b') % syl onset
    ylim([1 length(allDur)])
    box off;
    set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',8)

    linkaxes([h g], 'x')
end