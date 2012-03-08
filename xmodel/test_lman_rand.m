lmanrandlist = 1:10;
for iii = 1:length(lmanrandlist)
    save temp.mat iii lmanrandlist 
    clear all
    load temp.mat
    sparsemodel_parameters
    lman_rand = lmanrandlist(iii);
    sparsemodel_initialize
    sparsemodel_run
    filename = ['c:\stetner\data\sparsemodel\lman_rand_test_' int2str(iii)];
    save(filename)
end

%%
lmanrandlist = 1:10;
bins = -5:0.25:0;
for iii = 1:length(lmanrandlist)
    filename = ['c:\stetner\data\sparsemodel\lman_rand_test_' int2str(iii)]
    d = load(filename, 'weights_on_msn_from_hvc', 'bias', 'template');

    subplot(2,2,1)
    weightimage(d)
    
    subplot(2,2,2)
    plotmsebias(d)
    
    subplot(2,2,3)
    sp = sparseness(d.weights_on_msn_from_hvc');
    hist(sp, bins)
    xlabel('Sparseness')
    avgsp(iii) = nanmean(sp);
    
    subplot(2,2,4)
    se = selectivity(d.weights_on_msn_from_hvc');
    hist(se, bins)
    xlabel('Selectivity')
    avgse(iii) = nanmean(se);
    
    %pause
end

%%
figure
plot(lmanrandlist, avgse)
hold all
plot(lmanrandlist, avgsp)
legend({'Selectivity', 'Sparseness'})