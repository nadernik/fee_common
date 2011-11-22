function rpeplothelper(Y, bin_centers, hist_ymax, colors, t)

figure
hold on
yhi = max(max(Y));
ylo = min(min(Y));
yrange = yhi - ylo;
ylo = ylo - 0.15 * yrange;
yhi = yhi + 0.15 * yrange;
plot(Y, 'Color', trace_color)
x = t + [-0.5, 0.5];
y = interp1(1:T, Y(:, nred), x);
plot(x, y, 'Color', colors.bad, 'LineWidth', 3)
y = interp1(1:T, Y(:, ngreen), x);
plot(x, y, 'Color', colors.good, 'LineWidth', 3)
xlim([0 T])
ylim([ylo yhi])
axis off

figure
counts = hist(Y(t, :), bin_centers);
h = histdot(counts, bin_centers);
set(h, 'Marker', '.', 'MarkerEdgeColor', colors.trace, 'MarkerFaceColor', colors.trace)
hold on
[junk, redbin] = min(abs(bin_centers - Y(t, nred)));
scatter(bin_centers(redbin), counts(redbin) + 1, 'MarkerEdgeColor', colors.bad, 'MarkerFaceColor', colors.bad)
[junk, greenbin] = min(abs(bin_centers - Y(t, ngreen)));
scatter(bin_centers(greenbin), counts(greenbin) + 1, 'MarkerEdgeColor', colors.good, 'MarkerFaceColor', colors.good)
xlim([-100 100])
ylim([0 hist_ymax])
axis off