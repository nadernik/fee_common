% also see Compilation6865 for notes on how to run things on openmind, rasters in labeled data, etc.

%% decide what data to look at
foldername = '6938_April10prepostnap'; 
DataFolder = fullfile('U:\ProcessedCalciumData\', foldername); 
cnmfeFilePath = fullfile('U:\ProcessedCalciumData\', foldername, 'cnmfe_results_cleaned.mat'); 
load(cnmfeFilePath, 'neuron'); 
load(fullfile(DataFolder, 'compiled.mat'), 'VIDEOfs', 'SOUNDfs')
clf; imagesc(neuron.C);shg
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
indSong = 1:2000; 

M = neuron.C;
nNeurons = size(neuron.C,1);
nColors = lines(nNeurons);
Corr = corr(M(:,indSong)'); 
Corr(isnan(Corr)) = 0; 
Z = linkage(Corr, 'weighted', 'correlation'); 
D = pdist(Corr);
leafOrder = optimalleaforder(Z,D, 'criteria', 'group');

figure(3); clf
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
circleNeurons(cnmfeFilePath,indSeqSort, nColors);
papersize = [8 8];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])



%% excude some neurons
% TOEXCLUDE = excludeNeurons(cnmfeFilePath); %TOEXCLUDE = indSeqSort([23 47 70 74]); 
% tokeep = setdiff(1:size(neuron.C,1), TOEXCLUDE);
% neuron.C = neuron.C(tokeep,:); 
% neuron.A = neuron.A(:,tokeep); 
% cnmfeFilePath = [cnmfeFilePath(1:end-4) '_cleaned.mat']; 
% save(cnmfeFilePath, 'neuron'); 
% after excluding neurons, rerun from beginning
%% raw traces
figure(1); 
papersize = [8 10];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
selectedTraces(DataFolder, M, indSeqSort, nColors)
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
MedFiltDat = medianFilter(neuron.C, VIDEOfs); 
TotAct = sum(MedFiltDat,1); 
S = []; 
for ni = 1:size(MedFiltDat,1)
    [S(ni,:,:),Time,F] = spectrogramELM(TotAct,30,1/30, 0, [1 10],.2, 6); 
    ni
end
Smaxproj = squeeze(mean(S,1)); 
% [S,Time,F] = spectrogramELM(TotAct,30,1/30, 0, [1 10],.2, 6); 
selectedTraces(DataFolder, M, indSeqSort, nColors,Smaxproj,F, 'Frequency (Hz)')
%% sleep analyses
clf
% find events
indSleep = 2401:16101; 
indSong = 1:2400; % includes some tutoring too
TotAct = sum(medianFilter(neuron.C(indSeqSort,indSleep), VIDEOfs),1); 
plot(TotAct); 
[pks,locs,widths,proms] =  findpeaks(TotAct);
EventTimes = locs(proms>prctile(proms,95))+indSleep(1)-1; 
clf; plot(indSleep, TotAct); hold on; plot(EventTimes, ones(size(EventTimes,1),1), 'r.')
[P,f] = PowerSpectrumELM(TotAct,VIDEOfs,3); 
clf; plot(f,P, 'k'); xlabel('Frequency (Hz)'); ylabel('Power (au)')
papersize = [8 4];
set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
title(['Power spectrum of average population activity during sleep ' foldername], 'interpreter', 'none')
PopPSpec = []; 
for ni = 1:length(indSeqSort)
    tmp = medianFilter(neuron.C(indSeqSort(ni), indSleep), VIDEOfs);
    [P,f] = PowerSpectrumELM(tmp,VIDEOfs,3); 
    PopPSpec = [PopPSpec; P'];
end
figure(4); clf; 
subplot(3,1,1)
[P,f] = PowerSpectrumELM(TotAct,VIDEOfs,3); 
plot(f,P, 'k'); xlabel('Frequency (Hz)'); ylabel('Power (au)')
subplot(3,1,2:3)
imagesc(f, 1:size(PopPSpec,1), PopPSpec)

figure(3); clf
h(1) = subplot(4,1,1)
[S,Time,F] = spectrogramELM(TotAct,30,1/30, 1, [1 10],.2, 20); drawnow; shg
h(2) = subplot(4,1,2:4)
plot(Time, neuron.C(:, indSleep)+repmat(10*(1:numel(indSeqSort))',1,length(Time)))
linkaxes(h, 'x')


Weird5Hz = indSeqSort([11 41 42 60 67]); 
comp5hz = []; 
compS5Hz = [];
for ni = 1:length(Weird5Hz)
    tmp = medianFilter(neuron.C(Weird5Hz(ni), indSleep), VIDEOfs);
    [S,Time,F] = spectrogramELM(tmp,30,1/30, 1, [0 10],.001, 10); drawnow; shg
    comp5hz = [comp5hz; tmp]; 
    compS5Hz = [compS5Hz; S];
end
% find similar events while awake
Twin = 30; % units frames
ei = 1; 
figure(3); clf
subplot(2,1,1)
Im = imagesc(neuron.C(indSeqSort, (EventTimes(ei)-Twin):(EventTimes(ei)+Twin)));
colormap gray
for ei = 1:length(EventTimes)
    % plot a little history around the event
    Im.CData = neuron.C(indSeqSort, (EventTimes(ei)-Twin):(EventTimes(ei)+Twin));
    drawnow; shg
    vec = neuron.C(indSeqSort, EventTimes(ei)); 
    % find times when same neurons were active during singing
    Dsong = sum((neuron.C(indSeqSort, indSong).*repmat(vec, 1,length(indSong)))); 
    subplot(2,1,2)
    plot(Dsong); xlim([150 500]); ylim([0 5000]); (pause(.05))
%     MatchingEventTimes = 1:
end
% Construct similarity time series of sleep events, then look at them
% during singing
BasisSet = neuron.C(indSeqSort,EventTimes); 
SimTimeSeries = BasisSet'*neuron.C(indSeqSort,:); 
SimTimeSeries = bsxfun(@rdivide, SimTimeSeries, sum(neuron.C,1));
SimTimeSeries = bsxfun(@rdivide, SimTimeSeries, sum(BasisSet,1)'); 
selectedTraces(DataFolder, SimTimeSeries,  1:length(EventTimes) ,lines(length(EventTimes)))