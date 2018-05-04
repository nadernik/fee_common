faclist = logspace(-2,2,21);
for iii = 1:length(faclist)
    save temp.mat iii faclist
    clear all
    load temp.mat
    sparsemodel_parameters
    stability_factor = stability_factor * faclist(iii)
    sparsemodel_initialize
    sparsemodel_run
    save(['c:\stetner\data\sparsemodel\stability_factor_test_' int2str(iii)])
end

%%
clear all
figure
faclist = logspace(-2,2,21);
w = zeros(300,50,21);
for iii = 1:length(faclist)
    d = load(['c:\stetner\data\sparsemodel\stability_factor_test_' int2str(iii)], ...
        'weights_on_msn_from_hvc', 'stability_factor', 'bias', 'template');
    w(:,:,iii) = d.weights_on_msn_from_hvc;
    c(iii) = d.stability_factor;
    
    subplot(1,4,1)
    imagesc(w(:,:,iii))
    title(num2str(c(iii)))
    
    subplot(1,4,2)
    mse = xmodel_calculate_mse(permute(d.bias, [3 1 2]), d.template);
    endingmse(iii) = mse(end);
    plot(mse)
    ylim([-0.2, 3])
    ylabel('Mean Squared Error')
    xlabel('Trials')
    
    subplot(1,4,3)
    bins = -5:0.25:0;
    sp = sparseness(d.weights_on_msn_from_hvc');
    meansp(iii) = mean(sp);
    hist(sp, bins)
    xlabel('Sparseness')
    ylabel('Number of HVC bins')
    
    subplot(1,4,4)
    se = selectivity(d.weights_on_msn_from_hvc');
    meanse(iii) = nanmean(se);
    hist(se,bins)
    xlabel('Selectivity')
    ylabel('Number of MSNs')
    
    pause
end

figure
subplot(3,1,1)
semilogx(c, meanse)
xlabel('Stability Factor')
ylabel('Mean Selectivity')

subplot(3,1,2)
semilogx(c, meansp)
xlabel('Stability Factor')
ylabel('Mean Sparseness')

subplot(3,1,3)
semilogx(c, endingmse)
xlabel('Stability Factor')
ylabel('Mean Squared Error at End of Learning')