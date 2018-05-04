function bout_derivs = aSAP_clipBoutsFromSD(m_spec_deriv, param, boutStartSyll, boutEndSyll, syllStartTimes, syllEndTimes, bufferSec)
%Given a spectral derivative, start and end time of syllables within
%spectral derivative, and the index of syllables which start and end bouts,
%create a cell array of spectral derivatives.

[startBoutNdx, endBoutNdx] = aSAP_getBoutFeatureNdxRange(param, boutStartSyll, boutEndSyll, syllStartTimes, syllEndTimes, bufferSec);
startBoutNdx = max(startBoutNdx, 1);
endBoutNdx = min(endBoutNdx, size(m_spec_deriv, 1));

for(nBout = 1:length(startBoutNdx))
    bout_derivs{nBout} = m_spec_deriv(startBoutNdx(nBout):endBoutNdx(nBout),:);
end