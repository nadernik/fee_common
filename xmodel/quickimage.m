function quickimage(varargin)
% QUICKIMAGE Display a labeled, scaled image
%   QUICKIMAGE('label1', data1, ...)
%   If multiple labels and data are provided, concatenates them in the y
%   direction.
%   See also IMAGESC

data = [];
for n = 1:nargin/2
    data = catnanpad(1, data, varargin{2*n});
    labels{n} = varargin{2*n-1};
    lastrow(n) = size(data, 1);
end

imagesc(data);
hold on
midpts = mean([1 lastrow(1:end-1); lastrow+1]);
set(gca, 'YTick', midpts) 
set(gca, 'YTickLabel', labels)
for n = 1:length(lastrow)
    line([0 size(data, 2)], ones(1,2)/2 + lastrow(n), 'LineWidth', 3, 'Color', 'k')
end
xlim([1 size(data,2)])
ylim([0.5 size(data,1)+0.5])