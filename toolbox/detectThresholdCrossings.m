function [leadingEdgeNdx, fallingEdgeNdx] = detectThresholdCrossings(sig, fThres, bAbove)
%DETECTTHRESHOLDCROSSINGS Rising and falling edges of threshold crossings
%   [t1 t2] = detectThresholdCrossings(v, thresh, bAbove)
%       Returns leading (t1) and falling (t2) times when signal (v) is
%       above threshold (thresh). If bAbove is false, the leading edge is
%       when the signal falls below thresh. 

leadingEdgeNdx = [];
fallingEdgeNdx = [];
sig = sig(:);
if ~exist('bAbove', 'var')
    bAbove = true;
end

if(bAbove)
    exceedsThres = find(sig>fThres);
else
    exceedsThres = find(sig<fThres);
end
    
if(length(exceedsThres)>0)
    ndx = find(diff(exceedsThres)>1);
    
    leadingEdgeNdx = exceedsThres(ndx + 1);
    leadingEdgeNdx = [exceedsThres(1); leadingEdgeNdx];
    fallingEdgeNdx = exceedsThres(ndx);  
    fallingEdgeNdx = [fallingEdgeNdx; exceedsThres(end)];
end
    
    
   