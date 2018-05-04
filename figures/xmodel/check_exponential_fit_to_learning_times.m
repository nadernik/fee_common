for ii = 1:length(files)
    x = (nsmooth:learning_motifs)-nsmooth;
    y = log(files(ii).smoothed_error)';
    c = polyfit(x, y, 1);
    scatter(x,y)
    hold on
    plot(x, polyval(c, x))
    hold off
    pause
    title(num2str(ii))
end