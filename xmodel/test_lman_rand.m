function test_lman_rand(do_simulations)
if do_simulations
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
end
%%
lmanrandlist = 1:10;
bins = -5:0.25:0;
for iii = 1:length(lmanrandlist)
    filename = ['c:\stetner\data\sparsemodel\lman_rand_test_' int2str(iii)]
    d = load(filename, 'weights_on_msn_from_hvc', 'bias', 'template', 'competing_msns');

    subplot(2,2,1)
    weightimage(d)
    title(filename)
    
    subplot(2,2,2)
    [h, mse] = plotmsebias(d);
    
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
    
    % Count MSNs that are experiencing competition
    pctcomp(iii) = sum(d.competing_msns) / length(d.competing_msns);
    
    temp = find(mse < 0.2, 1,'first');
    if ~isempty(temp)
        lrate(iii) = temp;
    else
        lrate(iii) = 5000;
    end
    
    pause
end

%%
figure
plot(lmanrandlist, avgse)
hold all
plot(lmanrandlist, avgsp)
legend({'Selectivity', 'Sparseness'})
xlabel('LMAN-X randomness')
ylabel('Sparseness or Selectivity')

figure
plot(lmanrandlist, pctcomp)
xlabel('LMAN-X randomness')
ylabel('Fraction MSNs competing at end of 5000 iterations')

figure
plot(lmanrandlist, lrate)
xlabel('LMAN-X randomness')
ylabel('Trials to reach MSE of 0.2')