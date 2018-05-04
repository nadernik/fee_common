function matchScore = aSAP_computeMatchScore1(feats1, feats2, jitter, bWarp)
%bWarp not yet implemented... always false.

if(feats1.param.winstep ~= feats2.param.winstep | feats1.param.fs ~= feats2.param.fs)
    warning('aSAP_computeMatchScore1: Both sets of features must use the same winstep and fs.');
end

if(abs(length(feats1.m_AM) - length(feats2.m_AM)) * feats1.param.winstep /  feats1.param.fs > .025)
    matchScore = 0; 
    return;
end

%Demean the utilized features.
feats1.m_AM = (feats1.m_AM - mean(feats1.m_AM)) / std(feats1.m_AM);
feats1.m_FM = (feats1.m_FM - mean(feats1.m_FM)) / std(feats1.m_FM);
feats1.m_Entropy = (feats1.m_Entropy - mean(feats1.m_Entropy)) / std(feats1.m_Entropy);
feats1.gravity_center = (feats1.gravity_center - mean(feats1.gravity_center)) / std(feats1.gravity_center);
feats1.m_Pitch = (feats1.m_Pitch - mean(feats1.m_Pitch)) / std(feats1.m_Pitch);  

%Demean the utilized features.
feats2.m_AM = (feats2.m_AM - mean(feats2.m_AM)) / std(feats2.m_AM);
feats2.m_FM = (feats2.m_FM - mean(feats2.m_FM)) / std(feats2.m_FM);
feats2.m_Entropy = (feats2.m_Entropy - mean(feats2.m_Entropy)) / std(feats2.m_Entropy);
feats2.gravity_center = (feats2.gravity_center - mean(feats2.gravity_center)) / std(feats2.gravity_center);
feats2.m_Pitch = (feats2.m_Pitch - mean(feats2.m_Pitch)) / std(feats2.m_Pitch);  

maxlag = round(jitter*feats1.param.fs/feats1.param.winstep);

r = zeros(5,2*maxlag+1);
r(1,:) = xcorr(feats1.m_AM, feats2.m_AM, maxlag);
r(2,:) = xcorr(feats1.m_FM, feats2.m_FM, maxlag);
r(3,:) = xcorr(feats1.m_Entropy, feats2.m_Entropy, maxlag);
r(4,:) = xcorr(feats1.gravity_center, feats2.gravity_center, maxlag);
r(5,:) = xcorr(feats1.m_Pitch, feats2.m_Pitch, maxlag);

r = prod(r,1);
matchScore = max(r)/(max(length(feats1.m_AM),length(feats2.m_AM))*5);
