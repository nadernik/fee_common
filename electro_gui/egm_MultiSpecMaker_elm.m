function handles = egm_MultiSpecMaker_elm(handles)
shg;
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
SIGNALS.song = handles.sound(round(ind_time*fs));

if ~issame(getSelectedString(handles.popup_Channel1), '(None)')
    SIGNALS.top_plot = handles.chan1(round(ind_time*fs));
    SIGNALS.top_plot = SIGNALS.top_plot(:);
end
if ~issame(getSelectedString(handles.popup_Channel2), '(None)')
    SIGNALS.bottom_plot = handles.chan2(round(ind_time*fs));
    SIGNALS.bottom_plot = SIGNALS.bottom_plot(:);
end
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

% get spike events
for ei = 1:length(handles.EventSources)
    % get the event times
    Spikes = handles.dbase.EventTimes{1,ei}{1,filenum};
    Spikes = Spikes(handles.dbase.EventIsSelected{1,ei}{1,filenum}==1);
    spiketrain = 0*time; 
    spiketrain(Spikes) = 1; 
    stringname = [handles.EventSources{ei} '_' handles.EventFunctions{ei} '_' handles.EventDetectors{ei}];
    stringname(ismember(stringname,' ,.:;!()')) = [];
    SIGNALS.(stringname) ...
        = spiketrain(:); 
end
% [seventnum,v] = listdlg('PromptString','Select spike events',...
%                 'SelectionMode','single',...
%                 'ListString',str)
%% dropdown to choose the first channel and second channel (from spike amp coherence)

prompts = fieldnames(SIGNALS)

[Selection1,ok] = listdlg('PromptString','Select a channel from the list',...
                'SelectionMode','single',...
                'ListString', prompts,...
                'InitialValue', 2);
if ~ok
    error('clicked cancel')
end

[Selection2,ok] = listdlg('PromptString','Select a (different) channel from the list',...
                'SelectionMode','single',...
                'ListString', prompts,...
                'InitialValue', 3);
if ~ok
    error('clicked cancel')
end

Signal1 = SIGNALS.(prompts{Selection1}); 
Signal2 = SIGNALS.(prompts{Selection2}); 

%% set defaults, option to choose params (from cohegram/spike spectrum)
% parameters for cohgram
answer = inputdlg({'[T=winsize winstep]', '[minfreq maxfreq]', 'W=bandwidth', '# Tapers (<=2TW-1)'},'in seconds...',1,{'[1.5 .02]', '[2 50]', '3', '8'}); % input dialog box
if isempty(answer)
    return
end

movingwin = str2num(answer{1});
fpass = str2num(answer{2});
W = str2num(answer{3}); % frequency bandwidth... sacrefice bandwidth for tapers
K = str2num(answer{4}); %number of tapers, must be <= 2TW-1
winsize = movingwin(1); 
winstep = movingwin(2); 
params.Fs = fs;
params.fpass = fpass; % hd 0 to 50
T = movingwin(1); 
params.tapers = [T*W K];
params.err = 0; % not calculating error bars
params.trialave = 0; 
%% compute cohegram (see spike amp coherence)
% for now, cohegramc. Maybe cohegramcpt. 
% structSPIK = cell2struct(SPIK, 'times', 1); 

[C,phi,S12,S1,S2,t,f]=cohgramc(Signal1-mean(Signal1),Signal2-mean(Signal2),movingwin,params);
% imagesc(S2', 'xdata', t, 'ydata', f);shg
%% choose what to plot
AskToPlot = {'Song Spectrogram', 'Signal1', 'Signal2', 'top plot', 'bottom plot', 'Spectrum1', 'Spectrum2', 'CrossSpectrum', 'Cohegram'}
[PlotThese,ok] = listdlg('PromptString','Select what to display',...
                'SelectionMode','multiple',...
                'ListString', AskToPlot, ...
                'InitialValue', [1 2 3 6 7 8 9]);
%% plot them each
nSubplots = length(PlotThese)
figure(8); clf
%         tdata = get(temp, 'xdata'); tdata = time; 
%         tmp = suptitle([handles.path_name ' #' num2str(filenum)])
%         set(tmp, 'fontsize', FS);
thisPlot = 0; 
hh = []; 
for plotInd = PlotThese
    thisPlot = thisPlot+1; 
    hh(thisPlot) = subplot('Position', [.1 (.8 - .8*(thisPlot-1)/nSubplots) .7 .8/nSubplots]);
switch plotInd
    case 1 % Song Spectrogram
        % grab spectrogram data and plot it. 
        temp = get(handles.axes_Sonogram, 'Children'); 
        cdata = get(temp, 'Cdata');
        fdata = get(temp, 'ydata');
        tdata = get(temp, 'xdata'); tdata = tdata - min(tdata); 
        cdata(cdata<handles.SonogramClim(1)) = handles.SonogramClim(1); 
        cdata(cdata>handles.SonogramClim(2)) = handles.SonogramClim(2); 
        imagesc(cdata, 'xdata', tdata, 'ydata', fdata/1000); set(gca, 'ydir', 'normal', 'ytick', 2:2:6)
        ylabel('Freq (kHz)','fontsize',FS)
        set(gca, 'xtick', [], 'xticklabel', '');
        try 
            cmap = parula
        catch
            cmap = jet; 
        end
        cmap(1,:) = zeros(1,3); % background = black
        colormap(cmap);
        title([handles.path_name '_file#' num2str(filenum) '_T=' num2str(T) '_K=' num2str(K), '_W=' num2str(W)], 'fontsize', FS);
    case 2 % Signal 1
        plot(time,Signal1, 'k')
    case 3 % Signal 2
        plot(time,Signal2, 'k')
    case 4 % top plot
        if isfield(SIGNALS, 'top_plot')
            plot(time,SIGNALS.top_plot, 'k')
        end
    case 5 % bottom plot
        if isfield(SIGNALS, 'bottom_plot')
            plot(time,SIGNALS.bottom_plot, 'k')
        end
    case 6 % Spectrum 1
        toPlot = log(S1');
        imagesc(toPlot, 'xdata', t, 'ydata', f); ylabel('Freq (Hz)', 'fontsize', FS_axes)
    case 7 % Spectrum 2
        toPlot = log(S2'); 
        imagesc(toPlot, 'xdata', t, 'ydata', f); ylabel('Freq (Hz)', 'fontsize', FS_axes)
    case 8 % CrossSpectrum
        toPlot = log(abs(S12))';
        imagesc(toPlot, 'xdata', t, 'ydata', f); ylabel('Freq (Hz)', 'fontsize', FS_axes)
    case 9 % Cohegram
        toPlot = C';
        imagesc(toPlot, 'xdata', t, 'ydata', f); ylabel('Freq (Hz)', 'fontsize', FS_axes)
end
if plotInd ~= PlotThese(end)
    set(gca, 'xtick', [], 'xticklabel', '');
else
    xlabel('Time (s)', 'fontsize', FS_axes)
end
set(gca, 'ydir', 'normal')
axis tight
tmpx = xlim; tmpy = ylim; 
text(tmpx(1),tmpy(2),{AskToPlot{plotInd}}, 'horizontalalignment', 'left', ...
    'verticalalignment', 'top' , 'fontsize', FS_axes)
if ismember(plotInd,[6 7 8 9])
    gg(thisPlot) = subplot('Position', [.8 (.8 - .8*(thisPlot-1)/nSubplots) .1 .8/nSubplots]);
    plot(mean(toPlot,2),f, 'k');
    if plotInd == 9
        set(gca,'ytick', [])
        xlim([0 max(mean(toPlot,2))*1.1])
    else
        set(gca, 'xtick', [], 'ytick', [])
    end
end
end
linkaxes(hh,'x')
linkaxes(gg, 'y')