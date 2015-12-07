function [sigValueLo, sigValueHi] = getPeakSignificance(guiHandle)

P.NumSurrogates = 10000;
P.WaitBar = false;
P.SignificanceLevel = 0.05;
%%
% handles = guidata(guiHandle);
% params = getSortedRasterParameters(handles);
handles.axes_PSTH = findobj('Parent', guiHandle, 'Tag', 'axes_PSTH');
handles.axes_Raster = findobj('Parent', guiHandle, 'Tag', 'axes_Raster');
params.PsthSmoothing = 5;
allTicks = findobj('Parent', handles.axes_Raster, ...
              'Type', 'line', ...
              'Color', [0 0 0]); % ticks in raster
numTrials = max([allTicks.YData]) - 1;
tSpikeOriginal = cell(numTrials, 1);
for nTrial = 1:numTrials
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

% hpatch = findobj(handles.axes_PSTH.Children, 'Type', 'patch');
% bins = unique(hpatch.Vertices(:,1));
hline = findobj('Parent', handles.axes_PSTH, 'Type', 'line', 'LineWidth', 3);
bins = hline.XData;

roi = bins > -0.25 & bins < 0.25;

for iter = 1:P.NumSurrogates
    if P.WaitBar
        str = sprintf('Creating surrogate dataset for significance testing %g/%g', iter, P.NumSurrogates);
        waitbar(iter / P.NumSurrogates, h, str);
    end
    
%     if mod(P.NumSurrogates, 100) == 0
%         fprintf('Creating surrogate dataset for significance testing %g/%g\n', iter, P.NumSurrogates);
%     end
    
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
    firingRateSurrogate = helperPsth(tSpike, bins, params);
    
    % Find and store peak of the PSTH
    surrogatePeaks(iter) = max(firingRateSurrogate(roi));
    surrogateValleys(iter) = min(firingRateSurrogate(roi));
end
if P.WaitBar
    delete(h)
end

firingRateOriginal = helperPsth(tSpikeOriginal, bins, params);
originalPeak = max(firingRateOriginal(roi));
originalValley = min(firingRateOriginal(roi));


% When peaks are above sigValueHi, they are significant
% sortedPeaks = sort(surrogatePeaks);
% ndx = round((1 - P.SignificanceLevel) * P.NumSurrogates);
% sigValueHi = sortedPeaks(ndx);

sigValueHi = (sum(surrogatePeaks > originalPeak) + 1) / (P.NumSurrogates + 1);

% When valleys are below sigValueLo, they are significant
% sortedValleys = sort(surrogateValleys);
% ndx = round(P.SignificanceLevel * P.NumSurrogates);
% sigValueLo = sortedValleys(ndx);
sigValueLo = (sum(surrogateValleys < originalValley) + 1) / (P.NumSurrogates + 1);

function firingRate = helperPsth(t, bins, params)
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
counts = mysmooth(counts, params.PsthSmoothing);
firingRate = counts / (length(t) - skippedTrials) / binSizeSec;

function y = mysmooth(x, span)
assert(mod(span, 2) == 1, 'span must be odd')
halfspan = (span - 1) / 2;
w = 1 / span;
y = zeros(size(x));
if isempty(x)
    return
end
y(1) = (halfspan + 1) * w * x(1);
for n = 1:halfspan
    y(1) = y(1) + w * x(n + 1);
end
for n = 2:length(x)
    irem = n - halfspan - 1;
    iadd = n + halfspan;
    if irem < 1
        irem = 1;
    end
    if iadd > length(x)
        iadd = length(x);
    end
    y(n) = y(n - 1) - w * x(irem) + w * x(iadd);
end
y(1:halfspan) = nan;
y(end-halfspan:end) = nan;
    
