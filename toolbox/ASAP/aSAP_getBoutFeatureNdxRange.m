function [boutStartFeatNdx, boutEndFeatNdx] = aSAP_getBoutFeatureNdxRange(param, boutStartSyll, boutEndSyll, syllStartTimes, syllEndTimes, bufferSec)

startTime = syllStartTimes(boutStartSyll) - bufferSec;
endTime = syllEndTimes(boutEndSyll) + bufferSec;
boutStartFeatNdx = aSAP_conTime2FeatNdx(startTime, param.fs, param.winstep);
boutEndFeatNdx = aSAP_conTime2FeatNdx(endTime, param.fs, param.winstep);

