function matchScore = aSAP_computeMatchScore1(feats1, feats2, jitter, bWarp, audio1, audio2, bDebug )
%bWarp not yet implemented... always false.
%jitter in seconds
%bDebug: display analysis, and send to keybard.

if(feats1.param.winstep ~= feats2.param.winstep | feats1.param.fs ~= feats2.param.fs)
    warning('aSAP_computeMatchScore1: Both sets of features must use the same winstep and fs.');
end

%if(abs(length(feats1.m_AM) - length(feats2.m_AM)) * feats1.param.winstep /  feats1.param.fs > .025)
%    matchScore = 0; 
%    return;
%end

if(length(feats1.m_AM) > length(feats2.m_AM))
    temp = feats2;
    feats2 = feats1;
    feats1 = temp;
    temp = audio2;
    audio2 = audio1;
    audio1 = temp;
end

len1 = length(feats1.m_AM);
len2 = length(feats2.m_AM);
lengthDeduct = len1 / len2;

%resample:
feats1.m_AM = resample(double(feats1.m_AM), len2, len1);
feats1.m_FM = resample(double(feats1.m_FM), len2, len1);
feats1.m_Entropy = resample(double(feats1.m_Entropy), len2, len1);
feats1.gravity_center = resample(double(feats1.gravity_center), len2, len1);
feats1.m_Pitch = resample(double(feats1.m_Pitch), len2, len1);

%Demean the utilized features.
feats1.m_AM = (feats1.m_AM - mean(feats1.m_AM)) / std(feats1.m_AM);
feats1.m_FM = smooth(feats1.m_FM, 4);
feats1.m_FM = (feats1.m_FM - mean(feats1.m_FM)) / std(feats1.m_FM);
feats1.m_Entropy = (feats1.m_Entropy - mean(feats1.m_Entropy)) / std(feats1.m_Entropy);
feats1.gravity_center = (feats1.gravity_center - mean(feats1.gravity_center)) / std(feats1.gravity_center);
feats1.m_Pitch = smooth(feats1.m_Pitch, 4);
feats1.m_Pitch = (feats1.m_Pitch - mean(feats1.m_Pitch)) / std(feats1.m_Pitch);  


%Demean the utilized features.
feats2.m_AM = (feats2.m_AM - mean(feats2.m_AM)) / std(feats2.m_AM);
feats2.m_FM = smooth(feats2.m_FM, 4);
feats2.m_FM = (feats2.m_FM - mean(feats2.m_FM)) / std(feats2.m_FM);
feats2.m_Entropy = (feats2.m_Entropy - mean(feats2.m_Entropy)) / std(feats2.m_Entropy);
feats2.gravity_center = (feats2.gravity_center - mean(feats2.gravity_center)) / std(feats2.gravity_center);
feats2.m_Pitch = smooth(feats2.m_Pitch, 4);
feats2.m_Pitch = (feats2.m_Pitch - mean(feats2.m_Pitch)) / std(feats2.m_Pitch);  


maxlag = round(jitter*feats1.param.fs/feats1.param.winstep);

r = zeros(5,2*maxlag+1);
r(1,:) = xcorr(feats1.m_AM, feats2.m_AM, maxlag)/(max(length(feats1.m_AM),length(feats2.m_AM))-1);
r(2,:) = xcorr(feats1.m_FM, feats2.m_FM, maxlag)/(max(length(feats1.m_AM),length(feats2.m_AM))-1);
r(3,:) = xcorr(feats1.m_Entropy, feats2.m_Entropy, maxlag)/(max(length(feats1.m_AM),length(feats2.m_AM))-1);
r(4,:) = xcorr(feats1.gravity_center, feats2.gravity_center, maxlag)/(max(length(feats1.m_AM),length(feats2.m_AM))-1);
r(5,:) = xcorr(feats1.m_Pitch, feats2.m_Pitch, maxlag)/(max(length(feats1.m_AM),length(feats2.m_AM))-1);
r(r<0) = 0;

rAll = sum(r([2],:),1);
matchScore = (max(rAll)/5) * lengthDeduct;

if(bDebug)
    figure(29839);
   clf;
    subplot(6,2,1);
    displayAudioSpecgram(audio1, 40000); title(matchScore);
    subplot(6,2,2);
    displayAudioSpecgram(audio2, 40000);
    subplot(6,2,3); plot(feats1.m_AM);  hold on; plot(feats2.m_AM - 5, 'r'); axis tight; line(xlim,[0,0]); line(xlim,[-5,-5]);
    subplot(6,2,4); plot(r(1,:));  axis tight; ylim([-1,1]);
    subplot(6,2,5); plot(feats1.m_FM);  hold on; plot(feats2.m_FM - 5, 'r'); axis tight; line(xlim,[0,0]); line(xlim,[-5,-5]);
    subplot(6,2,6); plot(r(2,:));  axis tight; ylim([-1,1]);
    subplot(6,2,7); plot(feats1.m_Entropy);  hold on; plot(feats2.m_Entropy - 5, 'r'); axis tight; line(xlim,[0,0]); line(xlim,[-5,-5]);
    subplot(6,2,8); plot(r(3,:));  axis tight; ylim([-1,1]);
    subplot(6,2,9); plot(feats1.gravity_center);  hold on; plot(feats2.gravity_center - 5, 'r'); axis tight; line(xlim,[0,0]); line(xlim,[-5,-5]);
    subplot(6,2,10); plot(r(4,:));  axis tight; ylim([-1,1]);
    subplot(6,2,11); plot(feats1.m_Pitch);  hold on; plot(feats2.m_Pitch - 5, 'r'); axis tight; line(xlim,[0,0]); line(xlim,[-5,-5]);
    subplot(6,2,12); plot(r(5,:));  hold on; axis tight; plot(rAll/5,'r'); ylim([-1,1]);
    pause;
end
    
