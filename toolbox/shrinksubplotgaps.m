function shrinksubplotgaps(hAxes, shrinkFactor)
%SHRINKSUBPLOTGAPS decrease gaps between subplots
%   SHRINKSUBPLOTGAPS(hAxes, shrinkFactor) decreases the gap between axes
%   pointed to by handle array 'hAxes' by a factor of 'shrinkFactor.' These
%   axes are assumed to be in the same figure, and created by SUBPLOT.
% 
%   Author: Galen Lynch
%   7/23/2014

assert(all(ishghandle(hAxes)), 'hAxes must be an array of valid handles');
assert(isscalar(shrinkFactor) && shrinkFactor > 0, 'shrinkFactor must be scalar greater than zero');
nAx = numel(hAxes);
unitsCache = cell(1,nAx);
axPos = nan(nAx,4);
for axNo = 1:nAx
    axPos(axNo,:) = get(hAxes(axNo), 'position');
    unitsCache{axNo} = get(hAxes(axNo), 'Units');
    set(hAxes(axNo), 'Units', 'normalized');
end

%Check for arrangement of axes
if all(diff(axPos(:,2)) < 0) %monotonically decreasing y positions
    axPos = flipud(axPos);%Flip axes positions to be bottom to top
    hAxes = hAxes(end:-1:1);%Do the same for the handles
    unitsCache = unitsCache(end:-1:1);
elseif all(diff(axPos(:,2)) > 0) %monotonically increasing y positions
    %Do nothing
else
    error('Axes y positions must be monotonic')
end

axHeights = axPos(:,4)';
gaps = nan(1, nAx - 1);
for gapNo = 1:(nAx-1)%Find gap sizes
    thisTop = sum(axPos(gapNo,[2,4]));
    nextBottom = axPos(gapNo + 1,2);
    gaps(gapNo) = nextBottom - thisTop;
end
margins = [axPos(1,2), 1-sum(axPos(end,[2,4]))];%[bottomMargin, topMargin]
heightDialation = (1-sum(margins)-sum(gaps)/shrinkFactor)/sum(axHeights);%Factor to dialate axes
%rebuild axPos
newPos = axPos;
newHeights = axHeights*heightDialation;
newBottoms = [margins(1), margins(1) + cumsum(gaps/shrinkFactor + newHeights(1:end-1))];
newPos(:,2) = newBottoms';
newPos(:,4) = newHeights';
for axNo = 1:nAx
    set(hAxes(axNo), 'position', newPos(axNo,:));%move axes
    set(hAxes(axNo), 'Units', unitsCache{axNo});%Clean up
end
end