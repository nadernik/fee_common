function bouts = SegsToBouts(segs, moat)
segsPlus = bsxfun(@plus, segs, [-moat moat]); 
% remove gaps bigger than moat
candStarts = segsPlus(:,1); 
candEnds = segsPlus(:,2); 
dontStop = candStarts(2:end)<candEnds(1:end-1);
candEnds(find(dontStop)) = []; 
candStarts(find(dontStop)+1) = []; 
bouts = [candStarts candEnds];
% bouts(find((segsPlus(2:end,1) - segsPlus(1:end-1,2))<0),:) = []; % gap is too big
bouts(:,1) = max(1,bouts(:,1)); 
bouts(:,2) = min(segs(end,2),bouts(:,2)); 