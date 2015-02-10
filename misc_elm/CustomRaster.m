% bird = '4202'; 
% day = '2013-12-05-NIf'; 
% depth = 's369'; 
% bird = '5223'; 
% day = '2014-11-03-NIf'; 
% depth = 's1333'; 
% 

% bird = '4202'; 
% day = '2013-12-02-NIf'; 
% depth = 's340'; 
% bird = '4032'; 
% day = '2013-09-27-NIf'; 
% depth = 's3XXa'; 
% 
bird = '5530'; 
day = '2015-01-30-NIf'; 
depth = 's472'; 

% bird = '4202'; 
% day = '2013-12-02-NIf'; 
% depth = 's325'; 

% bird = '4202'; 
% day = '2013-12-02-NIf'; 
% depth = 's325'; 
% bird = '5182'; 
% day = '2014-10-04-NIf'; 
% depth = 's1303'; 
% bird = '4108'; 
% day = '2013-10-22-NIf'; 
% depth = 's409'; 
% bird = '5182'; 
% day = '2014-09-29-NIf'; 
% depth = 's1292'; 
% bird = '4238'; 
% day = '2013-12-12-NIf'; 
% depth = 's258'; 
% bird = '4238'; 
% day = '2013-12-17-NIf'; 
% depth = 's213'; 

load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'raster'));

dt = .001; 
PSTHdt = .005; 
timepts = -.2:dt:.3;
PSTHtimepts = -.2:PSTHdt:.3;
timepts = -.2:dt:.3;
PSTHtimepts = -.2:PSTHdt:.3;
SPIKES = zeros(numel(trigInfo.eventOnsets{1}),length(timepts)); 
PSTHSPIKES = zeros(numel(trigInfo.eventOnsets{1}),length(PSTHtimepts)); 
g = subplot(3,2,3:6); hold on; 

for i = 1:numel(trigInfo.eventOnsets{1});
    times = trigInfo.eventOnsets{1}{i};
    if numel(times)>0
        %plot(times, ones(1,length(times))*i, 'marker', 'diamond')
        [n1,x1] = histc(times, timepts); 
        SPIKES(i,:) = n1>0; 
        [n1,x1] = histc(times, PSTHtimepts); 
        PSTHSPIKES(i,:) = n1; 
    end
end
%%
figure(1); clf; 
MaxToPlot = 100; 
if numel(trigInfo.eventOnsets{1})>MaxToPlot
    ind = randperm(numel(trigInfo.eventOnsets{1})); 
    ind = sort(ind(1:MaxToPlot)); 
    trigInfo.eventOnsets{1} = trigInfo.eventOnsets{1}(ind); 
    trigInfo.currTrigOnset = trigInfo.currTrigOnset(ind); 
    trigInfo.currTrigOffset = trigInfo.currTrigOffset(ind); 
    trigInfo.prevTrigOnset = trigInfo.prevTrigOnset(ind); 
    trigInfo.prevTrigOffset = trigInfo.prevTrigOffset(ind); 
    SPIKES = SPIKES(ind,:);
end
g = subplot(3,2,3:6); hold on
for i = 1:numel(trigInfo.eventOnsets{1});
    times = trigInfo.eventOnsets{1}{i};
    if numel(times)>0
        plottimes = reshape([times times times]',1,3*numel(times)); 
        plottrialind = reshape([ones(length(times),1)*i ones(length(times),1)*i+1 ones(length(times),1)*NaN]',1,3*numel(times)); 
        plot(plottimes,plottrialind, 'k')
    end
end

Dur = trigInfo.currTrigOffset-trigInfo.currTrigOnset; 
%g = subplot(3,2,3:6); hold on; imagesc(SPIKES, 'xdata', timepts); colormap(flipud(gray)); shg
plot(trigInfo.currTrigOnset, 1:numel(trigInfo.eventOnsets{1}), 'g')
plot(trigInfo.currTrigOffset, 1:numel(trigInfo.eventOnsets{1}), 'r'); %axis tight
ylabel('syllable number'); ylim([0 numel(trigInfo.eventOnsets{1})])
set(gca, 'ytick', 0:20:numel(trigInfo.eventOnsets{1})-1)
xlabel('time relative to syllable onset (s)')
ylim([1 numel(trigInfo.eventOnsets{1})+1])
set(gca,'color','none')
h = subplot(3,2,1:2); hold on
rate = mean(PSTHSPIKES,1)/PSTHdt; 
b = bar(PSTHtimepts, rate,'histc'); axis tight; box off
plot([0 0], [0 max(rate)], 'g')
set(b, 'FaceColor', [0 0 0])
ylabel('rate (Hz)')
set(gca, 'xtick', [])
set(gca,'color','none')
linkaxes([h g], 'x'); xlim([PSTHtimepts(1) PSTHtimepts(end)])
ShrinkBy = 5; 
p = get(h, 'pos');
q = get(g, 'pos');
m = mean([p(2) q(2)+q(4)]);
gap = p(2) - (q(2)+q(4));
p(2) = m + gap/(2*ShrinkBy);
q(4) = m-q(2)-  gap/(2*ShrinkBy);
set(h, 'pos', p)
set(g, 'pos', q)
%%
set(gcf, 'papersize', [4 3], 'paperposition', [0 0 4 3])
print -dmeta -r300