close all
%%
clear all

clc

XLS = importdata('C:/Users/emackev/Dropbox/MackeviciusLabPresentations/NIfUnits.xlsx');
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
Columns = XLS.textdata.Sheet1(1,:);

SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
TUTORING = XLS.data.Sheet1(:,strmatch('tutoring?', Columns))==1;
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
PROTOSYLLABLE = zeros(size(XLS.data.Sheet1,1),1); SUBSONG(strmatch('protosyllable', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
DIFF = zeros(size(XLS.data.Sheet1,1),1); SUBSONG(strmatch('diff', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
%%
rows = find(SINGING&HASH);
SortBy = 'age'; % 'age' or 'elecpos'
switch SortBy
    case 'age'
        [~,agePerm] = sort(Age(rows), 'ascend'); 
        rows = rows(agePerm); 
    case 'elecpos'
        rows = intersect(rows, find(goodHist==1)); % Only keep rows with good hist. Change to goodHist>0 for lower thres on hist quality
        [~,posPerm] = sort(elecPosition(rows), 'ascend'); 
        rows = rows(posPerm); 
end

p.sylType = 'song'; % 'tutor' 'song' or 'artificialsubsong'
p.XLS = XLS; 
p.rasterRange = [-.2 .3];
p.psthdt = .002; 
smoothwin = 3; %boxcar smoothing window. smoothwin must be odd. 1 is no smoothing.
bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
p.figNum = 1;
p.makeFig = 0;
comboPSTH = zeros(length(rows),length(bins)); 

% to plot just one row: 
%row = 192; p.makeFig = 1; row2PSTH(row,p)

for rowi = 1:length(rows)
    row = rows(rowi); 
    comboPSTH(rowi,:) = smooth(row2PSTH(row,p),smoothwin); 
end
% normalize rows
zscorePSTHs = zscore(comboPSTH')'; 

% plotting
figure(4); clf;

% population average zscore rate
g = subplot(4,1,1)
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

xlabel('Time relative to syl onset (s)')

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
end
birdColors = lines(length(unique(birdnum))); 
for rowi = 1:length(rows)
    plot((p.rasterRange(end) - 3*p.psthdt), rowi, 's','MarkerFaceColor', birdColors(birdnum(rows(rowi)),:), 'MarkerEdgeColor', 'none');
end
%colorbar('ytick', [-2 0 2], 'yticklabel', {'-2 std', 'mean', '+2 std'})
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',8)
axis tight; box off; 
set(gcf, 'papersize', [8 6], 'paperposition', [0 0 8 6]);


linkaxes([h g], 'x')
