function Result = analyzeRow(row, p, task)

% collect params from p
XLS = p.XLS; 
Columns = p.Columns;

% load analysis file
[dbase rowstr pathname filename] = getDbase_elm(row, XLS, Columns);
fs = dbase.Fs;
 

% bird = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns)));
% day = XLS.textdata.Sheet1{row,strmatch('day', Columns)};
% depth = XLS.textdata.Sheet1{row,strmatch('folder', Columns)};
% feeboxFolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
% if strmatch('feebox4',feeboxFolder)
%     feeboxFolder = '\\feebox6\shared\emackev\AcqGui\';
% end
% if strmatch('feebox5',feeboxFolder)
%     feeboxFolder = '\\feebox5\emily\AcqGui\';
% end
% filename = ['analysis' depth(2:end)];

% getting the relevant info from NIfUnits spreadsheet
eventNum = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns)); 
chanNum = XLS.data.Sheet1(row,strmatch('electrode #', Columns))+1;
TutorSylNames = eval(XLS.textdata.Sheet1{row,strmatch('T syl names', Columns)});
SongSylNames = eval(XLS.textdata.Sheet1{row,strmatch('song syl names', Columns)});
ASubSylNames = eval(XLS.textdata.Sheet1{row,strmatch('AS syl names', Columns)}); 

p.eventNum = eventNum; 
p.TutorSylNames = TutorSylNames; 
p.SongSylNames = SongSylNames;
p.ASubSylNames = ASubSylNames; 
p.rowstr = rowstr; 


%%

switch task
    case 'PSTH' % doesn't need rasterMatrix
        [PSTH plotX plotY allDur]  = PSTH_elm(dbase, p);
        Result = PSTH; 
    case 'relDKL' % this just calculates DKL.  'relLat' also calculates DKL
        [PSTH plotX plotY allDur]  = PSTH_elm(dbase, p);
        bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
        nSyls = length(allDur);
        perm = randperm(nSyls);
        indA = ismember(plotY(1,:),perm(1:ceil(nSyls/2)));
        indB = ismember(plotY(1,:),perm((ceil(nSyls/2)+1):end));
        PSTHA = smooth(hist(plotX(1,indA),bins),p.smoothwin); 
        PSTHB = smooth(hist(plotX(1,indB),bins),p.smoothwin);  
%         PSTHA = smooth(sum(rasterMatrix(perm(1:ceil(nSyls/2)),:),1),p.smoothwin);
%         PSTHB = smooth(sum(rasterMatrix(perm((ceil(nSyls/2)+1):end),:),1),p.smoothwin);
        PA = PSTHA/sum(PSTHA)+eps; 
        PB = PSTHB/sum(PSTHB)+eps; 
        DKL = sum(PA.*log(PA./PB)) + sum(PB.*log(PB./PA)); 
        Result = DKL; 
    case 'ksTest'
        [PSTH plotX plotY allDur]  = PSTH_elm(dbase, p);
        bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
        nSyls = length(allDur);
        perm = randperm(nSyls);
        indA = ismember(plotY(1,:),perm(1:ceil(nSyls/2)));
        indB = ismember(plotY(1,:),perm((ceil(nSyls/2)+1):end));
        [~,Result] = kstest2(plotX(1,indA),plotX(1,indB));
    case 'relLat'
        [PSTH plotX plotY allDur]  = PSTH_elm(dbase, p);
        bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
        % first calculate DKL
        nSyls = length(allDur);
        perm = randperm(nSyls);
        indA = ismember(plotY(1,:),perm(1:ceil(nSyls/2)));
        indB = ismember(plotY(1,:),perm((ceil(nSyls/2)+1):end));
        PSTHA = smooth(hist(plotX(1,indA),bins),p.smoothwin); 
        PSTHB = smooth(hist(plotX(1,indB),bins),p.smoothwin);  
%         PSTHA = smooth(sum(rasterMatrix(perm(1:ceil(nSyls/2)),:),1),p.smoothwin);
%         PSTHB = smooth(sum(rasterMatrix(perm((ceil(nSyls/2)+1):end),:),1),p.smoothwin);
        PA = PSTHA/sum(PSTHA)+eps; 
        PB = PSTHB/sum(PSTHB)+eps; 
        DKL = sum(PA.*log(PA./PB)) + sum(PB.*log(PB./PA)); 
        Result.DKL = DKL; 
        [~,~,Result.KS] = kstest2(plotX(1,indA),plotX(1,indB));
        % calculate mean and std in full window 
        PSTH = smooth(hist(plotX(1,:),bins),p.smoothwin); 
        indBaseline = find(bins<-.1|bins>.1); 
        mu = mean(PSTH(indBaseline)); 
        sigma = std(PSTH(indBaseline)); 
        % find the first time it exceeds 2std above the mean
        indElig = find(bins>=-.1&bins<=.1); 
        thresCrossings = find((PSTH(indElig)-mu)>p.Nsigma*sigma); 
        [~,indPeak] = max(PSTH(indElig)); 
        if length(find((PSTH(indElig)-mu)>p.Nsigma*sigma))>0 & Result.KS<.1 % if KS stat is reliable, and there is a peak 3sigma above mean
            switch p.latMethod
                case 'thresCrossing'
                    Result.latency = bins(indElig(thresCrossings(1))); % latency of first thres crossing
                case 'peakTime'
                    Result.latency = bins(indElig(indPeak)); % latency of peak
            end
            Result.reliable = 1; 
        else % unreliable
            Result.latency = 0; 
            Result.reliable = 0; 
        end
    case 'fourRasters'
        figure(p.figNum); 
        p.alignTo = 'onset'; 

        p.sortBy = 'syldur'; 
        p.panel = 1; 
        analyzeRow(row, p, 'PSTH');

        p.sortBy = 'gapdur'; 
        p.panel = 2; 
        analyzeRow(row, p, 'PSTH');

        p.alignTo = 'offset'; 

        p.sortBy = 'syldur'; 
        p.panel = 3; 
        analyzeRow(row, p, 'PSTH');

        p.sortBy = 'gapdur'; 
        p.panel = 4; 
        analyzeRow(row, p, 'PSTH');
        
        % if there's an example file
        try
            tmp = XLS.textdata.Sheet1(row,strmatch('ExampleSinging [fileNum tstart tstop]', Columns));
            ExampleFile = eval(tmp{1}); 

            % extract the sound trace
            [song fs dateandtime label props]  = egl_AA_daq(fullfile(pathname,dbase.SoundFiles(ExampleFile(1)).name),1);
            song = song(round(fs*ExampleFile(2)):round(fs*ExampleFile(3)));
            % extract the neural trace
            [units fs dateandtime label props]  = egl_AA_daq(fullfile(pathname, dbase.ChannelFiles{chanNum}(ExampleFile(1)).name),1);
            units = units(round(fs*ExampleFile(2)):round(fs*ExampleFile(3)));
            % plot them
            hh = subplot('position', [.1 .85 .8 .1]);
            [S,Time,F] = spectrogramELM(song,fs,.005,1); 
            gg = subplot('position', [.1 .7 .8 .1]); plot((1:length(units))/fs, egf_HanningHighPass(units, fs, egf_HanningHighPass('params')), 'k'); 
            axis tight; box off; set(gca, 'ytick', 0, 'color','none','tickdir','out','ticklength',[0.025 0.025]); 
            linkaxes([hh,gg],'x')
            subplot(hh);  axis off; title(p.rowstr, 'FontSize', p.fontsize, 'interpreter', 'none')
        catch exception
            exception
        end

        
    case 'forANOVA'
        [PSTH plotX plotY allDur]  = PSTH_elm(dbase, p);
        bins = p.rasterRange(1):p.psthdt:p.rasterRange(2); 
        nSyls = max(plotY(1,:));
        for syli = 1:nSyls
            cnt(syli) = sum(plotY(1,:)==syli); % how many times did it spike during this syllable
        end
        Result = cnt;
end