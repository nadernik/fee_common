function y = decimateToAxesWidth(y, ax)
set(ax, 'Units', 'pixels');
pos = get(ax, 'Position');
width = pos(3);
factor = round(length(y) / width);
if factor > 1
    temp = decimateMinMax(y, factor / 2);
    clear y
    y(:,1) = temp(1:2:end);
    y(:,2) = temp(2:2:end);
end