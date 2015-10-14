function RastersFromDbase()
close all; clear all; clc

%RunAnalyses('PUTPROJ&SINGING&DIFF', 'latency', 'song')

% RunAnalyses('HASH&SINGLEUNIT&SINGING', 'latency', 'song')
% RunAnalyses('HASH&SINGLEUNIT&TUTORING', 'latency', 'tutor')
% RunAnalyses('HASH&SINGLEUNIT&SINGING', 'age', 'song')
% RunAnalyses('HASH&SINGLEUNIT&SINGING', 'elecpos', 'song')
% RunAnalyses('HASH&SINGLEUNIT&TUTORING', 'elecpos', 'tutor')
RunAnalyses('PUTPROJ&TUTORING', 'elecpos', 'tutor')

% RunAnalyses('PUTPROJ&SINGLEUNIT&SINGING', 'elecpos', 'song')
% RunAnalyses('PUTPROJ&SINGLEUNIT&SINGING', 'age', 'song')
% RunAnalyses('PUTPROJ&SINGLEUNIT&SINGING', 'latency', 'song')
% 
% RunAnalyses('PUTPROJ&SINGING&DIFF', 'elecpos', 'song')
% RunAnalyses('PUTPROJ&SINGING&DIFF', 'age', 'song')
% RunAnalyses('PUTPROJ&SINGING&DIFF', 'latency', 'song')
% 
% RunAnalyses('PUTPROJ&SINGLEUNIT&TUTORING', 'elecpos', 'tutor')
% RunAnalyses('PUTPROJ&SINGLEUNIT&TUTORING', 'age', 'tutor')
% RunAnalyses('PUTPROJ&SINGLEUNIT&TUTORING', 'latency', 'tutor')
% 
% RunAnalyses('PUTPROJ&TUTORING', 'elecpos', 'tutor')
% RunAnalyses('PUTPROJ&TUTORING', 'age', 'tutor')
% RunAnalyses('PUTPROJ&TUTORING', 'latency', 'tutor')

% RunAnalyses('HASH&TUTORING', 'elecpos', 'tutor')
% RunAnalyses('HASH&TUTORING', 'age', 'tutor')
% RunAnalyses('HASH&TUTORING', 'latency', 'tutor')

% RunAnalyses('HASH&SINGING', 'elecpos', 'song')
% RunAnalyses('HASH&SINGING', 'age', 'song')
% RunAnalyses('HASH&SINGING', 'latency', 'song')

function RunAnalyses(ThisDataset, SortBy, sylType); 
% ThisDataset should be a string, eg: 'PUTPROJ&SINGLEUNIT&SINGING'; 
% SortBy options: 'age' or 'elecpos' or 'latency'
% p.sylType options: 'tutor' 'song' 'artificialsubsong' or 'specified'
%%


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
birdColors = lines(length(unique(birdnum))); 

SUBSONG = zeros(size(XLS.data.Sheet1,1),1); SUBSONG(strmatch('subsong', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
PROTOSYLLABLE = zeros(size(XLS.data.Sheet1,1),1); PROTOSYLLABLE(strmatch('protosyllable', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
DIFF = zeros(size(XLS.data.Sheet1,1),1); DIFF(strmatch('diff', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;

%% Setting parameters
figure(1)
SaveFigPath = 'C:\Users\emackev\Documents\MATLAB\code\RasterPlots\'; 
mkdir(SaveFigPath, ThisDataset); 
SaveFigPath = fullfile(SaveFigPath, ThisDataset); 
rows = find(eval(ThisDataset));
% SortBy = 'latency'; % 'age' or 'elecpos' or 'latency'
p.sylType = sylType; % 'tutor' 'song' 'artificialsubsong' or 'specified'
% p.sylName = {'C'}; % specify syllable to align to, Only used when p.sylType = 'specified'
p.makeFig = 0;
p.PSTHaxisMax = []; % [] to leave automatic
p.alignTo = 'onset'; 
p.sortBy = 'syldur'; % syldur or gapdur
p.XLS = XLS; 
p.Columns = Columns; 
p.rasterRange = [-.5 .5];
p.plotRange = [-.2 .3]; 
p.psthdt = .001; 
smoothwin = 19; %boxcar smoothing window. smoothwin must be odd. 1 is no smoothing.
p.smoothwin = smoothwin; 
bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
p.figNum = 1;
p.papersize = 2*[3.5 2.5]; 
p.fontsize = 10; 

%% Test reliability of each unit during singing and during tutoring
% Units will be excluded from summary stats if not enough data was 
% recorded to reliably estimate the onset-aligned PSTH (determined by a 
% KS test on PSTHs estimated from random halves of the data). 
% In addition, units will be excluded from summary plots if the
% syllable-onset-aligned PSTHs lacks a clear peak (if it never exceeds the 
% mean by Nsigma = 3)

calcAllReliabilities = 1; 

if calcAllReliabilities
    rows1 = 1:length(SINGING); 
    p.Nsigma = 3; % must exceed mean by Nsigma*sigma to be considered 'reliable'
    p.latMethod = 'peakTime'; % 'peakTime' or 'thresCrossing'. Thres is Nsigma above mean.
    TUTOR_INCLUDE_KS = zeros(length(rows1),1);
    TUTOR_LOCKED = zeros(length(rows1),1);
    TUTOR_latency = zeros(length(rows1),1);
    SONG_INCLUDE_KS = zeros(length(rows1),1);
    SONG_LOCKED = zeros(length(rows1),1);
    SONG_latency = zeros(length(rows1),1);

    tic
    for rowi = 1:length(rows1) % remember to take rows 2:end if copying into xls
        if SINGING(rowi)
            p.sylType = 'song';
            Result = analyzeRow(rows1(rowi),p,'relLat'); 
            SONG_INCLUDE_KS(rowi) = Result.KS<.1; % if KS stat is reliable
            SONG_LOCKED(rowi) = Result.reliable; 
            SONG_latency(rowi) = Result.latency; 
        end
        if TUTORING(rowi)
            p.sylType = 'tutor';
            Result = analyzeRow(rows1(rowi),p,'relLat'); 
            TUTOR_INCLUDE_KS(rowi) = Result.KS<.1; % if KS stat is reliable
            TUTOR_LOCKED(rowi) = Result.reliable; 
            TUTOR_latency(rowi) = Result.latency; 
        end
        display(['row ' num2str(rows1(rowi))])
    end
    toc
    p.sylType = sylType;
else
    SONG_INCLUDE_KS = XLS.data.Sheet1(:,strmatch('SONG_INCLUDE_KS', Columns))==1;
    SONG_LOCKED = XLS.data.Sheet1(:,strmatch('SONG_LOCKED', Columns))==1;
    TUTOR_INCLUDE_KS = XLS.data.Sheet1(:,strmatch('TUTOR_INCLUDE_KS', Columns))==1;
    TUTOR_LOCKED = XLS.data.Sheet1(:,strmatch('TUTOR_LOCKED', Columns))==1;
end

%% How many units in each category?

Cats = {HASH SINGLEUNIT&HASH PUTPROJ&SINGLEUNIT ISOLATE&SINGLEUNIT&HASH (~ISOLATE)&SINGLEUNIT&HASH};
CatNames = {'units with hash' 'single units with hash' 'single unit putative projectors' 'single units with hash from isolate birds' 'single units with hash from nonisolate birds'}; 
for cati = 1:length(Cats)
    ThisCategory = Cats{cati}; 
    ThisCategoryName = CatNames{cati}; 
    tmp = ThisCategory;
    display([num2str(sum(tmp)) ' ' ThisCategoryName ', from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = ThisCategory&((SINGING&SONG_INCLUDE_KS)|(TUTORING&TUTOR_INCLUDE_KS)); 
    display([num2str(sum(tmp)) ' of those pass a ks test, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = SINGING&ThisCategory;
    display(['    ' num2str(sum(tmp)) ' during singing, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = SONG_INCLUDE_KS&SINGING&ThisCategory; 
    display(['        ' num2str(sum(tmp)) ' pass KS test, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = SONG_LOCKED&SINGING&ThisCategory;
    display(['        ' num2str(sum(tmp)) ' song locked, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    display(['           lat: [' num2str(min(SONG_latency(tmp))) ', ' num2str(max(SONG_latency(tmp))) '] mean=' num2str(mean(SONG_latency(tmp))) ', std=' num2str(std(SONG_latency(tmp))) 's'])
    tmp = SINGING&DIFF&ThisCategory;
    display(['        ' num2str(sum(tmp)) ' during multiple syllable types, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = SONG_INCLUDE_KS&SINGING&DIFF&ThisCategory;
    display(['            ' num2str(sum(tmp)) ' pass KS test, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = SONG_LOCKED&SINGING&DIFF&ThisCategory; 
    display(['            ' num2str(sum(tmp)) ' song locked, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = TUTORING&ThisCategory; 
    display(['    ' num2str(sum(tmp)) ' during tutoring, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = TUTOR_INCLUDE_KS&TUTORING&ThisCategory;
    display(['        ' num2str(sum(tmp)) ' pass KS test, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = TUTOR_LOCKED&TUTORING&ThisCategory;
    display(['        ' num2str(sum(tmp)) ' tutor locked, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    display(['           lat: [' num2str(min(TUTOR_latency(tmp))) ', ' num2str(max(TUTOR_latency(tmp))) '] mean=' num2str(mean(TUTOR_latency(tmp))) ', std=' num2str(std(TUTOR_latency(tmp))) 's'])
    display(['           ' num2str(sum(TUTOR_latency(tmp)<0)) ' pre-onset'])
    tmp = (Age<=45)&TUTOR_INCLUDE_KS&TUTORING&ThisCategory;
    display(['        ' num2str(sum(TUTOR_LOCKED&tmp)) ' out of ' num2str(sum(tmp)) ' tutor locked in birds <=45dph '])
    tmp = (Age>45)&TUTOR_INCLUDE_KS&TUTORING&ThisCategory;
    display(['        ' num2str(sum(TUTOR_LOCKED&tmp)) ' out of ' num2str(sum(tmp)) ' tutor locked in birds >45dph '])
    tmp = SINGING&TUTORING&ThisCategory;
    display(['    ' num2str(sum(tmp)) ' during both, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = TUTOR_INCLUDE_KS&SONG_INCLUDE_KS&SINGING&TUTORING&ThisCategory;
    display(['        ' num2str(sum(tmp)) ' pass both KS tests, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = TUTOR_INCLUDE_KS&SONG_INCLUDE_KS&TUTOR_LOCKED&SONG_LOCKED&SINGING&TUTORING&ThisCategory;
    display(['        ' num2str(sum(tmp)) ' pass both & locked to both, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = (SONG_INCLUDE_KS&(~SONG_LOCKED))&TUTOR_INCLUDE_KS&TUTOR_LOCKED&SINGING&TUTORING&ThisCategory; 
    display(['        ' num2str(sum(tmp)) ' pass both & only locked to tutoring, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
    tmp = SONG_INCLUDE_KS&SONG_LOCKED&(TUTOR_INCLUDE_KS&(~TUTOR_LOCKED))&SINGING&TUTORING&ThisCategory;
    display(['        ' num2str(sum(tmp)) ' pass both & only locked to singing, from ' num2str(length(unique(birdID(tmp)))) ' birds'])

%     display(['        ' num2str(sum(TUTOR_INCLUDE_KS&SINGING&TUTORING&ThisCategory)) ' pass tutoring KS test, from ' num2str(length(unique(birdID(TUTOR_INCLUDE_KS&SINGING&TUTORING&ThisCategory)))) ' birds'])
%     display(['        ' num2str(sum(TUTOR_LOCKED&SINGING&TUTORING&ThisCategory)) ' tutor locked, from ' num2str(length(unique(birdID(TUTOR_LOCKED&SINGING&TUTORING&ThisCategory)))) ' birds'])
%     display(['        ' num2str(sum(SONG_INCLUDE_KS&SINGING&TUTORING&ThisCategory)) ' pass song KS test, from ' num2str(length(unique(birdID(SONG_INCLUDE_KS&SINGING&TUTORING&ThisCategory)))) ' birds'])
%     display(['        ' num2str(sum(SONG_LOCKED&SINGING&TUTORING&ThisCategory)) ' song locked, from ' num2str(length(unique(birdID(SONG_LOCKED&SINGING&TUTORING&ThisCategory)))) ' birds'])
    tmp = ASUBSONG&ThisCategory;
    display(['    ' num2str(sum(tmp)) ' artificial subsong, from ' num2str(length(unique(birdID(tmp)))) ' birds'])
end


%% calculating reliability and latency for each row. Takes ~10 seconds. 

p.Nsigma = 3; % must exceed mean by Nsigma*sigma to be considered 'reliable'
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
%% make figs for each neuron, each syllable
genfigs = 0; % generate figures for each neuron?
p.makeFig = 1; 
p.MaxToPlot = 200;
%set(p.figNum, 'color', [1 1 1]) 
Fstat = []; 
pval = []; 
for rowi = [1:numel(rows)]
    row = rows(rowi); 
    filestr = fullfile(SaveFigPath, [ThisDataset, '_row', num2str(row), '_Age', num2str(Age(row))]); 
    if genfigs
        analyzeRow(row, p, 'fourRasters');
        saveas(p.figNum,[filestr '_FourRasters.fig'])
        saveas(p.figNum,[filestr '_FourRasters.jpg'])
    end
    sylType = p.sylType; 
    p.sylType = 'specified'; 
    switch sylType
        case 'song'
            stypes = eval(XLS.textdata.Sheet1{row,strmatch('song syl names', Columns)});
        case 'tutor'
            stypes = eval(XLS.textdata.Sheet1{row,strmatch('T syl names', Columns)});
        otherwise
            stypes = [eval(XLS.textdata.Sheet1{row,strmatch('song syl names', Columns)})...
                eval(XLS.textdata.Sheet1{row,strmatch('T syl names', Columns)})]; 
            warning('using all syllable types')
    end
    forANOVACounts = []; 
    forANOVAIDs = {}; 
    for stypei = 1:length(stypes)
        clf
        p.sylName = (stypes(stypei)); 
        try; sname = char(p.sylName); catch; sname = '[]'; end
        if genfigs
            analyzeRow(row, p, 'PSTH'); drawnow; pause(.1);
            saveas(p.figNum,[filestr '_' sname '.jpg'])
            saveas(p.figNum,[filestr '_' sname '.fig'])
        end
        % for anova analysis
        if ~issame(sname, '[]') % don't include unlabeled syllables in anova analysis
            p1 = p; 
            p1.rasterRange = [-.05 .02]; 
            p1.makeFig = 0; 
            cnts = analyzeRow(row, p1, 'forANOVA'); 
            forANOVACounts = [forANOVACounts cnts]; 
            forANOVAIDs((end+1):(end+length(cnts))) = repmat({sname}, 1, length(cnts)); % = [forANOVAIDs stypei*ones(1,length(cnts))]; 
        end
    end
    % for anova analysis
    [~,tbl] = anova1(forANOVACounts, forANOVAIDs, 'off');
    Fstat(rowi) = tbl{2,5};
    pval(rowi) = tbl{2,6};
    if genfigs
        figure; 
        boxplot(forANOVACounts, forANOVAIDs);
        ylabel('spike count'); xlabel('syllable')
        title({['row ' num2str(row)]; ['ANOVA: F = ' num2str(Fstat(rowi)), ', p = ', num2str(pval(rowi))]}); 
        box off;
        set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize', p.fontsize)
        set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
        saveas(gcf,[filestr '_ANOVA.jpg'])
        saveas(gcf,[filestr '_ANOVA.fig'])
    end
    % put back to original setting
    p.sylType = sylType;
end
p.makeFig = 0; 
figure; hold on; set(gca, 'xscale', 'log', 'yscale', 'log')
pval = pval+eps; 
for rowi = 1:length(rows); plot(Fstat(rowi),pval(rowi), 'k.'); text(Fstat(rowi),pval(rowi)+eps*rand, num2str(rows(rowi))); end
plot([min(Fstat) max(Fstat)], [.05 .05]/length(rows), 'r'); % bonferroni corrected 
plot([1 1], [min(pval) max(pval)], 'r')
axis tight; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize', p.fontsize)
xlabel('F statistic'); ylabel('p value + \epsilon')
set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'ANOVAResults_' sylType '.fig'])); 
saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'ANOVAResults_' sylType '.jpg']));
sound(sin(1:900)); 

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
        scatter(latency, Age(rows)+jitt'/5, 'Cdata', birdColors(birdnum(rows),:), 'markerfacecolor', 'flat'); 
        plot(latFitAge, Age(rows), 'r'); 
        title(['Latency vs Age: R^2 = ' num2str(latRsqAge)])
        box off; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',p.fontsize)
        xlabel('Latency (s)'); ylabel('Age (dph)'); %b = colorbar; ylabel(b, 'Age (dph)')
        set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
        saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'SortByAge_' p.sylType '.fig'])); 
        saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'SortByAge_' p.sylType '.jpg']));
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
        scatter(latency, elecPosition(rows)+jitt, 'Cdata', birdColors(birdnum(rows),:), 'markerfacecolor', 'flat'); 
        plot(latFitPosition, elecPosition(rows), 'r'); 
        title(['Latency vs Position: R^2 = ' num2str(latRsqPosition)])
        box off; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',p.fontsize)
        xlabel('Latency (s)'); ylabel('Position along NIf axis (um)');
        set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
        saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'SortByElecPos_' p.sylType '.fig'])); 
        saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'SortByElecPos_' p.sylType '.jpg'])); 
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
        box off; set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',p.fontsize)
        set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3]);
        ylim([-.1 .1])
        title(['Rank sum test p = ' num2str(pRankSum)])
        saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'ElecPos_' p.sylType '.fig'])); 
        saveas(gcf, fullfile(SaveFigPath, [ThisDataset, 'ElecPos_' p.sylType '.jpg'])); 
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
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',p.fontsize)
set(gca, 'xtick', [])
hold on
plot([0 0], [-1 1], 'r')

% heatmap of population responses
h = subplot(4,1,2:4); hold on
%imagesc(zscorePSTHs, 'xdata', bins)
surf(bins, 1:size(zscorePSTHs,1), zscorePSTHs, 'edgecolor', 'none'); view(0,90); axis tight

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
            plot3([bins(1) bins(end)], [bracRow(abi) bracRow(abi)], [1000 1000],'Color', [1 1 1]);
        end
        bInd = [1 diff(bracRow)>0]==1;
        bracRow = bracRow(bInd); 
        AgeBrackets = AgeBrackets(bInd);
        set(gca, 'ytick', bracRow, 'yticklabel', AgeBrackets, 'ydir', 'normal')
        plot3([0 0], [0 length(rows)]+.5, [1000 1000],'r')
        ylabel('Age (dph)');
    case 'elecpos'
        posBrackets = -200:100:1000;
        posBrackets = posBrackets(posBrackets>=elecPosition(rows(1)) & posBrackets<= elecPosition(rows(end))); 
        bracRow = []; 
        for abi = 1:length(posBrackets)
            tmp = elecPosition(rows); 
            tmp1 = find(tmp>=posBrackets(abi)); 
            bracRow(abi) = tmp1(1)-.5; 
            plot3([bins(1) bins(end)], [bracRow(abi) bracRow(abi)],  [1000 1000],'Color', [1 1 1]);
        end
        bInd = [1 diff(bracRow)>0]==1;
        bracRow = bracRow(bInd); 
        posBrackets = posBrackets(bInd);
        set(gca, 'ytick', bracRow, 'yticklabel', posBrackets, 'ydir', 'normal')
        plot3([0 0], [0 length(rows)]+.5, [1000 1000],'r')
        ylabel('Position along NIf axis (um)');
    case 'latency'
        latBrackets = -.1:.025:.1;
        latBrackets = latBrackets(latBrackets>=latency(1) & latBrackets<= latency(end)); 
        bracRow = []; 
        for abi = 1:length(latBrackets)
            tmp = latency; 
            tmp1 = find(tmp>=latBrackets(abi)); 
            bracRow(abi) = tmp1(1)-.5; 
            plot3([bins(1) bins(end)], [bracRow(abi) bracRow(abi)],  [1000 1000],'Color', [1 1 1]);
        end
        bInd = [1 diff(bracRow)>0]==1;
        if length(bracRow)>0
            bracRow = bracRow(bInd); 
            latBrackets = latBrackets(bInd);
        end
        set(gca, 'ytick', bracRow, 'yticklabel', latBrackets, 'ydir', 'normal')
        plot3([0 0], [0 length(rows)]+.5, [1000 1000], 'r')
        ylabel('Latency (s)');
end
for rowi = 1:length(rows)
    if PUTPROJ(rows(rowi)); tmp = 'flat'; else; tmp = 'none'; end
    scatter3((bins(end) - 3*p.psthdt), rowi, 1000,'s','Cdata', birdColors(birdnum(rows(rowi)),:), 'MarkerFaceColor', tmp);
%     if latency(rowi)~=100 % plot latency on figure, for debugging
%         plot3(latency(rowi),rowi, 1000,'w.', 'markersize', .25)
%     end
end
%colorbar('ytick', [-2 0 2], 'yticklabel', {'-2 std', 'mean', '+2 std'})
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025], 'fontsize',p.fontsize)
axis tight; box off; 
set(gcf, 'papersize', [5 5], 'paperposition', [0 0 5 5]);
linkaxes([h g], 'x')
saveas(gcf, fullfile(SaveFigPath, [ThisDataset, '_PopulationPlot_SortedBy' SortBy, '_', p.sylType '.fig'])); 
saveas(gcf, fullfile(SaveFigPath, [ThisDataset, '_PopulationPlot_SortedBy' SortBy, '_', p.sylType '.jpg'])); 
end
end