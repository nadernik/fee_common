function shrinksubplotgaps(hAxes, shrinkFactor, dim)
%SHRINKSUBPLOTGAPS decrease gaps between subplots
%   SHRINKSUBPLOTGAPS(hAxes, shrinkFactor) decreases the gap between axes
%   pointed to by handle array 'hAxes' by a factor of 'shrinkFactor.' These
%   axes are assumed to be in a single vertical line in the 
%   same figure.
% 
%   Author: Galen Lynch
%   7/23/2014

if ~exist('dim', 'var')
    dim = 1;
end

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

switch dim%choose position vector indices based on desired dimension
    case 1
        offsetD = 2;
        spanD = 4;
    case 2
        error('not currently working!');
%         offsetD = 1;
%         spanD = 3;
    otherwise
        error('only works with two dimensions')
end

[~, srtIdx] = sort(axPos(:,offsetD),'ascend');%Sort by distance from bottom of figure
axPos = axPos(srtIdx,:);
hAxes = hAxes(srtIdx);
unitsCache = unitsCache(srtIdx);

axSpans = axPos(:,spanD)';
gaps = nan(1, nAx - 1);
for gapNo = 1:(nAx-1)%Find gap sizes
    thisTop = sum(axPos(gapNo,[offsetD,spanD]));
    nextBottom = axPos(gapNo + 1,offsetD);
    gaps(gapNo) = nextBottom - thisTop;
end
margins = [axPos(1,offsetD), 1-sum(axPos(end,[offsetD,spanD]))];%[bottomMargin, topMargin]
heightDialation = (1-sum(margins)-sum(gaps)/shrinkFactor)/sum(axSpans);%Factor to dialate axes
%rebuild axPos
newPos = axPos;
newHeights = axSpans*heightDialation;
newBottoms = [margins(1), margins(1) + cumsum(gaps/shrinkFactor + newHeights(1:end-1))];
newPos(:,offsetD) = newBottoms';
newPos(:,spanD) = newHeights';
for axNo = 1:nAx
    set(hAxes(axNo), 'position', newPos(axNo,:));%move axes
    set(hAxes(axNo), 'Units', unitsCache{axNo});%Clean up
end
end