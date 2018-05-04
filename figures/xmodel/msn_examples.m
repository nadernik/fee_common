function msn_examples(d, msn_example_list)
SF = 3;
% rescale so template has max value of 3
mx = max(d.template);
tmpl = SF * d.template / mx;
plot(tmpl, 'Color', [0.7 0.7 0.7], 'LineWidth', 3) % plot template
hold on
bs = SF * d.bias(:, end) / mx;
plot(bs, '.', 'Color', 'k', 'LineWidth', 3) % plot bias on last motif
line(xlim, [0 0], 'Color', [0 0 0]) % black line at pitch = 0
offset = 2; % starting offset. each trace is offset in Y from previous so traces do not overlap
dy = 1.6; % offset increment between traces
mmx = globalmax(d.msn_output(:,:,end));
for ii = 1:length(msn_example_list)
    m = msn_example_list(ii);
    Y(:,ii) = d.msn_output(m, :, end); % output of this msn on the last motif
    Y(:,ii) = Y(:,ii) ./ mmx - offset; % normalize to height 1 and apply offset
    ymsns(ii) = -offset;
    offset = offset + dy; % increment offset by dy
end
plot(Y, 'Color', 'k', 'LineWidth', 3) % plot all the msn traces
ylim([-offset, 1.2*SF])
set(gca, 'FontSize', 16)
xlabel('Time (ms)')
set(gca, 'YTick', [wrev(ymsns) 0])
set(gca, 'YTickLabel', [arrayfun(@int2str, wrev(msn_example_list), 'UniformOutput', false), 0])
hold off
end