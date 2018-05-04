clear all; clc 
%% loading data
%nname = 'Neuron1333';
nname = 'Neuron1083'; 
figure(1);clf
load(['misc_elm\TestingFeatureLocking\', nname, '\rasterIFR.mat']); 
trigInfo.eventLabels{1}{67} = trigInfo.eventLabels{1}{67}(1:500); % weirdly 501 timepoints in 67th syllable of raster for 1083
trigInfo.eventLabels{1}{98} = trigInfo.eventLabels{1}{98}(1:500); % weirdly 501 timepoints in 98th syllable of raster for 1083
for i = 1:length(trigInfo.eventOnsets{1})
    RawIFR(i,:) = trigInfo.eventLabels{1}{i};
end
t = linspace(trigInfo.dataStart{1},trigInfo.dataStop{1}, size(RawIFR,2));
S = bsxfun(@minus, RawIFR, mean(RawIFR,1));
rsmpf = 5; %downsample factor eg 5 -> dt = 5ms
S1 = [];
for i = 1:size(S,1)
    S1(i,:) = decimate(S(i,:),rsmpf);
end
t  = decimate(t,rsmpf);
S = S1;

%% Test locking with each feature
Features = {'Pitch','Entropy', 'PitchGoodness', 'Amplitude', 'PitchChose'};

for fi = 1:length(Features)
    load(['misc_elm\TestingFeatureLocking\', nname, '\raster', Features{fi}, '.mat']); 
    trigInfo.eventLabels{1}{67} = trigInfo.eventLabels{1}{67}(1:500); % weirdly 501 timepoints in 67th syllable of raster for 1083
    trigInfo.eventLabels{1}{98} = trigInfo.eventLabels{1}{98}(1:500); % weirdly 501 timepoints in 98th syllable of raster for 1083
    for i = 1:length(trigInfo.eventOnsets{1})
        RawFeat(i,:) = trigInfo.eventLabels{1}{i};
    end
    t = linspace(trigInfo.dataStart{1},trigInfo.dataStop{1}, size(RawFeat,2));
    F = bsxfun(@minus, RawFeat, mean(RawFeat,1));
    F1 = [];
    for i = 1:size(F,1)
        F1(i,:) = decimate(F(i,:),rsmpf);
    end
    F = F1;
    t = decimate(t,rsmpf);
    
    % shuffling
    dt = t(2)-t(1); 
    lags = round(t/dt);
    lags = lags(t>-.1&t<.1);
    nshuff = 100;
    COVShuff = zeros(nshuff, length(lags));

    for shuffi = 1:nshuff
        SShuff = S(randperm(size(S,1)),:); 
        for lagi = 1:length(lags)
            lag = lags(lagi); 
            Stemp = zeros(size(S,1), size(S,2)); 
            indold = (1:length(t)) + lag; % to shift spike data by lag
            indnew = 1:length(t); % to shift spike data by lag
            indnew = indnew(indold>=1&indold<=length(t)); % make sure within range
            indold = indold(indold>=1&indold<=length(t)); % make sure within range
            Stemp(:,indnew) = SShuff(:,indold); % spike data shifted by lag
            COVtmp = mean(F.*Stemp); % cov at every time bin for this lag
            COVShuff(shuffi,lagi) =mean(COVtmp); % average cov across all time bins
        end
    end

    % actual calculation
    dt = t(2)-t(1); 
    lags = round(t/dt);
    lags = lags(t>-.1&t<.1);
    COV = zeros(1,length(lags));
    COVSIG = zeros(1,length(lags)); 

    for lagi = 1:length(lags)
        lag = lags(lagi); 
        Stemp = zeros(size(S,1), size(S,2)); 
        indold = (1:length(t)) + lag; % to shift spike data by lag
        indnew = 1:length(t); % to shift spike data by lag
        indnew = indnew(indold>=1&indold<=length(t)); % make sure within range
        indold = indold(indold>=1&indold<=length(t)); % make sure within range
        Stemp(:,indnew) = S(:,indold); % spike data shifted by lag
        COVtmp = mean(F.*Stemp); % cov at every time bin for this lag
        COV(lagi) = mean(COVtmp); % average cov across all time bins
        %COVSIG(lagi) = sum(COVShuff(:,lagi)<COV(lagi))/nshuff; 
    end
    subplot(3,2,fi); hold on
%     subplot(2,1,1)
%     plot(lags*dt, mean(COVSIG,1), 'k'); axis tight; ylim([0 1])
%    subplot(2,1,2); hold on
    Alp = 5; 
    BonCorAlpha = Alp/length(lags); 
    errorpatch_asym(lags*dt, prctile(COVShuff,50), ...
        prctile(COVShuff, BonCorAlpha/2), ...
        prctile(COVShuff, 100-BonCorAlpha/2)); 
    %plot(lags*dt, COVShuff, 'color', [.8 .8 .8])
    plot(lags*dt, prctile(COVShuff, 50), 'k'); 
    plot(lags*dt, COV, 'r'); axis tight
    xlabel('lag (s)') % positive lag of X s means spikes occur X s after feature
    ylabel('mean cov (au)')
    title(Features{fi}); 
    set(gcf, 'Color', [1 1 1], 'papersize', [6 6], 'paperposition', [0 0 6 6])
end


%%

%imagesc(S, 'xdata', t); shg
% %% 
% Features = {'Pitch','Entropy', 'PitchGoodness', 'Amplitude'};
% for fi = 1:length(Features)
%     load(['misc_elm\TestingFeatureLocking\raster', Features{fi}, '.mat']); 
%     for i = 1:length(trigInfo.eventOnsets{1})
%         RawFeat(i,:) = trigInfo.eventLabels{1}{i};
%     end
%     t = linspace(trigInfo.dataStart{1},trigInfo.dataStop{1}, size(RawFeat,2));
%     F = bsxfun(@minus, RawFeat, mean(RawFeat,1));
%     F1 = [];
%     for i = 1:size(F,1)
%         F1(i,:) = decimate(F(i,:),rsmpf);
%     end
%     F = F1;
%     %F = [zeros(107,2) S(:,1:(end-2))];
%     t = decimate(t,rsmpf);
%     %imagesc(F, 'xdata', t); shg
%     
%     % shuffling
%     dt = t(2)-t(1); 
%     lags = round(t/dt);
%     lags = lags(t>-.1&t<.1);
%     nshuff = 1000;
%     COVShuff = zeros(nshuff, length(t), length(lags));
% 
%     for shuffi = 1:nshuff
%         SShuff = S(randperm(size(S,1)),:); 
%         for lagi = 1:length(lags)
%             lag = lags(lagi); 
%             Stemp = zeros(size(S,1), size(S,2)); 
%             indold = (1:length(t)) + lag;  
%             indnew = 1:length(t); 
%             indnew = indnew(indold>=1&indold<=length(t)); indold = indold(indold>=1&indold<=length(t));
%             Stemp(:,indnew) = SShuff(:,indold);
%             COVShuff(shuffi,:,lagi) = mean(F.*Stemp); 
%         end
%     end
%     COVShuff = COVShuff(:,t>-.1&t<.2,:);
%     MShuff=squeeze(std(COVShuff,1)); 
%     %imagesc(MShuff); colorbar
% 
%     % actual calculation
%     dt = t(2)-t(1); 
%     lags = round(t/dt);
%     lags = lags(t>-.1&t<.1);
%     COV = zeros(length(t), length(lags));
% 
%     for lagi = 1:length(lags)
%         lag = lags(lagi); 
%         Stemp = zeros(size(S,1), size(S,2)); 
%         indold = (1:length(t)) + lag;  
%         indnew = 1:length(t); 
%         indnew = indnew(indold>=1&indold<=length(t)); indold = indold(indold>=1&indold<=length(t));
%         Stemp(:,indnew) = S(:,indold);
%         COV(:,lagi) = mean(F.*Stemp); 
%     end
%     COV= COV(t>-.1&t<.2,:);
%     t1 = t(t>-.1&t<.2);
%     COVSIG = zeros(size(COV,1),size(COV,2)); 
%     for lagi = 1:length(lags)
%         for ti = 1:size(COV,1)
%             COVSIG(ti,lagi) = sum((COVShuff(:,ti,lagi))<(COV(ti,lagi)))/nshuff; 
%         end
%     end
%     COVSIG(COVSIG>.1&COVSIG<.9)=.5;
%     %COVSIG = COVSIG-.5; 
%     figure(fi); clf
% 
%     subplot(3,3,1:2)
%     plot(lags*dt, mean(COVSIG,1), 'k'); axis tight; ylim([0 1])
%     subplot(3,3,[6 9])
%     plot(mean(COVSIG,2), t1,'k'); axis tight; xlim([0 1])
%     subplot(3,3,[4 5 7 8])
%     covplot = [ones(1,size(COV,2));zeros(1,size(COV,2));COVSIG];
%     tplot = [t1 t1(end)+dt t1(end)+2*dt]; 
%     imagesc(covplot, 'ydata', tplot, 'xdata', lags*dt); 
%     %set(colorbar, 'ytick', [.05 .5 .95], 'yticklabel', {'5%', '50%', '95%'})% 'location', 'EastOutside')
%     set(gca, 'ydir', 'normal'); ylim([t1(1) t1(end)])
%     ylabel('time before syllable onset (s)')
%     xlabel('lag (s)') % positive lag of X s means spikes occur X s after feature
%     cvec = [zeros(128,1);(1:128)'/128];
%     CMAP = [cvec cvec+flipud(cvec) flipud(cvec)];
%     colormap(CMAP)
%     suptitle(Features{fi}); 
% end
