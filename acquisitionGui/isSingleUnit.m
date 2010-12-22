function bUnit = isSingleUnit(sig, varargin)

P.threshold = 4;
P.thresholdType = {'abs', 'std'}; 
P.refractory = .001; %secs
P.minSpikeHeight = 1.5; %Signal Units
P.minRate = 1; %Hz
P.maxSpikeHeight
P = parseargs(P,varargin{:});

if(strcmpi(P.thresholdType,'std'))
   P.threshold = P.threshold * std(sig); 
end

[riseAbove, fallAbove] = detectThresholdCrossings(sig, P.threshold, true)
[riseBelow, fallBelow] = detectThresholdCrossings(sig, P.threshold, false)