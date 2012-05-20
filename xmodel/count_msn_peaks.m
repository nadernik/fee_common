function total_extrema = count_msn_peaks(msn_output)

DEBUG_FLAG = 0;

if DEBUG_FLAG
    figure
end
for m = 1:size(msn_output, 1)
    y = msn_output(m,:,end);
    sgn = sign(diff(y));
    sgn(sgn == 0 ) = 1; % zeros are positive
    t_extrema = sgn(1:end-1) == -sgn(2:end);
    t_extrema = find(t_extrema & abs(y(2:end-1)) > 0.05)+1;
    y_extrema = y(t_extrema);
    total_extrema(m) = length(t_extrema);
    if DEBUG_FLAG
        plot(y)
        title(int2str(m))
        hold on
        scatter(t_extrema, y_extrema);
        hold off
        pause
    end
end
figure
x = 0:0.5:max(total_extrema);
hist(total_extrema,x)
set(gca, 'XTick', 0:max(total_extrema))
xlabel('Number of peaks')
ylabel('Number of neurons')