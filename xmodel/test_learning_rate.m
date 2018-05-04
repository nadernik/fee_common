function test_learning_rate(do_simulations)
filename = @(n) ['c:\stetner\data\sparsemodel\learning_rate_test_' int2str(n)];
colorscheme_file = 'c:\stetner\code\figures\xmodel\xmodel_color_scheme.mat';
LRfactor = logspace(-1.5,1.5, 11);
if do_simulations
    for iii = 1:length(LRfactor)
        save temp.mat iii LRfactor filename
        clear all
        load temp.mat
        sparsemodel_parameters
        msn_learning_rate = msn_learning_rate .* LRfactor(iii)
        sparsemodel_initialize
        sparsemodel_run
        save(filename(iii))
    end
end
%%
bins = -5:0.25:0;
colorscheme_file = 'c:\stetner\code\figures\xmodel\xmodel_color_scheme.mat';
for iii = 1:length(LRfactor)
    d = load(filename(iii), 'weights_on_msn_from_hvc', 'bias', 'template', 'competing_msns', 'total_motifs', 'msn_learning_rate');
    c = load(colorscheme_file);

    subplot(2,3,1)
    weightimage(d)
    title(filename(iii))
    
    subplot(2,3,2)
    [h, mse] = plotmsebias(d);
    
    subplot(2,3,3)
    sp = sparseness(d.weights_on_msn_from_hvc');
    hist(sp, bins)
    xlabel('Sparseness')
    avgsp(iii) = nanmean(sp);
    
    subplot(2,3,4)
    se = selectivity(d.weights_on_msn_from_hvc');
    hist(se, bins)
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
    
    msn_learning_rate(iii) = d.msn_learning_rate;
    
    pause
end

%%
figure
semilogx(msn_learning_rate, avgse)
hold all
semilogx(msn_learning_rate, avgsp)
legend({'Selectivity', 'Sparseness'})
xlabel('Learning Rate')
ylabel('Sparseness or Selectivity')

figure
semilogx(msn_learning_rate, pctcomp)
xlabel('Learning Rate')
ylabel('Fraction MSNs competing at end of 5000 iterations')

figure
semilogx(msn_learning_rate, lrate)
xlabel('Learning Rate')
ylabel('Trials to reach MSE of 0.5')