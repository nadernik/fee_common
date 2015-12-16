function setcolormapfreeze(axesHandles, cmapStr, backgroundC)
colormap(axesHandles, cmapStr);
figH = get_parent_figure(axesHandles);
if verLessThan('matlab','8.4.0')
    cmap = get(figH,'colormap');
    cmap(1,:) = backgroundC;%Set background to black
    set(figH, 'colormap', cmap);
    freezeColors(axesHandles);
else
    cmap = colormap(axesHandles);
    cmap(1,:) = backgroundC;%Set background to black
    colormap(axesHandles, cmap);
end
end