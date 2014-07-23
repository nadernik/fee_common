function eliminatesubplotgaps(hAxes)
%ELIMINATESUBPLOTGAPS decrease gaps between subplots
%   ELIMINATESUBPLOTGAPS(hAxes) eliminates the gap between axes pointed
%   to by handle array 'hAxes'. These axes are assumed to be in the same
%   figure, and have been created by SUBPLOT.
% 
%   Author: Galen Lynch
%   7/23/2014

assert(all(ishghandle(hAxes)), 'hAxes must be an array of valid handles');
nAx = numel(hAxes);
axPos = nan(nAx,4);
for axNo = 1:nAx
    axPos(axNo,:) = get(hAxes(axNo), 'position');
end

%Check for arrangement of axes
if all(diff(axPos(:,2)) < 0) %monotonically decreasing y positions
    axPos = flipud(axPos);%Flip axes positions to be bottom to top
    hAxes = hAxes(end:-1:1);%Do the same for the handles
elseif all(diff(axPos(:,2)) > 0) %monotonically increasing y positions
    %Do nothing
else
    error('Axes y positions must be monotonic')
end

gaps = nan(1, nAx - 1);
axHeights = axPos(:,4)';
for gapNo = 1:(nAx-1)
    thisTop = sum(axPos(gapNo,[2,4]));
    nextBottom = axPos(gapNo + 1,2);
    gaps(gapNo) = nextBottom - thisTop;
end
gapOffset = sum(gaps)/2; %How much to increase bottom height by
%rebuild axPos
newPos = axPos;
newBottoms = axPos(1,2)+gapOffset;
newBottoms = [newBottoms, newBottoms + cumsum(axHeights(1:end-1))];
newPos(:,2) = newBottoms';
for axNo = 1:nAx
    set(hAxes(axNo), 'position', newPos(axNo,:));
end
end