close all
%%
clear all

clc

XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits.xlsx');
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
Columns = XLS.textdata.Sheet1(1,:);

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

% plotting hash latency and latency jitter
% figure(5); hold on; 
% plot(hashLat(SINGLEUNIT), hashLatJitt(SINGLEUNIT), 'k.'); 
% plot(hashLat(PUTPROJ), hashLatJitt(PUTPROJ), 'r.')
% plot(hashLat(CTEST), hashLatJitt(CTEST), 'ro')
% set(gca, 'yscale', 'log')
% legend('locked unit', 'put. proj.', 'collision tested', 'location', 'northwest')
% xlabel('latency (ms)'); ylabel('latency jitter (us)')
% set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',8)
% set(gcf, 'color', [1 1 1], 'papersize', [8 6], 'paperposition', [0 0 8 6]);

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

SUBSONG = zeros(size(XLS.data.Sheet1,1),1); SUBSONG(strmatch('subsong', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
PROTOSYLLABLE = zeros(size(XLS.data.Sheet1,1),1); PROTOSYLLABLE(strmatch('protosyllable', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
DIFF = zeros(size(XLS.data.Sheet1,1),1); DIFF(strmatch('diff', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
%%

rows = find(SINGING&PUTPROJ);
SortBy = 'elecpos'; % 'age' or 'elecpos' or 'latency'
p.sylType = 'song'; % 'tutor' 'song' 'artificialsubsong' or 'specified'
p.sylName = {'A'}; % specify sylable to align to, Only used when p.sylType = 'specified'
p.PSTHaxisMax = []; % [] to leave automatic
p.alignTo = 'onset'; 
p.XLS = XLS; 
p.rasterRange = [-.5 .5];
p.plotRange = [-.2 .3]; 
p.psthdt = .001; %.001; 
smoothwin = 19; %boxcar smoothing window. smoothwin must be odd. 1 is no smoothing.
p.smoothwin = smoothwin; 
bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
p.figNum = 1;
p.makeFig = 0;
p.papersize = 2*[3.5 2.5]; 
p.fontsize = 2*6; 

% to plot just one row
p.makeFig = 1; p.MaxToPlot = 100; analyzeRow(236, p, 'PSTH'); p.makeFig = 0;
%% calculating reliability and latency for each row. Takes 20 seconds. 

p.Nsigma = 5; % must exceed mean by Nsigma*sigma to be considered 'reliable'
p.latMethod = 'peakTime'; % 'peakTime' or 'thresCrossing'. Thres is Nsigma above mean.

reliable = zeros(1,length(rows)); 
latency = zeros(1,length(rows)); 
tic
p.relThres = 4; 
for rowi = 1:length(rows)
    Result = analyzeRow(rows(rowi),p,'relLat'); 
    reliable(rowi) = Result.reliable; 
    latency(rowi) = Result.latency; 
end
toc

% discard unreliable rows
relInd = find(reliable); %find(relDKL<p.relThres); 
display([num2str(numel(relInd)) ' reliable of ' num2str(length(rows)) ' total units'])
rows = rows(relInd); 
latency = latency(relInd); 

%%

% plotting KS statistiv vs DKL
% figure; plot(relKS, relDKL, '.'); xlabel('KS statistic'); ylabel('KL divergence'); 
% hold on; plot([min(relKS) max(relKS)], [4 4], 'r'); plot([.1 .1], [min(relDKL) max(relDKL)],'r')

% plotting examples of unreliable neurons under each test
% indBadKS = find(relKS>.1); 
% for i = 1:length(indBadKS)
%     p.figNum = i; 
%     row = rows(indBadKS(i)); p.makeFig = 1; analyzeRow(row,p,'PSTH')
%     title(['p_{KS} = ' num2str(relKS(i))])
% end
% 
% indBadDKL = find(relDKL>4); 
% for i = 1:length(indBadDKL)
%     p.figNum = i; 
%     row = rows(indBadDKL(i)); p.makeFig = 1; analyzeRow(row,p,'PSTH')
%     title(['row ' num2str(rows(i)) ' DKL = ' num2str(relDKL(i))])
% end

%%

% sorting
switch SortBy
    case 'age'
        [~,agePerm] = sort(Age(rows), 'ascend'); 
        rows = rows(agePerm); 
        latency = latency(agePerm); 
        % calculate r^2 for linear fits of latency based on electrode position
        pfit = polyfit(Age(rows)',latency,1); 
        latFitAge = polyval(pfit,Age(rows)'); 
        latResidualsAge = latency-latFitAge; 
        latRsqAge = 1 - sum(latResidualsAge.^2)/((length(latency)-1)*var(latency));
        jitt = 2*randn(1,length(rows)); 
        figure(9); clf; hold on; 
        plot(latency, Age(rows)+jitt'/5, 'k.'); 
        plot(latFitAge, Age(rows), 'r'); 
        title(['Latency vs Age: R^2 = ' num2str(latRsqAge)])
        box off; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',10)
        xlabel('Latency (s)'); ylabel('Age (dph)'); %b = colorbar; ylabel(b, 'Age (dph)')
        set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
    case 'elecpos'
        [rows,indkeep,~] = intersect(rows, find(goodHist==1)); % Only keep rows with good hist. Change to goodHist>0 for lower thres on hist quality
        latency = latency(indkeep);
        [~,posPerm] = sort(elecPosition(rows), 'ascend'); 
        rows = rows(posPerm); 
        latency = latency(posPerm); 
        % calculate r^2 for linear fits of latency based on age 
        pfit = polyfit(elecPosition(rows),latency,1); 
        latFitPosition = polyval(pfit,elecPosition(rows)); 
        latResidualsPosition = latency-latFitPosition; 
        latRsqPosition = 1 - sum(latResidualsPosition.^2)/((length(latency)-1)*var(latency));
        jitt = 2*randn(1,length(rows)); 
        % plotting position vs latency. 
        figure(9); clf; hold on; 
        plot(latency, elecPosition(rows)+jitt, 'k.'); 
        plot(latFitPosition, elecPosition(rows), 'r'); 
        title(['Latency vs Position: R^2 = ' num2str(latRsqPosition)])
        box off; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',10)
        xlabel('Latency (s)'); ylabel('Position along NIf axis (um)');
        set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
        
        % splitting NIf into 2 sections, making bar/scatter plots of
        % latencies
        figure(10); clf; hold on
        dividingLine = 150; %um from lambda point
        indAnt = elecPosition<=dividingLine; 
        indPos = elecPosition>dividingLine; 
        % do box&whisker thingy
        catLabels = {'Posterior' 'Anterior'}; 
        pRankSum = ranksum(latency(indAnt(rows)),latency(indPos(rows)))
        boxplot(latency, catLabels(indAnt(rows)+1), 'grouporder', catLabels)
        jitt = .02*randn(1,length(rows));
        plot(indAnt(rows)+1+jitt, latency, 'k.', 'markersize', .5); 
        ylabel('Latency (ms)'); xlabel('Part of NIf')
        box off; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',10)
        set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
        ylim([-.1 .1])
        title(['Rank sum test p = ' num2str(pRankSum)])
    case 'latency'
        [~,latPerm] = sort(latency, 'ascend'); 
        rows = rows(latPerm); 
        latency = latency(latPerm); 
end
%%
% calculating psth for each row
comboPSTH = zeros(length(rows),length(bins)); 
for rowi = 1:length(rows)
    row = rows(rowi); 
    comboPSTH(rowi,:) = smooth(analyzeRow(row,p, 'PSTH'),smoothwin); 
end
%
% normalize rows

%alternative method, where normalize by baseline sigma and mu
% indBaseline = find(bins<-.1|bins>.1); 
% for rowi = 1:size(comboPSTH,1)
%     zscorePSTHs(rowi,:) = (comboPSTH(rowi,:) ...
%         - mean(comboPSTH(rowi,indBaseline))) ...
%         ./std(comboPSTH(rowi,indBaseline)); 
% end
zscorePSTHs = zscore(comboPSTH')'; 

% just plot the middle window, specified by p.plotRange
indplot = bins>p.plotRange(1) & bins<p.plotRange(end); 
bins = bins(indplot);
zscorePSTHs = zscorePSTHs(:,indplot); 

% plotting
figure(4); clf;

% population average zscore rate
g = subplot(4,1,1);
plot(bins,sum(zscorePSTHs)/size(zscorePSTHs,1), 'k', 'linewidth', 2); 
ylabel('Rate (\sigma above \mu)', 'interpreter', 'tex')
axis tight; box off
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',8)
set(gca, 'xtick', [])
hold on
plot([0 0], [-1 1], 'r')

% heatmap of population responses
h = subplot(4,1,2:4); hold on
imagesc(zscorePSTHs, 'xdata', bins)

% set colormap and clims (mean = black)
clims = max(abs(zscorePSTHs(:)))*[-1 1]; set(gca, 'clim', clims); 
cvec = [zeros(128,1);(1:128)'/128];
CMAP = [cvec cvec flipud(cvec)];
colormap(CMAP)

xlabel(['Time relative to syllable ' p.alignTo, ' (s)'])

switch SortBy
    case 'age'
        AgeBrackets = 35:5:85; 
        AgeBrackets = AgeBrackets(AgeBrackets>=Age(rows(1)) & AgeBrackets<=Age(rows(end)));
        bracRow = [];
        for abi = 1:length(AgeBrackets)
            tmp = Age(rows); 
            tmp1 = find(tmp>=AgeBrackets(abi)); 
            bracRow(abi) = tmp1(1)-.5; 
            plot([bins(1) bins(end)], [bracRow(abi) bracRow(abi)], 'Color', [1 1 1]);
        end
        bInd = [1 diff(bracRow)>0]==1;
        bracRow = bracRow(bInd); 
        AgeBrackets = AgeBrackets(bInd);
        set(gca, 'ytick', bracRow, 'yticklabel', AgeBrackets, 'ydir', 'normal')
        plot([0 0], [0 length(rows)]+.5,'r')
        ylabel('Age (dph)');
    case 'elecpos'
        posBrackets = -200:100:1000;
        posBrackets = posBrackets(posBrackets>=elecPosition(rows(1)) & posBrackets<= elecPosition(rows(end))); 
        bracRow = []; 
        for abi = 1:length(posBrackets)
            tmp = elecPosition(rows); 
            tmp1 = find(tmp>=posBrackets(abi)); 
            bracRow(abi) = tmp1(1)-.5; 
            plot([bins(1) bins(end)], [bracRow(abi) bracRow(abi)], 'Color', [1 1 1]);
        end
        bInd = [1 diff(bracRow)>0]==1;
        bracRow = bracRow(bInd); 
        posBrackets = posBrackets(bInd);
        set(gca, 'ytick', bracRow, 'yticklabel', posBrackets, 'ydir', 'normal')
        plot([0 0], [0 length(rows)]+.5,'r')
        ylabel('Position along NIf axis (um)');
    case 'latency'
        latBrackets = -.1:.025:.1;
        latBrackets = latBrackets(latBrackets>=latency(1) & latBrackets<= latency(end)); 
        bracRow = []; 
        for abi = 1:length(latBrackets)
            tmp = latency; 
            tmp1 = find(tmp>=latBrackets(abi)); 
            bracRow(abi) = tmp1(1)-.5; 
            plot([bins(1) bins(end)], [bracRow(abi) bracRow(abi)], 'Color', [1 1 1]);
        end
        bInd = [1 diff(bracRow)>0]==1;
        if length(bracRow)>0
            bracRow = bracRow(bInd); 
            latBrackets = latBrackets(bInd);
        end
        set(gca, 'ytick', bracRow, 'yticklabel', latBrackets, 'ydir', 'normal')
        plot([0 0], [0 length(rows)]+.5,'r')
        ylabel('Latency (s)');
end
birdColors = lines(length(unique(birdnum))); 
for rowi = 1:length(rows)
    plot((bins(end) - 3*p.psthdt), rowi, 's','MarkerFaceColor', birdColors(birdnum(rows(rowi)),:), 'MarkerEdgeColor', 'none');
    if latency(rowi)~=100
        plot(latency(rowi),rowi, 'w.', 'markersize', .25)
    end
end
%colorbar('ytick', [-2 0 2], 'yticklabel', {'-2 std', 'mean', '+2 std'})
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',6)
axis tight; box off; 
set(gcf, 'papersize', [5 4], 'paperposition', [0 0 5 4]);


linkaxes([h g], 'x')