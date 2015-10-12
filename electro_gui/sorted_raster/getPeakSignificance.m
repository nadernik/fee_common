function [sigValueLo, sigValueHi] = getPeakSignificance(guiHandle)

P.NumSurrogates = 10000;
P.WaitBar = false;
P.SignificanceLevel = 0.01;

handles = guidata(guiHandle);
allTicks = findobj('Parent', handles.axes_Raster, ...
              'Type', 'line', ...
              'Color', [0 0 0]); % ticks in raster
numTrials = max([allTicks.YData]) - 1;
tSpikeOriginal = cell(numTrials, 1);
for nTrial = 1:numTrials
    nTrial
    trialTicks = findobj(allTicks, 'YData', (0:1) + nTrial);
    if isempty(trialTicks)
        tSpikeOriginal{nTrial} = [];
    else
        xx = [trialTicks.XData]; % like [x1 x1 x2 x2 x3 x3 ... ]
        tSpikeOriginal{nTrial} = xx(1:2:end); % like [x1 x2 x3 ...]
    end
end

TLim = xlim(handles.axes_PSTH);
randomShift = (TLim(2) - TLim(1)) * rand(numTrials, P.NumSurrogates) + TLim(1);

hpatch = findobj(handles.axes_PSTH.Children, 'Type', 'patch');
bins = unique(hpatch.Vertices(:,1));

for iter = 1:P.NumSurrogates
    if P.WaitBar
        str = sprintf('Creating surrogate dataset for significance testing %g/%g', iter, P.NumSurrogates);
        waitbar(iter / P.NumSurrogates, h, str);
    end
    
    % Shift spike times
    tSpike = cell(size(tSpikeOriginal));
    for nTrial = 1:numTrials
        
        % random shift
        t = tSpikeOriginal{nTrial} + randomShift(nTrial, iter);
        
        % wrap times that went off the right edge of the window (too high)
        isTooHi = t > TLim(2);
        t(isTooHi) = t(isTooHi) - (TLim(2) - TLim(1));
        
        % wrap times that went off the left edge (too low)
        isTooLo = t < TLim(1);
        t(isTooLo) = t(isTooLo) + (TLim(2) - TLim(1));
        
        % These are the circularly-shifted spike times!
        tSpike{nTrial} = t;
    end
    
    % Make PSTH with shifted spike times
    firingRateSurrogate = helperPsth(tSpike, bins);
    
    % Find and store peak of the PSTH
    surrogatePeaks(iter) = max(firingRateSurrogate);
    surrogateValleys(iter) = min(firingRateSurrogate);
end
if P.WaitBar
    delete(h)
end

% When peaks are above sigValueHi, they are significant
sortedPeaks = sort(surrogatePeaks);
ndx = round((1 - P.SignificanceLevel) * P.NumSurrogates);
sigValueHi = sortedPeaks(ndx);

% When valleys are below sigValueLo, they are significant
sortedValleys = sort(surrogateValleys);
ndx = round(P.SignificanceLevel * P.NumSurrogates);
sigValueLo = sortedValleys(ndx);

function firingRate = helperPsth(t, bins)
%HELPERPSTH Peristimulus time histogram
%
% t is a cell array of spike times. Each cell containts a vector of spike
% times for one trial. Times are in milliseconds relative to the trigger
% onset.
%
% bins are the bin edges in milliseconds. They must be uniformly spaced

binSizeSec = bins(2) - bins(1);

counts = zeros(1, length(bins));

skippedTrials = 0;
for nTrial = 1:length(t)
    if isempty(t{nTrial})
        skippedTrials = skippedTrials + 1;
        continue
    end
    counts = counts + histc(t{nTrial}, bins);
end
counts(end) = nan; % remove edge effect - there are never any spikes in the last bin
firingRate = counts / (length(t) - skippedTrials) / binSizeSec;