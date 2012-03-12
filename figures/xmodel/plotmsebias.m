function varargout = plotmsebias(d)
mse = xmodel_calculate_mse(permute(d.bias, [3 1 2]), d.template);
h = plot(mse);
xlabel('Trials')
ylabel('Mean Squared Error')

if nargout >= 1
    varargout{1} = h;
end
if nargout >= 2
    varargout{2} = mse;
end

end