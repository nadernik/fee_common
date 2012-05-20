function msn_examples(d, msn_example_list)
c = load('xmodel_color_scheme.mat');
% rescale so template ranges from 0 to 3
mn = min(d.template);
mx = max(d.template);
tmpl = 3 * (d.template - mn) / (mx - mn);
plot(tmpl, 'Color', c.template, 'LineWidth', 3) % plot template
bs = 3 * (d.bias(:, end) - mn) / (mx - mn);
hold on
plot(bs, 'Color', c.bias, 'LineWidth', 3) % plot bias on last motif
offset = 4; % starting offset. each trace is offset in Y from previous so traces do not overlap
dy = 1.2; % offset increment between traces
mmx = globalmax(d.msn_output(:,:,end));
of1 = offset;
for ii = 1:length(msn_example_list)
    m = msn_example_list(ii);
    Y(:,ii) = d.msn_output(m, :, end); % output of this msn on the last motif
    Y(:,ii) = Y(:,ii) ./ mmx - offset; % normalize to height 1 and apply offset
    offset = offset + dy; % increment offset by dy
end
of2 = offset;
ymsn = -(of1 + of2) / 2;
plot(Y, 'Color', c.msn, 'LineWidth', 3) % plot all the msn traces
set(gca, 'FontSize', 16)
xlabel('Time (ms)')
set(gca, 'YTick', [ymsn, 1.5])
set(gca, 'YTickLabel', {'MSN', 'Song'})
hold off
end