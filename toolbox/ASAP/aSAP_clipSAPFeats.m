function feats = aSAP_clipSAPFeats(SAPFeats, startTimes, endTimes)
%Given a spectral derivative, start and end time of syllables within
%spectral derivative, and the index of syllables which start and end bouts,
%create a cell array of spectral derivatives.

[startNdx, endNdx] = aSAP_getSyllFeatureNdxRange(SAPFeats.param, startTimes, endTimes, 0);
startNdx = max(startNdx, 1);
endNdx = min(endNdx, length(SAPFeats.m_AM));

for(nClip = 1:length(startNdx))
    feats{nClip}.param = SAPFeats.param;
    feats{nClip}.m_AM = SAPFeats.m_AM(startNdx:endNdx);
    feats{nClip}.m_FM = SAPFeats.m_FM(startNdx:endNdx);
    feats{nClip}.m_Entropy = SAPFeats.m_Entropy(startNdx:endNdx);
    feats{nClip}.m_amplitude = SAPFeats.m_amplitude(startNdx:endNdx);
    feats{nClip}.gravity_center = SAPFeats.gravity_center(startNdx:endNdx);
    feats{nClip}.m_PitchGoodness = SAPFeats.m_PitchGoodness(startNdx:endNdx);          
    feats{nClip}.m_Pitch = SAPFeats.m_Pitch(startNdx:endNdx);
    feats{nClip}.Pitch_chose = SAPFeats.Pitch_chose(startNdx:endNdx);
    feats{nClip}.Pitch_weight = SAPFeats.Pitch_weight(startNdx:endNdx); 
end