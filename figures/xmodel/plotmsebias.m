function plotmsebias(d)
mse = xmodel_calculate_mse(permute(d.bias, [3 1 2]), d.template);
plot(mse)
xlabel('Trials')
ylabel('Mean Squared Error')
end