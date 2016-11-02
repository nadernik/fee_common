%% simulate bursts that always precede onsets by a particular latency
clearvars(); 
Time = 1:2000; % time in ms
MeanOnsetTimes = find((mod(Time, 200) == 30)& Time>200 & Time<1800); 
MeanOffsetTimes = find((mod(Time, 200) == 180) & Time>200 & Time<1800); 
nSyls = length(MeanOnsetTimes); 
figure(3); clf; hold on; 
Nrenditions = 60; 
jittersize = 8; % jitter of syl onset and offset times, in ms, will use randn
PremotorLatency = -30; 
Burst = 0:5; % spikes to place around burst time
Onsets = zeros(Nrenditions, nSyls);
Offsets = zeros(Nrenditions, nSyls);
SpikeTimes = {}; 
for ri = 1:Nrenditions
    Onsets(ri,:) = MeanOnsetTimes + jittersize*randn(1,nSyls); 
    Offsets(ri,:) = MeanOffsetTimes + jittersize*randn(1,nSyls); 
    
    % for offset-locked gaps
%     SpikeTimes{ri} = find((rand(1,length(Time))<.2) & Time>200 & Time<1800);
%     for si = 2:nSyls-1 % skip first and last syllables so it's clear how to do time warping
%         SpikeTimes{ri}(SpikeTimes{ri}>Offsets(ri,si)-PremotorLatency &...
%             SpikeTimes{ri}<Offsets(ri,si)-PremotorLatency+20) = []; 
%     end
%     
    % for onset-aligned bursts
    SpikeTimes{ri} = [];
    for si = 2:nSyls-1 % skip first and last syllables so it's clear how to do time warping
        SpikeTimes{ri} = [SpikeTimes{ri} Onsets(ri,si)-PremotorLatency+Burst]; 
    end

end
%% plot raster
figure(3); clf
plotX = []; plotY = []; 
plotXon = []; plotYon = []; 
plotXoff = []; plotYoff = []; 
IFR = zeros(Nrenditions, length(Time)); 

for ri = 1:Nrenditions
    spt = SpikeTimes{ri};
    Spt2 = [repmat(spt(:),1,2),NaN*ones(length(spt),1)]'; 
    plotX = [plotX Spt2]; 
    tmpy = bsxfun(@times,(ones(length(spt),3)),[ri ri+1 NaN])';
    plotY = [plotY tmpy]; 
    
    
    spt = Onsets(ri,:);
    Spt2 = [repmat(spt(:),1,2),NaN*ones(length(spt),1)]'; 
    plotXon = [plotXon Spt2]; 
    tmpy = bsxfun(@times,(ones(length(spt),3)),[ri ri+1 NaN])';
    plotYon = [plotYon tmpy]; 
    
    spt = Offsets(ri,:);
    Spt2 = [repmat(spt(:),1,2),NaN*ones(length(spt),1)]'; 
    plotXoff = [plotXoff Spt2]; 
    tmpy = bsxfun(@times,(ones(length(spt),3)),[ri ri+1 NaN])';
    plotYoff = [plotYoff tmpy]; 
    
    for si = 2:length(spt)
        IFR(ri, spt(si-1):spt(si)) = 1/(spt(si)-spt(si-1)); %Probably a bug
    end
end
plot(plotX,plotY, 'k'); 
hold on; 
plot(plotXon, plotYon, 'g'); 
plot(plotXoff, plotYoff, 'r'); axis tight
xlabel('time (ms)'); ylabel('rendition')
% imagesc(IFR); 
%% warp it...
whichwarp = 'onoff';
plotX = []; plotY = []; 
LagsForWarp = -200:2:200; 
Measure = []; 
for li = 1:length(LagsForWarp)
%     figure(3); clf
    LagForWarp = LagsForWarp(li);
    plotX = []; plotY = []; 
    IFR = zeros(Nrenditions, length(Time)); 
    for ri = 1:Nrenditions
        assert(all(Offsets(ri, 1:(end - 1)) < Onsets(ri, 2:end)), 'Impossible to make non-overlapping segments');
        switch whichwarp 
            case 'onoff'
                withinSyllSegs = [Onsets(ri, :); Offsets(ri, :)]; % on-off warping
                refWithinSyll = [MeanOnsetTimes; MeanOffsetTimes];
            case 'onon'
                withinSyllSegs = Onsets(ri,:);
                refWithinSyll = MeanOnsetTimes;
            case 'offoff'
                withinSyllSegs = Offsets(ri,:); 
                refWithinSyll = MeanOffsetTimes;
        end
        allSegs = [Time(1); withinSyllSegs(:); Time(end)];
        referenceSegs = [Time(1); refWithinSyll(:); Time(end)];
        spt = TimeWarp_elm(SpikeTimes{ri}(:),...
            allSegs + LagForWarp, referenceSegs + LagForWarp);
        spt = spt(spt>Time(1)&spt<Time(end)); 
        Spt2 = [repmat(spt(:), 1 , 2), NaN * ones(length(spt), 1)]'; 
        plotX = [plotX Spt2]; 
        tmpy = bsxfun(@times,(ones(length(spt),3)),[ri ri+1 NaN])';
        plotY = [plotY tmpy]; 
        for si = 2:length(spt)
            IFR(ri, ceil(spt(si-1):spt(si))) = 1/(spt(si)-spt(si-1)); % This type of indexing with floats makes no sense
        end
    end
%     IFR = IFR(:,Time>200 & Time<1800); 
%     IFR = bsxfun(@minus, IFR, mean(IFR,2)); 
%     Measure(li) = sum(std(IFR)); 
%     Corr = (IFR'*IFR/Nrenditions)./...
%         (std(IFR)'*std(IFR)); 
%     Corr = (IFR*IFR'/Nrenditions)./...
%         (std(IFR')'*std(IFR')); 
    Corr = corr(IFR'); 
    Measure(li) = (sum(Corr(:))-Nrenditions)/Nrenditions/(Nrenditions-1)/2; 
%     imagesc(Corr); pause(.1)
%     imagesc(IFR); pause(.1)%
%     plot(plotX,plotY, 'k'); pause(.1)
    
li
end
figure(3); hold all
plot(LagsForWarp, Measure);%ylim([0 .1])
xlabel('warp shift (ms)'); ylabel('correlation')
title(whichwarp)
legend('onoff', 'onon', 'offoff')
title('')