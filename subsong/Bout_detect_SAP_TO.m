function Bout_detect_SAP_TO(pathName)
%%% divide SAP wave files into bout files
%%% originally written by Dmitiriy Aronov
%%% Tatsuo Okubo
%%% 2011/01/29

if nargin<1 % input argument empty
    pathName = uigetdir('C:\SAP\', 'Choose the directory that contains songs');
end

cd(pathName)
dbase.ChannelFiles =[];


if isempty(dir([pathName filesep 'analysis.mat']))
    if isempty(dir([pathName filesep 'bouts']))
        mkdir([pathName filesep 'bouts']);
    end
    
    dbase = [];
    dbase.PathName = [pathName];
    
    s_files = dir([pathName,filesep,'*.wav']);
    dbase.Fs = 44100;
    dbase.SoundLoader = 'WaveRead';
    
    if ~isempty(s_files)
        dbase.EventSources = {};
        dbase.EventFunctions = {};
        dbase.EventDetectors = {};
        dbase.EventThresholds = zeros(0,length(s_files));
        dbase.EventTimes = {};
        dbase.EventIsSelected = {};
        
        for fl = 1:length(s_files)
            dbase.Properties.Names{fl} = {};
            dbase.Properties.Values{fl} = {};
            dbase.Properties.Types{fl} = {};
        end
        
        dbase.SoundFiles = s_files;
        
        dbase.AnalysisState.SourceList = {'(None)','Sound'}';
        dbase.AnalysisState.EventList = {'(None)',};
        dbase.AnalysisState.CurrentFile = 0;
        dbase.AnalysisState.EventWhichPlot = [0];
        dbase.AnalysisState.EventLims = repmat([1.000000000000000e-003 0.00300000000000],1,1);
        dbase.FileLength = zeros(1,length(s_files));
        dbase.Times = zeros(1,length(s_files));
        
        fig = figure;
        subplot('position',[.05 0.35 0.9 0.6]);
        text(0,3,[pathName],'fontsize',14,'interpreter','none','horizontalalignment','center');
        hold on
        filesanalyzed = text(0,2,['Files analyzed: 0 of ' num2str(length(s_files))],'fontsize',14,'interpreter','none','horizontalalignment','center');
        progbar = imagesc([-1 1],[.4 .6],zeros(1,length(s_files)));
        timeelapsed = text(0,-1,'Time elapsed: 0 sec','fontsize',14,'interpreter','none','horizontalalignment','center');
        boutssaved = text(0,-2,'Bouts saved: 0','fontsize',14,'interpreter','none','horizontalalignment','center');
        xlim([-1 1])
        ylim([-3 3]);
        axis off
        drawnow
        starttime = now;
        
        temp.files = [];
        temp.bouts = zeros(0,2);
        temp.syll = {};
        temp.titl = {};
        temp.sel = {};
        temp.time = [];
        temp.len = [];
        temp.ev = {};
        
        if ~isempty(dir([pathName filesep 'analysis_incomplete.mat']))
            load([pathName filesep 'analysis_incomplete.mat']);
        end
        
        for fl = dbase.AnalysisState.CurrentFile+1:length(s_files)
            dbase.AnalysisState.CurrentFile = fl;
            mt = dir([dbase.PathName '\bouts\extr' num2str(fl,'%05.f') '_*']);
            wg = dir([dbase.PathName '\bouts\pres' num2str(fl,'%05.f') '_*']);
            for i = 1:length(mt)
                delete([dbase.PathName '\bouts\' mt(i).name]);
                delete([dbase.PathName '\bouts\' wg(i).name]);
            end
            
            % CHANGE HERE FOR WAVE FILES
            
            try
                [a, fs] = wavread(s_files(fl).name);%[a fs] = wavread([fold(bird).name filesep days(dy).name filesep files(fl).name]);
                dbase.FileLength(fl) = length(a);
                dbase.Times(fl) = s_files(fl).datenum;
                dateandtime= s_files(fl).datenum;
            catch
                disp('fail');
                a = [];
            end
            
            if ~isempty(a)                
                % Remove clicks
                f = find(a==0);
                a(f) = randn(size(f))*std(a);
                f = 1;
                while ~isempty(f)
                    df = [0; diff(diff(a)); 0];
                    f = find(abs(df)>0.01);
                    a(f) = (a(f-1)+a(f+1))/2;
                end
                
                % Segment
                % [snd] = BandPass860to8600forBoutDet(a,fs);
                b = fir1(200,[1000 4000]/(fs/2));
                snd = filtfilt(b, 1, a);
                smooth_window = 0.0025;
                wind = round(smooth_window*fs);
                amp = smooth(10*log10(snd.^2+eps),wind);
                amp = amp-prctile(amp(wind:length(amp)-wind),5);
                amp(find(amp<0))=0;
                th = eg_AutoThreshold(amp);
                %if there is need to change the threshold from the auto
                %one
                %%th=5;
                params.Values = {'7', '7','7','0'};
                params.IsSplit = 0;
                segs = DA_segmenter(amp,fs,th,params);
                sel = select_bouts(a,fs,amp,th,segs);
                dbase.SegmentThresholds(fl) = th;
                dbase.SegmentTimes{fl} = segs;
                dbase.SegmentTitles{fl} = cell(1,size(segs,1));
                dbase.SegmentIsSelected{fl} = sel;
                
                syll = segs(find(sel==1),:);
                if ~isempty(syll)
                    intr = find(syll(2:end,1)-syll(1:end-1,2)>.5*fs);
                    ons = [1; intr+1];
                    offs = [intr; size(syll,1)];
                    for c = 1:length(ons)
                        temp.files(end+1) = fl;
                        temp.bouts(end+1,:) = [max(1,round(syll(ons(c),1)-.7*fs)) min(length(a),round(syll(offs(c),2)+.7*fs))];
                        f = find(segs(:,1)>temp.bouts(end,1) & segs(:,2)<temp.bouts(end,2));
                        temp.syll{end+1} = segs(f,:)-temp.bouts(end,1);
                        temp.titl{end+1} = cell(1,size(segs,1));
                        temp.sel{end+1} = sel(f);
                        
                        rec.Fs = fs;
                        rec.Data = a(temp.bouts(end,1):temp.bouts(end,2));
                        rec.Time = dateandtime + temp.bouts(end,1)/fs/(24*60*60);
                        temp.time(end+1) = rec.Time;
                        temp.len(end+1) = length(rec.Data);
                        
                        param.Values = {'7','7','0'};
                        temp.ev{end+1} = zeros(0,2);
                        
                        rec.Properties.Names = {};
                        rec.Properties.Types = [];
                        rec.Properties.Values = {};
                        
                        prs.Fs = fs;
                        prs.Time = dateandtime + temp.bouts(end,1)/fs/(24*60*60);
                        prs.Properties.Names = {};
                        prs.Properties.Types = [];
                        prs.Properties.Values = {};
                        
                        iss = 0;
                        while iss==0
                            try
                                save([dbase.PathName '\bouts\extr' num2str(fl,'%05.f') '_' num2str(c,'%03.f') '.mat'],'rec');
                                iss = 1;
                            catch
                                disp('fail');
                                pause(1);
                            end
                        end
                        
                        figure(fig);
                        subplot('position',[.05 0.05 0.9 0.3]);
                        ylim([1000 7000]);
                        [p f t] = quick_spectrogram(gca,rec.Data,rec.Fs);
                        imagesc(t,f,p);
                        set(gca,'ydir','normal');
                        axis tight
                        axis off
                        set(gca,'clim',[prctile(p(1:prod(size(p))),50) prctile(p(1:prod(size(p))),95)*1.2]);
                        drawnow
                    end
                end
                
                iss = 0;
                while iss==0
                    try
                        save([pathName filesep 'analysis_incomplete.mat'],'dbase','temp');
                        iss = 1;
                    catch
                        disp('fail');
                        pause(1);
                    end
                end
                
                set(filesanalyzed,'string',['Files analyzed: ' num2str(fl) ' of ' num2str(length(s_files))]);
                set(progbar,'cdata',[ones(1,fl) zeros(1,length(s_files)-fl)]);
                set(timeelapsed,'string',['Time elapsed: ' num2str((now-starttime)*(24*60*60)) ' sec']);
                set(boutssaved,'string',['Bouts saved: ' num2str(length(temp.files))]);
                drawnow
            end
        end
        
        dbase.AnalysisState.CurrentFile = 1;
        iss = 0;
        while iss==0
            try
                save([pathName filesep 'analysis_bout.mat'],'dbase');
                delete([pathName filesep 'analysis_incomplete.mat']);
                iss = 1;
            catch
                disp('fail');
                pause(1);
            end
        end
        
        
        % Bouts dbase
        thres = dbase.SegmentThresholds;
        
        dbase = [];
        dbase.PathName = [pathName filesep 'bouts'];
        dbase.Times = temp.time;
        dbase.FileLength = temp.len;
        dbase.SoundFiles = dir([dbase.PathName filesep 'extr*.mat']);
        dbase.ChannelFiles = {dir([dbase.PathName filesep 'pres*.mat'])};
        dbase.SoundLoader = 'Surgery_Rig_daq';
        dbase.ChannelLoader = {'Surgery_Rig_daq_pres'};
        dbase.Fs = fs;
        dbase.SegmentThresholds = thres(temp.files);
        dbase.SegmentTimes = temp.syll;
        dbase.SegmentTitles = temp.titl;
        
        for jj = 1:length(temp.sel)
            temp.sel{jj}(1:end) = 1;
        end
        dbase.SegmentIsSelected = temp.sel;
        
        dbase.EventSources = {'Sound'};
        dbase.EventFunctions = {'Extract_inspirations'};
        dbase.EventDetectors = {'ThresholdCrossings'};
        dbase.EventThresholds = 0.1*ones(1,length(dbase.Times));
        
        param.Values = {'7','7','0'};
        for fl = 1:length(temp.files)
            ev = temp.ev{fl};
            dbase.EventTimes{1}{1,fl} = ev(:,1)';
            dbase.EventIsSelected{1}{1,fl} = ones(size(ev(:,1)));
            dbase.EventTimes{1}{2,fl} = ev(:,2)';
            dbase.EventIsSelected{1}{2,fl} = ones(size(ev(:,2)));
        end
        
        for fl = 1:length(temp.files)
            dbase.Properties.Names{fl} = {};
            dbase.Properties.Values{fl} = {};
            dbase.Properties.Types{fl} = {};
        end
        
        dbase.AnalysisState.SourceList = {'(None)','Sound','Channel 1', 'Sound - Extract_inspirations - Zenith','Sound - Extract_inspirations - Nadir'}';
        dbase.AnalysisState.EventList = {'(None)','Sound - Extract_inspirations - Zenith','Sound - Extract_inspirations - Nadir'};
        dbase.AnalysisState.CurrentFile = 1;
        dbase.AnalysisState.EventWhichPlot = [0 0 0];
        dbase.AnalysisState.EventLims = repmat([1.000000000000000e-003 0.00300000000000],3,1);
        
        iss = 0;
        while iss==0
            try
                save([pathName filesep 'bouts' filesep 'analysis.mat'],'dbase');
                iss = 1;
            catch
                disp('fail');
                pause(1);
            end
        end
    end
    % end
end

function sel = select_bouts(a,fs,ampl,thres,segs)

seg = segs/fs*1000;
sel = zeros(1,size(seg,1));
if size(seg,1)<2
    return
end

dur = seg(:,2)-seg(:,1);

wind = round(0.001*fs);
b = fir1(200,[1000 10000]/(fs/2));
snd = filtfilt(b, 1, a);
snd = 10*log10(smooth(snd.^2,wind));
mn = median(abs(diff(snd(1:wind:end))));
gd = sel;
loud = sel;
for c = 1:size(seg,1)
    amp = snd(segs(c,1):segs(c,2));
    loud(c) = median(amp);
    df = diff(amp(1:wind:end));
    df = abs(df)/mn;
    if mean(df)/dur(c)<.075
        gd(c) = 1;
    end
end
f = find(diff(diff(loud))<-40)+1;
gd(f) = 0;

pause = zeros(size(seg,1),1);
f = find(gd==1);
ps = seg(f(2:end),1)-seg(f(1:end-1),2);
if ~isempty(ps)
    ps = min([[ps(1); ps] [ps; ps(end)]],[],2);
    pause(f) = ps;
    
    f = find(dur./(pause+eps)>.20 & gd'==1);
    
    if ~isempty(f)
        intr = find(seg(f(2:end),1)-seg(f(1:end-1),2)>500);
        ons = [1; intr+1];
        offs = [intr; length(f)];
    else
        ons = [];
        offs = [];
    end
    
    for c = 1:length(ons)
        numsyll = offs(c)-ons(c)+1;
        boutlength = seg(f(offs(c)),2)-seg(f(ons(c)),1);
        sylldur = sum(seg(f(ons(c):offs(c)),2)-seg(f(ons(c):offs(c)),1));
        if numsyll>2 & boutlength>300 & sylldur/boutlength>.3 ...
                & prctile(ampl(round(segs(f(ons(c)),1)):round(segs(f(offs(c)),2))),90)>15
            sel(f(ons(c)):f(offs(c))) = 1;
        end
    end
    
    sel(find(gd==0)) = 0;
end

function threshold = eg_AutoThreshold(amp)

if mean(amp)<0
    amp = -amp;
    isneg=1;
else
    isneg=0;
end
if range(amp)==0
    threshold = inf;
    return;
end

try
    % Code from Aaron Andalman
    [noiseEst, soundEst, noiseStd, soundStd] = eg_estimateTwoMeans(amp);
    if(noiseEst>soundEst)
        disc = max(amp)+eps;
    else
        %Compute the optimal classifier between the two gaussians...
        p(1) = 1/(2*soundStd^2+eps) - 1/(2*noiseStd^2);
        p(2) = (noiseEst)/(noiseStd^2) - (soundEst)/(soundStd^2+eps);
        p(3) = (soundEst^2)/(2*soundStd^2+eps) - (noiseEst^2)/(2*noiseStd^2) + log(soundStd/noiseStd+eps);
        disc = roots(p);
        disc = disc(find(disc>noiseEst & disc<soundEst));
        if(length(disc)==0)
            disc = max(amp)+eps;
        else
            disc = disc(1);
            %if u want to change the detection change the 0.5 to
            %the original code was: disc = soundEst - 0.5 * (soundEst - disc);
            disc = soundEst - 0.5 * (soundEst - disc);
        end
    end
    threshold = disc;
    
    if ~isreal(threshold)
        threshold = max(amp)*1.1;
    end
catch
    threshold = max(amp)*1.1;
end

if isneg
    threshold = -threshold;
end

% by Aaron Andalman
function [uNoise, uSound, sdNoise, sdSound] = eg_estimateTwoMeans(audioLogPow)

%Run EM algorithm on mixture of two gaussian model:

%set initial conditions
l = length(audioLogPow);
len = 1/l;
m = sort(audioLogPow);
uNoise = median(m(fix(1:length(m)/2)));
uSound = median(m(fix(length(m)/2:length(m))));
sdNoise = 5;
sdSound = 20;

%compute estimated log likelihood given these initial conditions...
prob = zeros(2,l);
prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
[estProb, class] = max(prob);
warning off
logEstLike = sum(log(estProb)) * len;
warning on
logOldEstLike = -Inf;

%maximize using Estimation Maximization
while(abs(logEstLike-logOldEstLike) > .005)
    logOldEstLike = logEstLike;
    
    %Which samples are noise and which are sound.
    nndx = find(class==1);
    sndx = find(class==2);
    
    %Maximize based on this classification.
    uNoise = mean(audioLogPow(nndx));
    sdNoise = std(audioLogPow(nndx));
    if ~isempty(sndx)
        uSound = mean(audioLogPow(sndx));
        sdSound = std(audioLogPow(sndx));
    else
        uSound = max(audioLogPow);
        sdSound = 0;
    end
    
    %Given new parameters, recompute log likelihood.
    prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2+eps)))./(sdNoise+eps);
    prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2+eps)))./(sdSound+eps)+eps;
    [estProb, class] = max(prob);
    logEstLike = sum(log(estProb+eps)) * len;
end

function segs = DA_segmenter(a,fs,th,params)
% ElectroGui segmenter

if isstr(a) & strcmp(a,'params')
    segs.Names = {'Minimum duration (ms)','Minimum interval (ms)','Mininum duration for splitting (ms)','Minimum interval for splitting (ms)'};
    segs.Values = {'7', '7','7','0'};
    return
end

min_dur = str2num(params.Values{1})/1000;
min_stop = str2num(params.Values{2})/1000;

if params.IsSplit == 1
    min_dur = str2num(params.Values{3})/1000;
    min_stop = str2num(params.Values{4})/1000;
end

if th < 0
    a = -a;
    th = -th;
end
th = th-min(a);
a = a-min(a);

% Find threshold crossing points
f = [];
a = [0; a; 0];
f(:,1) = find(a(1:end-1)<th & a(2:end)>=th)-1;
f(:,2) = find(a(1:end-1)>=th & a(2:end)<th)-1;
a = a(2:end-1);

% Eliminate VERY short syllables
i = find(f(:,2)-f(:,1)>min_dur/2*fs);
f = f(i,:);

% Extend syllables to a lower threshold
if params.IsSplit == 0
    warning off
    mn = mean(a(find(a<th)));
    st = std(a(find(a<th)));
    warning on
    %%% to get the syllable longer use lower threshold, the origenal code was: thnew = min([th mn+2*st]);
    thnew = min([th mn+2*st]);
    for c=1:size(f,1)
        f(c,1)=max([1; find(a(1:f(c,1)-1)<thnew)]);
        f(c,2)=min([length(a); f(c,2)+find(a(f(c,2)+1:end)<th/2)]);
    end
end

% Eliminate short syllables
i = find(f(:,2)-f(:,1)>min_dur*fs);
f = f(i,:);

if isempty(f)
    segs = zeros(0,2);
    return
end

% Eliminate short intervals
if size(f,1)>1
    i = [find(f(2:end,1)-f(1:end-1,2) > min_stop*fs); length(f)];
    f = [f([1; i(1:end-1)+1],1) f(i,2)];
end

segs = f;