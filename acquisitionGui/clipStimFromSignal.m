function stimClips = clipStimFromSignal(sig, fs, stimThreshold, preStimMs, postStimMs, maxStimPeakWidthMs, minStimSpacingSecs)
samplesPre = preStimMs / 1000 * fs;
samplesPost = postStimMs / 1000 * fs;
minSpacingSamples = minStimSpacingSecs * fs;
maxWidthSamples = maxStimPeakWidthMs / 1000 * fs;

aboveThreshold = sig > stimThreshold;
belowThreshold = sig < stimThreshold;
risingEdge  = find(diff(aboveThreshold) == 1);
fallingEdge = find(diff(belowThreshold) == 1);


% Remove stims that are too wide
widthSamples = abs(risingEdge - fallingEdge);
tooWide = widthSamples > maxWidthSamples;
risingEdge = risingEdge(~tooWide); % logical indexing
fallingEdge = fallingEdge(~tooWide);

% Remove stims that are too close together
while true
    spacingSamples = diff(risingEdge);
    [shortestSpacing, iShortest] = min(spacingSamples);  
    if shortestSpacing < minSpacingSamples
        i = 1:length(risingEdge);
        risingEdge = risingEdge(i ~= (iShortest + 1));
        fallingEdge = fallingEdge(i ~= (iShortest + 1));
    else
        break
    end
end

% Get signal around each stim
if sign(stimThreshold) == 1
    leadingEdge = risingEdge;
else
    leadingEdge = fallingEdge;
end
stimClips = zeros(samplesPre + samplesPost + 1, length(leadingEdge));
for nstim = 1:length(leadingEdge)
    samp1 = leadingEdge(nstim) - samplesPre;
    samp2 = leadingEdge(nstim) + samplesPost;
    try
        stimClips(:, nstim) = sig(samp1:samp2);
    end
end
