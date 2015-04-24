function zoomboxCallback(ax, evnt)
% Left click and drag to zoom in; shift left click to zoom out

fig = get(ax, 'Parent');

% Store the current axes limits as the original limits if there is no
% original stored already.
ud = get(ax, 'UserData');
if ~isfield(ud, 'xlimOriginal') || ~isfield(ud, 'ylimOriginal')
    ud.xlimOriginal = xlim;
    ud.ylimOriginal = ylim;
    set(ax, 'UserData', ud)
end

switch get(fig, 'SelectionType')
    case 'normal'
        % Left click and drag to make a box, and zoom in so that the new
        % axes limits are the edges of the box.
        clickLocation = get(ax, 'CurrentPoint');
        rect = rbbox;
        endPoint = get(ax,'CurrentPoint');
        x1 = clickLocation(1,1);
        y1 = clickLocation(1,2);
        x2 = endPoint(1,1);
        y2 = endPoint(1,2);
        xmin = min(x1, x2);
        xmax = max(x1, x2);
        ymin = min(y1, y2);
        ymax = max(y1, y2);
        
        % If the box is smaller than 0.1% along a dimension, just zoom in 
        % by a factor of four centered on the click point
        axesWidth = abs(diff(xlim));
        if (xmax - xmin) < (0.001 * axesWidth)
            xmin = xmin - axesWidth / 8;
            xmax = xmax + axesWidth / 8;
        end
        axesHeight = abs(diff(ylim));
        if (ymax - ymin) < (0.001 * axesHeight)
            ymin = ymin - axesHeight / 8;
            ymax = ymax + axesHeight / 8;
        end
        
        xlim([xmin, xmax])
        ylim([ymin, ymax])
    case 'extend'
        %shift click to zoom out
        xlim(ud.xlimOriginal)
        ylim(ud.ylimOriginal)
end