function varargout = plotmsebias(d)
mse = xmodel_calculate_mse(permute(d.bias, [3 1 2]), d.template);
h = semilogy(mse, 'LineWidth', 3, 'Color', 'k');
set(gca, 'FontSize', 16)
xlabel('Trials')
ylabel('Mean Squared Error')
ylim([0,1.1*max(mse)])
xlim([0, d.total_motifs])

if nargout >= 1
    varargout{1} = h;
end
if nargout >= 2
    varargout{2} = mse;
end

end