function syll_derivs = aSAP_clipSyllsFromSD(m_spec_deriv, param, syllStartTimes, syllEndTimes, bufferSec)
%Given a spectral derivative, start and end time of syllables within
%spectral derivative, and the index of syllables which start and end bouts,
%create a cell array of spectral derivatives.

[startSyllNdx, endSyllNdx] = aSAP_getSyllFeatureNdxRange(param, syllStartTimes, syllEndTimes, bufferSec)
startSyllNdx = max(startSyllNdx, 1);
endSyllNdx = min(endSyllNdx, size(m_spec_deriv, 1));

for(nBout = 1:length(startBoutNdx))
    syll_derivs{nBout} = m_spec_deriv(startSyllNdx(nBout):endSyllNdx(nBout),:);
end