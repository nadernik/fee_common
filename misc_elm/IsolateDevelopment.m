%% load isolate excel sheet
clear all; 
XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/ISOLATES.xls'); % edit isolate_inventory
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
birdnum = [0; XLS.data.Sheet1(2:end,strmatch('Name', Columns))];

%% transfer files over

for row = 2:24; 
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
        allfiles = dir(fullfile(feeboxfolder, num2str(birdnum(row)), AllDays(dayi).name, '*.dat'));
        if length(allfiles) > 10 % if at least 10 files
            ChosenFive = (1) + ceil(length(allfiles)/2); % pick 1 examples from the middle
            for i = 1:5
                copyfile(fullfile(feeboxfolder, num2str(birdnum(row)), ...
                    AllDays(dayi).name, allfiles(ChosenFive(i)).name), ...
                    fullfile(savehere, [num2str(age) 'dph_', ...
                    allfiles(ChosenFive(i)).name]))
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



%% segment song (do this with electro_gui)

%% make pages for binder
for row = 23:24;%[10 11 16 18 23:24]; % eventually go to 24
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

%% autocorrelation over development
maxlag = .4; 
specDT = .002; 

% to fit autocorr of sinewave: 
sineAC = @(omega) ...
    cos(lags*specDT*2*pi*omega).* ...
    (length(Amplitude)*specDT - abs(lags*specDT))/(length(Amplitude)*specDT);
tryOmegas = 1:.2:12; 

    
for row = 2:24;%[10 11 16 18 23:24]; % eventually go to 24
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
        CorrMat = zeros(length(dbase.SoundFiles), 2*maxlag/specDT+1);
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
            [CorrMat(fi,:),lags] = xcorr(Amplitude - mean(Amplitude), maxlag/specDT, 'coeff'); 


        %     ToFit = CorrMat(fi,:) - mean(CorrMat(fi,:)); 
        % %     ToFit(abs(lags)<tryOmegas(end)) = 0;
        %     
        %     for i = 1:length(tryOmegas)
        % %         plot(sineAC(tryOmegas(i)).*(ToFit)*tryOmegas(i)); ylim([-.25 1]); pause(.1)
        %         FitMat(fi,i) = sum(sineAC(tryOmegas(i)).*(ToFit)*tryOmegas(i)); 
        %     end
        %     
            %     plot(lags*specDT,CorrMat(fi,:))
        %     sndOrig = [sndOrig; zeros(round(fsOrig*SecondsPerFile),1)]; 
        %     sndOrig = sndOrig(1:round(fsOrig*SecondsPerFile)); 


            end
        end
        CorrMat(sum(CorrMat,2)==0,:) = []; 
        age(sum(CorrMat,2)==0) = []; 
        figure(1); clf
        h(2) = subplot('position', [.1 .1 .8 .6]);
        imagesc(bsxfun(@minus, CorrMat, mean(CorrMat,2)), 'xdata', lags*specDT); colormap parula; shg
        ticks = get(gca, 'ytick'); 
        set(gca, 'yticklabels', age(ticks))
        xlabel('Lag (s)'); ylabel('Age (dph)'); 

        h(1) = subplot('position', [.1 .7 .8 .2]);
        plot(lags*specDT, median(bsxfun(@minus, CorrMat, mean(CorrMat,2)),1), 'k'); axis tight; axis off

        linkaxes(h,'x'); xlim([0 maxlag])
        title(num2str(birdnum(row))); 
        papersize = [4 4]; 
        set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
        saveas(gcf, fullfile(DumpFigsHere, ...
                    ['Isolate' num2str(birdnum(row)) '_Autocorr.jpg'])); 

        %         figure(2); clf
        % h(2) = subplot('position', [.1 .1 .8 .6]);
        % imagesc(FitMat, 'xdata', tryOmegas); colormap parula; shg
        % ticks = get(gca, 'ytick'); 
        % set(gca, 'yticklabels', age(ticks))
        % xlabel('Freq(Hz)'); ylabel('Age (dph)'); 
        % 
        % h(1) = subplot('position', [.1 .7 .8 .2]);
        % plot(tryOmegas, median(FitMat,1), 'k'); axis tight; axis off
        % 
        % linkaxes(h,'x'); 
        % title(num2str(birdnum(row))); 
        % drawnow;
        % papersize = [4 4]; 
        % set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
        % saveas(gcf, fullfile(DumpFigsHere, ...
        %             ['Isolate' num2str(birdnum(row)) '_Autocorr.jpg'])); 
        
    catch exception
        exception
    end
end

















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