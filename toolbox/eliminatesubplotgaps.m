function eliminatesubplotgaps(hAxes)
%ELIMINATESUBPLOTGAPS decrease gaps between subplots
%   ELIMINATESUBPLOTGAPS(hAxes) eliminates the gap between axes pointed
%   to by handle array 'hAxes'. These axes are assumed to be in a single 
%   vertical line in the same figure.
%   
% 
%   Author: Galen Lynch
%   7/23/2014

assert(all(ishghandle(hAxes)), 'hAxes must be an array of valid handles');
nAx = numel(hAxes);
unitsCache = cell(1,nAx);
axPos = nan(nAx,4);
for axNo = 1:nAx
    axPos(axNo,:) = get(hAxes(axNo), 'position');
    unitsCache{axNo} = get(hAxes(axNo), 'Units');
    set(hAxes(axNo), 'Units', 'normalized');
end

[~, srtIdx] = sort(axPos(:,2));%Sort by distance from bottom of figure
axPos = axPos(srtIdx,:);
hAxes = hAxes(srtIdx);
unitsCache = unitsCache(srtIdx);

axHeights = axPos(:,4)';
gaps = nan(1, nAx - 1);
for gapNo = 1:(nAx-1)%Find gap sizes
    thisTop = sum(axPos(gapNo,[2,4]));
    nextBottom = axPos(gapNo + 1,2);
    gaps(gapNo) = nextBottom - thisTop;
end
margins = [axPos(1,2), 1-sum(axPos(end,[2,4]))];%[bottomMargin, topMargin]
heightDialation = (1-sum(margins))/sum(axHeights);%Factor to dialate axes
%rebuild axPos
newPos = axPos;
newHeights = axHeights*heightDialation;
newBottoms = [margins(1), margins(1) + cumsum(newHeights(1:end-1))];
newPos(:,2) = newBottoms';
newPos(:,4) = newHeights';
for axNo = 1:nAx
    set(hAxes(axNo), 'position', newPos(axNo,:));%move axes
    set(hAxes(axNo), 'Units', unitsCache{axNo});%Clean up
end
end