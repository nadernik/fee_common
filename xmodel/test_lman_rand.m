function test_lman_rand(do_simulations)
lmanrandlist = 1:10;
if do_simulations
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
bins = -5:0.25:0;
nocomp = load('c:\stetner\data\figures\xmodel\nocompetition.mat');
for iii = 1:length(lmanrandlist)
    filename = ['c:\stetner\data\sparsemodel\lman_rand_test_' int2str(iii)]
    d = load(filename, 'weights_on_msn_from_hvc', 'bias', 'template', 'competing_msns', 'total_motifs');
    c = load('c:\stetner\code\figures\xmodel\xmodel_color_scheme.mat');

    subplot(2,3,1)
    weightimage(d)
    title(filename)
    
    subplot(2,3,2)
    [h, mse] = plotmsebias(d);
    
    subplot(2,3,3)
    sp   = sparseness(     d.weights_on_msn_from_hvc');
    spnc = sparseness(nocomp.weights_on_msn_from_hvc');
    n   = hist(sp,   bins);
    nnc = hist(spnc, bins);
    stairs(bins, n, '-k')
    hold on
    stairs(bins, nnc, ':k')
    hold off
    xlabel('Sparseness')
    title([int2str(sum(d.competing_msns)) ' msns competing'])
    avgsp(iii) = nanmean(sp);
    
    subplot(2,3,4)
    se   = selectivity(     d.weights_on_msn_from_hvc');
    senc = selectivity(nocomp.weights_on_msn_from_hvc');
    n   = hist(se,   bins);
    nnc = hist(senc, bins);
    stairs(bins, n, '-k')
    hold on
    stairs(bins, nnc, ':k')
    hold off
    xlabel('Selectivity')
    avgse(iii) = nanmean(se);
    
    subplot(2,3,5)
    plot(d.bias(:,end), 'LineWidth', 3, 'Color', c.bias)
    hold on
    plot(d.template, 'LineWidth', 3, 'Color', c.template);
    hold off
    
    
    % Count MSNs that are experiencing competition
    pctcomp(iii) = sum(d.competing_msns) / length(d.competing_msns);
    
    temp = find(mse < 0.5, 1,'first');
    if ~isempty(temp)
        lrate(iii) = temp;
    else
        lrate(iii) = d.total_motifs;
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
ylabel('Trials to reach MSE of 0.5')