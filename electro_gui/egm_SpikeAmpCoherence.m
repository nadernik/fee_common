function handles = egm_SpikeAmpCoherence(handles)
% ELM
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
FS = 8; % labels 
FS_axes = 8; % axis labels
%h = subplot(2,1,1)
fs = handles.fs;
lims = get(handles.axes_Sonogram, 'xlim');
if lims(1) < 1/fs;
    lims(1) = 1/fs;
end
if lims(2)*fs > numel(handles.sound)
    lims(2) = numel(handles.sound)/fs
end
ind_time = lims(1):1/fs:lims(2);
song = handles.sound(round(ind_time*fs));
units = handles.chan1(round(ind_time*fs));
time = 0:1/fs:(lims(2)-lims(1));
SegmentTimes = handles.dbase.SegmentTimes{filenum}/handles.fs-lims(1); 
SelectedSyls = handles.dbase.SegmentIsSelected{filenum}; 
SegmentNames = handles.dbase.SegmentTitles{filenum}; 

for si = 1:size(SegmentTimes,1)
    if length(SegmentNames{si})==0
        SegmentNames{si} = ''; 
    end
    if SegmentTimes(si,1) < 0 | SegmentTimes(si,2)>diff(lims)
        SelectedSyls(si) = 0; 
    end
end
%%
specDT = .001; makePlot = 0; 
[S,Time1,F] = spectrogramELM(song,fs,specDT, makePlot); 
SoundAmplitude = amplitudeELM(S,F); 

% figure out which spike events to use
for ei = 1:length(handles.EventSources)
    str{ei} = [handles.EventSources{ei} '_' handles.EventFunctions{ei} '_' handles.EventDetectors{ei}]; 
end
[seventnum,v] = listdlg('PromptString','Select spike events',...
                'SelectionMode','single',...
                'ListString',str)
% Spikes = handles.dbase.EventTimes{1,seventnum}{1,filenum}/fs; % spike times
% Spikes = Spikes(handles.dbase.EventIsSelected{1,seventnum}{1,filenum}==1);
% 
% % parameters for cohgram
% params.Fs = 1/specDT;
% params.fpass = [1 50]; % hd 0 to 50
% winstep =.01; % some overlap makes it look nice
% winsize = (2/params.fpass(1)); % big enough to resolve lowest freq in fpass, bigger to allow more tapers
% Time = (winstep:winstep:(length(song)/fs))-winstep; 
% T = winsize; 
% W = 4*(1/params.fpass(1)); %.025; % frequency bandwidth... sacrefice bandwidth for tapers
% K = round(2*T*W-1); %number of tapers, must be <= 2TW-1
% params.tapers = [T*W K];
% movingwin = [winsize winstep]; 
% params.err = 0; % not calculating error bars
% 
% [C,phi,S12,S1,S2,t,f]=cohgramcpt(SoundAmplitude',Spikes,movingwin,params);
% 
% % determining tapers for raw coherence
% params.Fs = 1/specDT;
% params.fpass = [2 50]; % hd 0 to 50
% winstep =.01; % some overlap makes it look nice
% Time = (winstep:winstep:(length(song)/fs))-winstep; 
% T = length(SoundAmplitude)/params.Fs;
% W = 2*(1/params.fpass(1)); %.025; % frequency bandwidth... sacrefice bandwidth for tapers
% K = round(2*T*W-1); %number of tapers, must be <= 2TW-1
% params.tapers = [T*W K];
% pval = .1; % for calculating error bars
% params.err = [2 pval]; %- Jackknife error bars 
% [C1,phi1,S121,S11,S21,f1,confC,phistd,Cerr]=coherencycpt(SoundAmplitude',Spikes,params);
% 
% figure(2); clf; set(gcf, 'color', [1 1 1])
% kk = subplot(2,4,1)
% Cerr = Cerr(:); f1 = f1(:); C1 = C1(:);
% errPy = [f1; f1(end:-1:1)]; 
% errPx = [(C1 + Cerr); (C1(end:-1:1) - Cerr(end:-1:1))];
% patch(errPx, errPy, [.8 .8 .8],'LineStyle', 'none');
% hold on; plot(C1, f1, 'color', 'k');%[1 1 1]);
% xlim([0 1])
% % set(gca, 'xtick', -1:.2:0, 'xticklabel', {'1', '.8', '.6', '.4', '.2', '0'})
% set(gca, 'xdir', 'reverse')
% xlabel('Coherence')
% ylabel('Frequency (Hz)')
% hh = subplot(2,4,2:4)
% tmp = suptitle([handles.path_name ' #' num2str(filenum)])
% set(tmp, 'fontsize', FS);
% showthis = real(C)';
% tmp = imagesc(showthis, 'ydata', f, 'xdata', t);
% % axis tight
% % ylabel('Frequency (Hz)'); 
% % tmp = imagesc(showthis, 'ydata', f, 'xdata', t, max(abs(showthis(:)))*[-1 1]); % symetric clims if doing phase
% % cmap = [[zeros(64,1) (64:-1:1)'/64 (64:-1:1)'/64]; ...
% %     [(1:64)'/64 zeros(64,1) (1:64)'/64]]; 
% % 
% % cmap = [[ones(64,1) (64:-1:1)'/64 (1:64)'/64]; ...
% %     [(64:-1:1)'/64 (1:64)'/64 ones(64,1)];...
% %     [ (1:64)'/64 ones(64,1) (64:-1:1)'/64]];
% 
% colormap(hot)
% set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
% set(gca,'fontsize',FS_axes);box off; axis tight; 
% set(gca, 'ydir', 'normal')
% % set(gca, 'ydir', 'normal')
% 
% gg = subplot(2,4,6:8); hold on
% 
% ifr = 0*Time1; 
% tmp = 1./diff(Spikes); 
% for i = 1:length(Spikes)-1
%     ifr(round(Spikes(i)/specDT):round(Spikes(i+1)/specDT)) = tmp(i); 
% end
% plot(Time1,ifr, 'r'); 
% plot(Time1, SoundAmplitude*max(ifr)/max(SoundAmplitude)-max(ifr), 'k'); 
% ylabel('Firing Rate (Hz) \newline Amplitude (au)'); xlabel('Time (s)'); 
% set(gca, 'ytick', [0:round(max(ifr/5)/25)*25:max(ifr)]); 
% linkaxes([hh gg] , 'x')
% linkaxes([kk hh] , 'y')
% set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
% set(gca,'fontsize',FS_axes)
% shg
% 
% 
% %% in order to make no space between plots
% ShrinkBy = 4; 
% p = get(hh, 'pos');
% q = get(gg, 'pos');
% m = mean([p(2) q(2)+q(4)])
% gap = p(2) - (q(2)+q(4));
% p(2) = m + gap/(2*ShrinkBy);
% q(4) = m-q(2)-  gap/(2*ShrinkBy);
% set(hh, 'pos', p)
% set(gg, 'pos', q)
% %%
% 
% set(gcf, 'Color', [1 1 1], 'papersize', 2*[4 2], 'paperposition', 2*[0 0 4 2]); 
% %print fig -dmeta -r300

%% Onset-aligned coherence
% compile data: 
window = [-2 2]; % window to include around each syllable
% ask which files to include
files = inputdlg('Which files?', 'File #s for onset-aligned coherence', 1, {num2str(filenum)}); files = eval(files{1}); 

AMPL = zeros(diff(window)/specDT,0); % sound ampl nTimebins x nSyllables
SPIK = cell(1,0); % spike times rel to each syl onset
IFR = zeros(diff(window)/specDT,0); % instantaneous firing rate

for filei = 1:length(files) % for each file
    file = files(filei); 
    
    % load the song
    [song fs dt label props] = eval(['egl_' handles.sound_loader ...
        '([''' handles.path_name filesep handles.sound_files(file).name '''],1)']);
%     [chan fsA dt label props] = eval(['egl_' handles.egh.chan_loader{indxA} ...
%         '([''' handles.path_name filesep handles.chan_files{indxA}(file).name '''],1)']);
    
    % calculate the ampl trace
    specDT = .001; makePlot = 0; 
    [S,Time1,F] = spectrogramELM(song,fs,specDT, makePlot); 
    SoundAmplitude = amplitudeELM(S,F); 
    
    % get the spikes
    Spikes = handles.dbase.EventTimes{1,seventnum}{1,file}/fs; % spike times
    Spikes = Spikes(handles.dbase.EventIsSelected{1,seventnum}{1,file}==1);
    
    ifr = 0*Time1; 
    tmp = 1./diff(Spikes); 
    for i = 1:length(Spikes)-1
        ifr(round(Spikes(i)/specDT):round(Spikes(i+1)/specDT)) = tmp(i); 
    end
    
    % get the syllables
    segs = handles.SegmentTimes{file};
    if length(segs)>0
        indAwayFromEdge = find(((segs(:,1)+fs*window(1))>0)&((segs(:,2)+fs*window(2))<length(song))); 
        segs = segs(indAwayFromEdge,:); % only keep syllables away from file edge, so have whole window
    end
    for syli = 1:size(segs,1) % 1:min(1,size(segs,1)); %maybe just align to first syl in bout
        % add a row to AMPL with onset-aligned ampl trace
        winAmp = SoundAmplitude(round(segs(syli)/specDT/fs+window(1)/specDT):...
            round(segs(syli)/specDT/fs+window(2)/specDT));
        AMPL = [AMPL; winAmp]; 
        
        % add an entry to SPIK with onset-aligned spike times
        winSpk = Spikes(Spikes>(segs(syli)/fs+window(1)) & Spikes<(segs(syli)/fs+window(2))); 
        SPIK{end+1} = winSpk; 
        
        % add row to IFR with onset-aligned ifr trace
        winIfr = ifr(round(segs(syli)/specDT/fs+window(1)/specDT):...
            round(segs(syli)/specDT/fs+window(2)/specDT));
        IFR = [IFR; winIfr]; 
    end
end

% plot onset-aligned coherence
% plot onset-aligned cohgram
% plot onset-aligned average ifr & aver ampl trace
%%
% parameters for cohgram
params.Fs = 1/specDT;
params.fpass = [3 50]; % hd 0 to 50
winstep =.01; % some overlap makes it look nice
winsize = (2/params.fpass(1)); % big enough to resolve lowest freq in fpass, bigger to allow more tapers
Time = (winstep:winstep:(length(song)/fs))-winstep; 
T = winsize; 
W = 4*(1/params.fpass(1)); %.025; % frequency bandwidth... sacrefice bandwidth for tapers
K = round(2*T*W-1); %number of tapers, must be <= 2TW-1
params.tapers = [T*W K];
movingwin = [winsize winstep]; 
params.err = 0; % not calculating error bars
params.trialave = 1; 
structSPIK = cell2struct(SPIK, 'times', 1); 
[C,phi,S12,S1,S2,t,f]=cohgramcpt(AMPL',structSPIK,movingwin,params);
%
% determining tapers for raw coherence
params.Fs = 1/specDT;
params.fpass = [2 50]; % hd 0 to 50
winstep =.01; % some overlap makes it look nice
Time = (winstep:winstep:(length(song)/fs))-winstep; 
T = length(SoundAmplitude)/params.Fs;
W = 2*(1/params.fpass(1)); %.025; % frequency bandwidth... sacrefice bandwidth for tapers
K = round(2*T*W-1); %number of tapers, must be <= 2TW-1
params.tapers = [T*W K];
pval = .1; % for calculating error bars
params.err = [2 pval]; %- Jackknife error bars 
params.trialave = 1; 
[C1,phi1,S121,S11,S21,f1,confC,phistd,Cerr]=coherencycpt(AMPL',structSPIK,params);

figure(2); clf; set(gcf, 'color', [1 1 1])
kk = subplot(3,4,1)
Cerr = Cerr(:); f1 = f1(:); C1 = C1(:);
errPy = [f1; f1(end:-1:1)]; 
errPx = [(C1 + Cerr); (C1(end:-1:1) - Cerr(end:-1:1))];
patch(errPx, errPy, [.8 .8 .8],'LineStyle', 'none');
hold on; plot(C1, f1, 'color', 'k');%[1 1 1]);
xlim([0 1])
% set(gca, 'xtick', -1:.2:0, 'xticklabel', {'1', '.8', '.6', '.4', '.2', '0'})
set(gca, 'xdir', 'reverse')
xlabel('Coherence')
ylabel('Frequency (Hz)')
hh = subplot(3,4,2:4)
tmp = suptitle([handles.path_name ' #' num2str(filenum)])
set(tmp, 'fontsize', FS);
showthis = real(C)';
tmp = imagesc(showthis, 'ydata', f, 'xdata', t+window(1));
% axis tight
% ylabel('Frequency (Hz)'); 
% tmp = imagesc(showthis, 'ydata', f, 'xdata', t, max(abs(showthis(:)))*[-1 1]); % symetric clims if doing phase
% cmap = [[zeros(64,1) (64:-1:1)'/64 (64:-1:1)'/64]; ...
%     [(1:64)'/64 zeros(64,1) (1:64)'/64]]; 
% 
% cmap = [[ones(64,1) (64:-1:1)'/64 (1:64)'/64]; ...
%     [(64:-1:1)'/64 (1:64)'/64 ones(64,1)];...
%     [ (1:64)'/64 ones(64,1) (64:-1:1)'/64]];

colormap(hot)
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
set(gca,'fontsize',FS_axes);box off; axis tight; 
set(gca, 'ydir', 'normal')
% set(gca, 'ydir', 'normal')

gg = subplot(3,4,6:8); hold on

errorpatch_asym(window(1):specDT:window(2), prctile(IFR, 50), ...
    prctile(IFR,25), prctile(IFR,75)); 
ylabel('Firing Rate (Hz)');
ll = subplot(3,4,10:12); hold on
errorpatch_asym(window(1):specDT:window(2), prctile(AMPL, 50), ...
    prctile(AMPL,25), prctile(AMPL,75)); 
ylabel('Sound Amplitude (au)'); xlabel('Time (s)'); 
set(gca, 'ytick', [0:round(max(ifr/5)/25)*25:max(ifr)]); 
linkaxes([ll hh gg] , 'x')
linkaxes([kk hh] , 'y')
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
set(gca,'fontsize',FS_axes)
shg


%% in order to make no space between plots
ShrinkBy = 4; 
p = get(hh, 'pos');
q = get(gg, 'pos');
m = mean([p(2) q(2)+q(4)])
gap = p(2) - (q(2)+q(4));
p(2) = m + gap/(2*ShrinkBy);
q(4) = m-q(2)-  gap/(2*ShrinkBy);
set(hh, 'pos', p)
set(gg, 'pos', q)
%%

set(gcf, 'Color', [1 1 1], 'papersize', 2*[4 2], 'paperposition', 2*[0 0 4 2]); 
