x = 0:200;
tau1 = 1;
tau2 = 20;
p = 8;
n = 0;
figure
% for tau1 = [10 100 200]
%     for tau2 = [10 30 50]
%         n = n + 1;
        kernel = (x./tau1).^p .* exp(-(x./tau2).^2);
        kernel = kernel ./ max(kernel);
        t_kernel = 0:length(kernel) - 1;
%         subplot(3,3,n)
        plot(t_kernel, kernel)
        title(sprintf('\\tau_1 = %g and \\tau_2 = %g', tau1, tau2))
%     end
% end
% error(t + t_kernel) = error(t + t_kernel) + instantaneous_error * kernel;