function msn_examples(d, msn_example_list)
c = load('xmodel_color_scheme.mat');
plot(d.template, 'Color', c.template, 'LineWidth', 3)
hold on
plot(d.bias(:,end), 'Color', c.bias, 'LineWidth', 3)
% chsv = rgb2hsv([1 0 0]);
% sat = linspace(.5, 1, length(msn_example_list));
dy = 1.2;
offset = 4;
for ii = 1:length(msn_example_list)
    m = msn_example_list(ii);
    Y(:,ii) = d.msn_output(m, :, end);
    Y(:,ii) = Y(:,ii) ./ max(Y(:,ii)) - offset;
    offset = offset + dy;
end
plot(Y, 'Color', c.msn, 'LineWidth', 3)
end