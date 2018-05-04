%% load isolate excel sheet
clear all; 
XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/ISOLATES.xls'); % edit isolate_inventory
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
birdnum = [0; XLS.data.Sheet1(2:end,strmatch('Name', Columns))];

%% transfer files over

for row = 2; 
feeboxfolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
AllDays = dir(fullfile(feeboxfolder, num2str(birdnum(row)), '*20*')); % hack to get just date folders
% make a new folder with 5 example files per day
savehere = fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
    num2str(birdnum(row)), 'OnePerDay'); 
mkdir(savehere); 
% for each day
tic
for dayi = 1:length(AllDays)
    try
        age = datenum(AllDays(dayi).name) - birthday(row); % compute age
        if age<=60
            nTransfer = 10; %10+10*(age<=50); 
        allfiles = dir(fullfile(feeboxfolder, num2str(birdnum(row)), AllDays(dayi).name, '*.dat'));
        if length(allfiles) > nTransfer % if at least 20 files
            ChosenFive = (1:nTransfer) + ceil(length(allfiles)/2); % pick 1 examples from the middle
            for i = 1:length(ChosenFive)
                copyfile(fullfile(feeboxfolder, num2str(birdnum(row)), ...
                    AllDays(dayi).name, allfiles(ChosenFive(i)).name), ...
                    fullfile(savehere, [num2str(age) 'dph_', ...
                    allfiles(ChosenFive(i)).name]))
            end
        end
        end
% copy them, appending age to the file name
    catch 
        warning(['skipping this folder: ' AllDays(dayi).name ])
    end
    display([AllDays(dayi).name ' ' num2str(birdnum(row))])
    toc
end
end

sound(sin(.1:.3:4000)); 

%% segment song (do this with electro_gui)

%% make pages for binder
for row = 19:21;%[10 11 16 18 23:24]; % eventually go to 24
    try
% load analysis file
load(fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
    num2str(birdnum(row)), 'OnePerDay', 'analysis_segmented'));
DumpFigsHere = 'C:\Users\emackev\Documents\MATLAB\code\RasterPlots\IsolateSpecgrams'
figure(1); clf
c = 1; 
d = 1; 
FilesPerPage = 15; 
SecondsPerFile = 4; 
% sort by age...
clear age
for fi = 1:length(dbase.SoundFiles)
    age(fi) = str2num(dbase.SoundFiles(fi).name (1:regexp(dbase.SoundFiles(fi).name, 'dph')-1)); 
end
[age,sortbyage] = sort(age, 'ascend'); 
dbase.SoundFiles = dbase.SoundFiles(sortbyage);
dbase.SegmentIsSelected = dbase.SegmentIsSelected(sortbyage);
dbase.SegmentTimes = dbase.SegmentTimes(sortbyage);
for fi = 1:length(dbase.SoundFiles)
    if sum(dbase.SegmentIsSelected{fi})>0
    % load one bout
    [sndOrig fsOrig dt label props] = ...
        eval(['egl_' dbase.SoundLoader...
        '([''' fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
        num2str(birdnum(row)), 'OnePerDay', ...
        dbase.SoundFiles(fi).name) '''],1)']);
    axes('Parent',1,'Units','normalized',...
        'Position',[.1 c*.8/FilesPerPage+.1 .8 .8/FilesPerPage]);
%     subplot('position', [.1 c*.8/10+.1 .8 .09]);
    sndOrig = [sndOrig; zeros(round(fsOrig*SecondsPerFile),1)]; 
    sndOrig = sndOrig(1:round(fsOrig*SecondsPerFile)); 
    [S,Time,F] = spectrogramELM(sndOrig,fsOrig,.005, 1); 
    % plot segments
    hold on
    for si = 1:size(dbase.SegmentTimes{fi},1)
        if dbase.SegmentIsSelected{fi}(si)&&dbase.SegmentTimes{fi}(si,2)/fsOrig<=SecondsPerFile
            patch(dbase.SegmentTimes{fi}(si,[1 2 2 1 1])/fsOrig, 6+.5*[0 0 1 1 0],...
                [1 0 0], 'Edgecolor','none', 'facecolor', [1 0 0])
        end
    end
    
    if c~=1; 
        set(gca,'xtick', []); set(gca,'ytick', []); xlabel('')
    else
        set(gca,'ytick', []);
    end


    set(gca, 'tickdir','out','ticklength',[0.025 0.01]); grid off; box off
    ylim([.5 7])
    ylabel([num2str(age(fi)) 'dph'], 'fontsize', 6)
%     text(0,1,dbase.SoundFiles(fi).name, 'Color','w', ...
%         'verticalalignment', 'bottom', 'fontsize', 6, ...
%         'interpreter', 'none'); 
    c = c+1;
    shg
    drawnow
    papersize = [8 10]; 
    set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
    if c == FilesPerPage || fi == length(dbase.SoundFiles)
        title(num2str(birdnum(row)))
        saveas(gcf, fullfile(DumpFigsHere, ...
            ['Isolate' num2str(birdnum(row)) '_' num2str(d) '.jpg'])); 
        clf
        d = d+1; 
        c = 1;
    end
    end
end


    catch
    end
end

%% autocorrelation and spectra over development
maxlag = .4; 
specDT = .002; 
desFreqs = .1:.1:15; 
rows = 2:23; 
CorrMat = {}; 
SpecMat = {}; 
for rowi = 1:length(rows)
    row = rows(rowi);
    try
        % load analysis file
        load(fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
            num2str(birdnum(row)), 'OnePerDay', 'analysis_segmented'));
        DumpFigsHere = 'C:\Users\emackev\Documents\MATLAB\code\RasterPlots\IsolateSpecgrams';
        % sort by age...
        clear age
        for fi = 1:length(dbase.SoundFiles)
            age(fi) = str2num(dbase.SoundFiles(fi).name (1:regexp(dbase.SoundFiles(fi).name, 'dph')-1)); 
        end
        [age,sortbyage] = sort(age, 'ascend'); 
        dbase.SoundFiles = dbase.SoundFiles(sortbyage);
        dbase.SegmentIsSelected = dbase.SegmentIsSelected(sortbyage);
        dbase.SegmentTimes = dbase.SegmentTimes(sortbyage);
        CorrMat{rowi} = zeros(length(dbase.SoundFiles), 2*maxlag/specDT+1);
        SpecMat{rowi} = zeros(length(dbase.SoundFiles), length(desFreqs));
        for fi = 1:length(dbase.SoundFiles)
            if sum(dbase.SegmentIsSelected{fi})>0
            % load one file
            [sndOrig fsOrig dt label props] = ...
                eval(['egl_' dbase.SoundLoader...
                '([''' fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
                num2str(birdnum(row)), 'OnePerDay', ...
                dbase.SoundFiles(fi).name) '''],1)']);
            
            % divide the file into song bouts
            moatSong = .15; % time around song syllables that is still counted as song
            segTimes = dbase.SegmentTimes{fi}/fsOrig; 
            isSongSyl = dbase.SegmentIsSelected{fi}; 
            filelength = length(sndOrig)/fsOrig; 
            CurrentlySong = 0; 
            SongBouts = segTimes(isSongSyl==1,:); 
            if size(SongBouts,1)>0
                Gaps = [[0; SongBouts(:,2)+moatSong] [SongBouts(:,1)-moatSong; filelength]]; 
                Gaps((Gaps(:,2)-Gaps(:,1))<0,:) = [];
                SongBouts = [[0; Gaps(:,2)] [Gaps(:,1); filelength]]; 
                SongBouts(SongBouts(:,2)==0|SongBouts(:,1) == filelength,:) = [];
            end
            
            % crop around longest bout of singing
            [~,LongestBoutID] = max(diff(SongBouts'));
            sndOrig = sndOrig((1/fsOrig+SongBouts(LongestBoutID,1)*fsOrig):SongBouts(LongestBoutID,2)*fsOrig); 


            [S,Time,F] = spectrogramELM(sndOrig,fsOrig,specDT, 0); 
            Amplitude = amplitudeELM(S,F); 
            [CorrMat{rowi}(fi,:),lags] = xcorr(Amplitude - mean(Amplitude), maxlag/specDT, 'coeff'); 
            [P,f] = PowerSpectrumELM(CorrMat{rowi}(fi,:), 1/specDT, 4);
            SpecMat{rowi}(fi,:) = interp1(f,P,desFreqs);
            end
        end
        CorrMat{rowi}(sum(CorrMat{rowi},2)==0,:) = []; 
        SpecMat{rowi}(sum(CorrMat{rowi},2)==0,:) = [];
        age(sum(CorrMat{rowi},2)==0) = []; 
        
%         figure(1); clf
%         h(2) = subplot('position', [.1 .1 .8 .6]);
%         imagesc(CorrMat{rowi}, 'xdata', lags*specDT, .5*[-1 1]); 
%         CMAP = [(1:64)'/64  (1:64)'/64 ones(64,1); ...
%         ones(64,1) (64:-1:1)'/64 (64:-1:1)'/64 ];
%         colormap(CMAP)
%         ticks = get(gca, 'ytick'); 
%         set(gca, 'yticklabels', age(ticks))
%         set(gca, 'tickdir','out','ticklength',[0.01 0.01], 'fontsize', 7);%box off
%         xlabel('Lag (s)'); ylabel('Age (dph)'); 
%         h(1) = subplot('position', [.1 .7 .8 .2]);
%         plot(lags*specDT, median(CorrMat{rowi},1), 'k'); 
%         hold on; plot([0 maxlag], [0 0], 'k');axis tight; axis off
%         linkaxes(h,'x'); xlim([0 maxlag]);
%         text(.3,.5,num2str(birdnum(row))); 
%         papersize = [4 4]; 
%         set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%         saveas(gcf, fullfile(DumpFigsHere, ...
%                     ['Isolate' num2str(birdnum(row)) '_Autocorr.jpg'])); 
%                 
%         figure(2); clf
%         h(2) = subplot('position', [.1 .1 .8 .6]);
%         imagesc((SpecMat{rowi}), 'xdata', desFreqs); 
%         colormap(parula)
%         ticks = get(gca, 'ytick'); 
%         set(gca, 'yticklabels', age(ticks))
%         set(gca, 'tickdir','out','ticklength',[0.01 0.01], 'fontsize', 7);%box off
%         xlabel('Lag (s)'); ylabel('Age (dph)'); 
%         h(1) = subplot('position', [.1 .7 .8 .2]);
%         plot(desFreqs, median(SpecMat{rowi},1), 'k'); 
%         hold on; axis tight; axis off
%         linkaxes(h,'x');
%         xlims = xlim; ylims = ylim; 
%         text(.9*xlims(end),.9*ylims(end),num2str(birdnum(row))); 
%         papersize = [4 4]; 
%         set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
%         saveas(gcf, fullfile(DumpFigsHere, ...
%         ['Isolate' num2str(birdnum(row)) '_Spectrum.jpg'])); 
%         drawnow
row
    catch exception
        exception
    end
end


%% scatter plots
figure(3); clf
ToScatter = [];

mycats = [0; XLS.data.Sheet1(2:end,strmatch('1=fast,2=slow,3=other', Columns))];

for rowi = 1:length(rows)
    ToScatter(rowi,:) = [median(SpecMat{rowi},1)];
end
ToScatter = bsxfun(@minus, ToScatter, min(ToScatter,[],1))+eps; 

ToScatter = bsxfun(@rdivide, ToScatter, std(ToScatter,1)+eps); 
parameters.perplexity = 2;
[yData,betas,P,errors] = run_tSne(ToScatter, parameters);
plot(yData(:,1), yData(:,2), '.')
for rowi = 1:length(rows)
    text(yData(rowi,1), yData(rowi,2), num2str(birdnum(rows(rowi))))
end
%%
% [U,S,V] = svd(ToScatter); 
% slow vs fast rhythms
% slowInd = (desFreqs>3&desFreqs<5);
% fastInd = (desFreqs>8&desFreqs<10);

figure(3); clf; hold on
% X = sum(ToScatter(:,slowInd),2);%./sum(ToScatter,2);
% Y = sum(ToScatter(:,fastInd),2);%./sum(ToScatter,2);
X = yData(:,1); 
Y = yData(:,2);
% plot(X,Y, '.')
MarkerSize = 1e6; 
Colors = [1 0 0; 0 .5 1; 0 1 0]; 
for rowi = 1:length(rows)
    row = rows(rowi);
%     psthTheta = lags*pi/lags(end) + pi/2; 
%     psthR = (ToScatter(rowi,:)-min(ToScatter(rowi,:))); %/sum(ToScatter(rowi,:));
    
    psthTheta = fliplr(desFreqs*2*pi/desFreqs(end))+pi/2; 
    psthR = median(SpecMat{rowi},1); 
    
    psthR = MarkerSize*psthR; 
    % make it circular, 
    psthX = psthR.*cos(psthTheta); 
    psthY = psthR.*sin(psthTheta); 
    plot(psthX+X(rowi),psthY+Y(rowi), 'color', Colors(mycats(row),:)); 
    text(X(rowi), Y(rowi), num2str(birdnum(rows(rowi))), 'fontsize', 6)
end
xlabel('tSNE1'); ylabel('tSNE2')
papersize = [4 4]; 
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
% set(gca, 'xscale', 'log', 'yscale', 'log'); %axis tight










% 
% 
% 
% %% process for tSNE
% for row = 2:22
% try
% rowstr = ['Isolate' num2str(row)]; 
% % load analysis file
% load(fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
%     num2str(birdnum(row)), 'OnePerDay', 'analysis_segmented'));
% fs = dbase.Fs;
% nFiles = length(dbase.SegmentTimes); 
% % load bouts, compute features, and concatenate
% AllLabels = [];
% for FileToLoad = 1:nFiles; 
%     display(['Processing file ', num2str(FileToLoad)]); 
%     % load one bout
%     [sndOrig fsOrig dt label props] = ...
%         eval(['egl_' dbase.SoundLoader...
%         '([''' fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
%         num2str(birdnum(row)), 'OnePerDay', ...
%         dbase.SoundFiles(FileToLoad).name) '''],1)']);
%     
%     % resample data
%     fs = 40000;
%     if round(fs)~=round(fsOrig)
%         warning('resampling song'); 
%         snd1 = interp1((1:length(sndOrig))/fsOrig, sndOrig, (1/fs):(1/fs):(length(sndOrig)/fsOrig))';
%         dbase.SegmentTimes{FileToLoad} = dbase.SegmentTimes{FileToLoad}*fs/fsOrig;
%     else
%         snd1 = sndOrig;
%     end
%     specDT = .005;
%     
%     % drop long gaps
%     [snd, timeInds, labels, SylFileNum, SylSegNum] = ...
%         DropLongGapsNIf(dbase, FileToLoad, snd1, fs);
% 
%     % compute spectrogram
%     data.song = snd;
%     data.fs = fs;
%     data.labels = [labels'; SylFileNum'; SylSegNum'];
%     if length(snd)>0
%         [newLabels FeatureInd] = FeatureLabelsNIf(data, specDT);
%         AllLabels = [AllLabels newLabels];
%     end
% end
% AllLabels = fliplr(AllLabels); 
% % AllLabelsOld = AllLabels;
% %% perform tSNE
% % AllLabels = AllLabelsOld; 
% % AllLabels = AllLabels(:,1:2100); 
% indForTsne = [FeatureInd.Spectrogram];
% 
% % nicer spectrogram for gui
% ForGUI = AllLabels; 
% ForGUI(FeatureInd.ForGuiSpectrogram,:) = cdfscore(AllLabels(FeatureInd.ForGuiSpectrogram,:)',[70 100])'; 
% 
% % cut out the gaps
% labels = AllLabels(FeatureInd.TimeFromOnset,:); 
% logNoGaps = (labels~=-2) & ...
%     (labels>0) & (labels<1); % don't embed gaps, or points in the very beginning/end of syllables
% logSubSample = logNoGaps; 
% ToTsne = AllLabels(indForTsne,logNoGaps);
% 
% parameters = setRunParameters;
% parameters.training_perplexity = 2*parameters.training_perplexity;
% parameters.perplexity = 2*parameters.perplexity;
% parameters.num_tsne_dim = 3; 
% if size(ToTsne,2)<2000 % just do normal tsne, not recurrent tsne
%     tic
%     [yData,betas,P,errors] = run_tSne(ToTsne', parameters);
%     display(['tSne on ' rowstr ...
%         ' took ' num2str(toc) 's, on ' num2str(size(ToTsne,2)) ' slices']); 
%     Spectro = ForGUI;
%     selected = logSubSample;
%     Spectro(FeatureInd.TimeFromOnset,~selected) = 0; 
%     tSNE_Coord = yData; 
%     figure; clf; plot3(yData(:,1), yData(:,2), yData(:,3),'.'); title(rowstr); shg; drawnow; 
% else % do recurrent tsne
%     % padding tsne, because recurrent tsne skips first and last 950 pts
%     nSkipped = 950; 
%     indTsne = [size(ToTsne,2)-(1:(nSkipped+100)) ...
%         1:size(ToTsne,2) ...
%         1:nSkipped]; % adding 100 because there's at most 100 slices slop, and recurrent tsne starts from the end.
%     ToTsne = ToTsne(:,indTsne); 
% 
%     tic
%     [X,Y,Z,nb_iter,size_step,window_size] = recurrent_tSNE_3D(ToTsne, parameters);
%     display(['recurrent tSne on ' rowstr ...
%         ' took ' num2str(toc) 's, on ' num2str(size(ToTsne,2)) ' slices']); 
% 
%     % need to unwrap
%     X1 = flipud(X); Y1 = flipud(Y); Z1 = flipud(Z); 
%     tSNE_Coord = [flipud(X1(:)) flipud(Y1(:)) flipud(Z1(:))];
%     useme = (size(tSNE_Coord,1) - sum(logSubSample)+1):size(tSNE_Coord,1); % remove slop at the beginning
%     tSNE_Coord = tSNE_Coord(useme,:); 
%     selected = logSubSample;
%     Spectro = ForGUI;
%     Spectro(FeatureInd.TimeFromOnset,~selected) = 0; 
%     figure; clf; plot3(X(:), Y(:), Z(:),'.'); title(rowstr); shg; drawnow; 
% end
% 
% save(['C:\Users\emackev\Documents\MATLAB\TsneResults\IsolateTsne_' rowstr],...
%     'Spectro','tSNE_Coord','selected', 'FeatureInd')
% emailme(['tsne''d ' rowstr])
% catch
% end
% end