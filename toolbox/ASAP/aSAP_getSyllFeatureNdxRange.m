function [syllStartFeatNdx, syllEndFeatNdx] = aSAP_getSyllFeatureNdxRange(param, syllStartTimes, syllEndTimes, bufferSec)

startTime = syllStartTimes - bufferSec;
endTime = syllEndTimes + bufferSec;
syllStartFeatNdx = aSAP_conTime2FeatNdx(startTime, param.fs, param.winstep);
syllEndFeatNdx = aSAP_conTime2FeatNdx(endTime, param.fs, param.winstep);

