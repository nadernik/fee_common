% also see Compilation6865 for notes on how to run things on openmind, rasters in labeled data, etc.
codepath = '\\feevault\shared\EmilyShijieShared\CNMF_E-master';
addpath(genpath(codepath))
%% check row movies

folder = 'G:\ProcessedCalciumData\6865_Jan9';%'\\feevault\data0\ProcessedCalciumData\AllRows\'; 
cnmfe_codepath = fullfile(sharedfolder, 'CNMF_E-master'); 
addpath(genpath(cnmfe_codepath)); 
for row = [2155]; %3244 3400 3330 4400 4399 4398 3740 3442 3289 3075]
    rowpath = [fullfile(folder, 'CaELM_row') num2str(row)];
    savepath = [fullfile(folder, 'Movie') num2str(row) '.avi']; 
    row2movie(rowpath, savepath);
end
%% decide what data to look at
foldername = '6938_FirstTutNewSyll'; 
DataFolder = fullfile('U:\ProcessedCalciumData\', foldername); 
cnmfeFilePath = fullfile('U:\ProcessedCalciumData\', foldername, 'cnmfe_results_cleaned.mat'); 
load(cnmfeFilePath, 'neuron'); 
clf; imagesc(neuron.C);shg
load(fullfile(DataFolder, 'compiled.mat'),  'SOUNDfs','VIDEOfs');
load(fullfile(DataFolder, 'analysis.mat')); 
AddGcampDataTimestamps(DataFolder);
%% play movie?
indSong = 1:250; 
% indSong = 133000:134000; 
indSeqSort = randperm(size(neuron.C,1)); 
tmp = neuron.C(indSeqSort,indSong); %medianFilter(neuron.C(:,indSong),.2*VIDEOfs);
tmp = tmp.*(tmp>0); 
Brainbow = neuron2brainbow(neuron.A(:,indSeqSort),tmp,.8*(1-hsv(size(neuron.C,1))));
SpecForMov = SpectrogramForMovie(DataFolder, indSong);
ToPlay = [[Brainbow; 0*SpecForMov+1] ToPlayRaw(:,:,:,1:250)]; 
implay(ToPlay,30);
%% save the video
obj = vision.VideoFileWriter('C:\Users\emackev\Downloads\BlinkingBrainbow1.avi', 'AudioInputPort', 1);%,  'fps', 20);
obj.FrameRate = VIDEOfs; 
for framei = 1:length(indSong)
    istart = floor(indSong(framei)*SOUNDfs/VIDEOfs); 
    Aud = CompSoundSONG(istart:(istart+floor(SOUNDfs/VIDEOfs)-1));
    step(obj, squeeze(ToPlay(:,:,:,framei)), Aud)
    display(framei)
end
release(obj)

%% make spectrogram if haven't already
variableInfo = who('-file', fullfile(DataFolder, 'compiled.mat'));
if ~ismember('SongSpec', variableInfo) 
    load(fullfile(DataFolder, 'compiled.mat'), 'CompSoundSONG', 'SOUNDfs')
    display('loaded song')
    tic; [SongSpec,SpecTime,SpecF] = spectrogramELM(CompSoundSONG,SOUNDfs,.005, 0); toc
    SongSpec = 10*log10(SongSpec); 
    display('computed spectrogram')
    save(fullfile(DataFolder, 'compiled.mat'), 'SongSpec', 'SpecTime', 'SpecF', ...
        '-append');
    display('saved spectrogram')
end
%% sort by correlation during singing

M = neuron.C;
nNeurons = size(neuron.C,1);
nColors = lines(nNeurons);
Corr = corr(M(:,indSong)'); 
Corr(isnan(Corr)) = 0; 
Z = linkage(Corr, 'weighted', 'correlation'); 
D = pdist(Corr);
leafOrder = optimalleaforder(Z,D, 'criteria', 'group');

figure(4); clf
h(1) = subplot(2,2,1); 
[dend,T,indSeqSort] = dendrogram(Z, size(M,1), 'Reorder',leafOrder,'Orientation','left'); 
hold on
scatter(0*ones(1,nNeurons),1:nNeurons, 'cdata', 1-nColors, 'marker', 's', 'markerfacecolor', 'flat')
xlabel('Distance (au)'); 
set(gca, 'ytick', [])

h(2) = subplot(2,2,2); 
imagesc(Corr(indSeqSort, indSeqSort)); %axis square
set(gca, 'ydir', 'normal')
linkaxes(h, 'y')
xlabel('Neuron #');ylabel('Neuron #')

subplot(2,2,3:4)
circleNeurons(cnmfeFilePath,indSeqSort, nColors);
papersize = [8 8];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
colormap(flipud(gray))
title(foldername, 'interpreter', 'none')
%% sort by autocorrelation 

M = neuron.C;
nNeurons = size(neuron.C,1);
nColors = lines(nNeurons);

load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs',...
        'SOUNDfs', 'CompSoundSONG', 'FnumBnum');
    

    
Corr = []; 
maxlag = 1*VIDEOfs;
window = ceil(.1*VIDEOfs); 
smallestlag = 2*window; 
MedM = medianFilter(M,window);
figure(1)
for ni = 1:nNeurons
    tmp = MedM(ni,indSong); % take out local median 
    [tmp1,lags] = xcorr(tmp, maxlag, 'coeff'); 
    Corr(ni,:) = tmp1((maxlag+smallestlag):end);
    lags = lags((maxlag+smallestlag):end)/VIDEOfs; 
    clf; 
%     plot(lags,Corr(ni,:), 'k.'); ylim([-.2 .4]); xlim([0 maxlag/VIDEOfs]); drawnow; pause(.1); 
end
Corr = bsxfun(@minus, Corr, mean(Corr,1)); 
Z = linkage(Corr, 'weighted', 'correlation'); 
D = pdist(Corr);
leafOrder = optimalleaforder(Z,D, 'criteria', 'group');

figure(3); clf
h(1) = subplot(2,2,1); 
[dend,T,indSeqSort] = dendrogram(Z, size(M,1), 'Reorder',leafOrder,'Orientation','left'); 

h(2) = subplot(2,2,2); 
imagesc(Corr(indSeqSort, :), 'xdata', lags); %axis square
set(gca, 'ydir', 'normal')
linkaxes(h, 'y')
xlabel('lag (s)');ylabel('Neuron #')    
title('autocorrelations')

subplot(2,2,3:4)
circleNeurons(cnmfeFilePath, indSeqSort([76 78:80 100:102 104 124 125]), nColors);
papersize = [8 8];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])



%% excude some neurons
% TOEXCLUDE = excludeNeurons_ByLocation(cnmfeFilePath);
% TOEXCLUDE = excludeNeurons(cnmfeFilePath); %TOEXCLUDE = 19; %indSeqSort([19]); 
% tokeep = setdiff(1:size(neuron.C,1), TOEXCLUDE);
% neuron.C = neuron.C(tokeep,:); 
% neuron.A = neuron.A(:,tokeep); 
% cnmfeFilePath = [cnmfeFilePath(1:end-4) '_cleaned.mat']; 
% save(cnmfeFilePath, 'neuron'); 
% after excluding neurons, rerun from beginning
%% raw traces
figure(1); 
papersize = [8 4];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
set(gca, 'color', 'none', 'tickdir', 'out', 'ticklength', [0.01, 0.01])
set(gca, 'fontsize' ,6)
selectedTraces(DataFolder, M, indSeqSort([76 78:80 100:102 104 124 125]), nColors); %([89 91 93 109 111 113 114 115 118 119 120 121]), nColors)
% figure(1); coloredTraces(DataFolder, cnmfeFilePath, indSeqSort, nColors)

%% nnmf
k = 10;
[W,H,rmsresidual(k)] = nnmf(M(:,:),k);
figure(3);clf; 
subplot(2,1, 1)
range = [-.8 .8]; 
imagesc(corr(H'), range);axis image; 
cmap = [[(1:64)'; 64*ones(64,1)] ...
    [1:64 64:-1:1]' ...
    [64*ones(64,1); (64:-1:1)']]/64;
colormap(cmap);shg
fcolors = lines(k); 
subplot(2,1, 2); 
Im = image(zeros(300,400,3)); 
for i = 1:k
    hold all; axis image
    tmp = reshape(neuron.A*W(:,i),300,400)/k/size(neuron.A,2);
    Im.CData = Im.CData + ...
        cat(3, tmp*fcolors(i,1), tmp*fcolors(i,2), tmp*fcolors(i,3)); 
%     Im.CData = Im.CData/max(Im.CData(:)); 
    drawnow
end

selectedTraces(DataFolder, H, 1:k,1-fcolors)
%% Looking at rhythms!
indToUse = 1:10000; 
MedFiltDat = medianFilter(neuron.C(:,indToUse), VIDEOfs*.1); 
TotAct = sum(MedFiltDat,1); 
S = []; 
for ni = 1:size(MedFiltDat,1)
    [S(ni,:,:),Time,F] = spectrogramELM(MedFiltDat(ni,:),30,1/30, 0, [1 10],.2, 5); 
    ni
end
Smaxproj = squeeze(max(10*log10(S+max(S(:)/100)),[],1));  
% Smaxproj = [Smaxproj Smaxproj1];

% selectedTraces(DataFolder, M, indSeqSort([26 27 30 61 62 64 66:70 93:96 102:104 116:120 128:130 162 163 189:192 208]), nColors,Smaxproj,F, 'Frequency (Hz)')
selectedTraces(DataFolder, M, indSeqSort([15:20 26:28 36:38 48 54 58:63 67:69]), nColors,Smaxproj,F, 'Frequency (Hz)')
% [S,Time,F] = spectrogramELM(TotAct,30,1/30, 0, [1 10],.2, 10); 
% selectedTraces(DataFolder, M, indSeqSort([11 18 20 27 33:36]), nColors,10*log10(S+max(S(:)/100)),F, 'Frequency (Hz)')
%% sleep analyses
% selectedTraces(DataFolder, M, indSeqSort([15:20 26:28 36:38 48 54 58:63 67:69]), nColors);%,Smaxproj,F, 'Frequency (Hz)')

clf
% find events
indSleep =[1:16351 19600:28800 31500:46200 50100:54900 56850:74700 ...
    77800:87700 91450:98050 98800:111400 113800:132250]; %3550:8250; 
% indSong = 1:3000; % includes some tutoring too
MedFiltDat = medianFilter(neuron.C, VIDEOfs*.1); 
TotAct = sum(MedFiltDat,1); 
plot(TotAct); 
[pks,locs,widths,proms] =  findpeaks(TotAct(indSleep));
EventTimes = indSleep(locs(proms>prctile(proms,95))); 
clf; plot((1:length(TotAct))/VIDEOfs, TotAct, 'k'); hold on; plot(EventTimes/VIDEOfs, ones(size(EventTimes,1),1), 'r.')
ylabel('Average of (med. filt.) neural activity (au)'); xlabel('Time (s)')
% [P,f] = PowerSpectrumELM(TotAct,VIDEOfs,3); 
% clf; plot(f,P, 'k'); xlabel('Frequency (Hz)'); ylabel('Power (au)')
% papersize = [8 4];
% set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
% title(['Power spectrum of average population activity during sleep ' foldername], 'interpreter', 'none')
% PopPSpec = []; 
% for ni = 1:length(indSeqSort)
%     tmp = medianFilter(neuron.C(indSeqSort(ni), indSleep), VIDEOfs);
%     [P,f] = PowerSpectrumELM(tmp,VIDEOfs,3); 
%     PopPSpec = [PopPSpec; P'];
% end
% figure(4); clf; 
% subplot(3,1,1)
% [P,f] = PowerSpectrumELM(TotAct,VIDEOfs,3); 
% plot(f,P, 'k'); xlabel('Frequency (Hz)'); ylabel('Power (au)')
% subplot(3,1,2:3)
% imagesc(f, 1:size(PopPSpec,1), PopPSpec)
% 
% figure(3); clf
% h(1) = subplot(4,1,1)
% [S,Time,F] = spectrogramELM(TotAct,30,1/30, 1, [1 10],.2, 20); drawnow; shg
% h(2) = subplot(4,1,2:4)
% plot(Time, neuron.C(:, indSleep)+repmat(10*(1:numel(indSeqSort))',1,length(Time)))
% linkaxes(h, 'x')
% 
% % find similar events while awake
% Twin = 30; % units frames
% ei = 1; 
% figure(3); clf
% subplot(2,1,1)
% Im = imagesc(neuron.C(indSeqSort, (EventTimes(ei)-Twin):(EventTimes(ei)+Twin)));
% colormap gray
% for ei = 1:length(EventTimes)
%     % plot a little history around the event
%     Im.CData = neuron.C(indSeqSort, (EventTimes(ei)-Twin):(EventTimes(ei)+Twin));
%     drawnow; shg
%     vec = neuron.C(indSeqSort, EventTimes(ei)); 
%     % find times when same neurons were active during singing
%     Dsong = sum((neuron.C(indSeqSort, indSong).*repmat(vec, 1,length(indSong)))); 
% end
% Construct similarity time series of sleep events, then look at them
% during singing


% sort events
% Corr = corr(neuron.C(indSeqSort,EventTimes)'); 
% Corr(isnan(Corr)) = 0; 
Z = linkage(neuron.C(indSeqSort,EventTimes)', 'weighted', 'correlation'); 
D = pdist(neuron.C(indSeqSort,EventTimes)');
leafOrder = optimalleaforder(Z,D, 'criteria', 'group');

% ewin = round(VIDEOfs*.05); 
% EventsInTime = []; 
% for ei = 1:length(EventTimes)
%     EventsInTime = [EventsInTime (EventTimes(leafOrder(ei))-ewin):(EventTimes(leafOrder(ei))+ewin)]; 
% end
BasisSet = MedFiltDat(indSeqSort,EventTimes(leafOrder)); 
SimTimeSeries = BasisSet'*MedFiltDat(indSeqSort,:); 
% SimTimeSeries = bsxfun(@rdivide, SimTimeSeries, sum(MedFiltDat,1));
% SimTimeSeries = bsxfun(@rdivide, SimTimeSeries, sum(BasisSet,1)'); 
% selectedTraces(DataFolder, SimTimeSeries,  1:length(EventTimes) ,lines(length(EventTimes)))
% selectedTraces(DataFolder, M, indSeqSort([15:20 26:28 36:38 48 54 58:63 67:69]), nColors, SimTimeSeries);%,Smaxproj,F, 'Frequency (Hz)')


% figure(3); clf
% h(1) = subplot(2,2,1); 
% [dend,T,indSeqSort] = dendrogram(Z, size(M,1), 'Reorder',leafOrder,'Orientation','left'); 

% for plotting
SimTimeSeries(SimTimeSeries<prctile(SimTimeSeries(:),.01)) = prctile(SimTimeSeries(:),.1); 
SimTimeSeries(SimTimeSeries>prctile(SimTimeSeries(:),99.9)) = prctile(SimTimeSeries(:),99.9); 

selectedTraces(DataFolder, neuron.C, indSeqSort(:), nColors, ...
    SimTimeSeries, 1:numel(EventTimes), 'Sleep Event #');