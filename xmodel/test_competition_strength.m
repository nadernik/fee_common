function test_competition_strength(do_simulations)


faclist = logspace(-2,2,11);

%% Do simulations if requested
if exist('do_simulations', 'var') && (do_simulations == 1)
for iii = 1:length(faclist)
    save temp.mat iii faclist
    clear all
    load temp.mat
    sparsemodel_parameters
    competition_strength = competition_strength * faclist(iii)
    sparsemodel_initialize
    sparsemodel_run
    save(['c:\stetner\data\sparsemodel\competition_strength_test_' int2str(iii)])
end
end

%% Plots

w = zeros(300,50,21);
nocomp = load('c:\stetner\data\figures\xmodel\nocompetition.mat');
for iii = 1:length(faclist)
    d = load(['c:\stetner\data\sparsemodel\competition_strength_test_' int2str(iii)], ...
        'weights_on_msn_from_hvc', 'competition_strength', 'bias', 'template', 'competing_msns', 'msn_output');
    w(:,:,iii) = d.weights_on_msn_from_hvc;
    c(iii) = d.competition_strength;
    
    subplot(2,3,1)
    imagesc(w(:,:,iii))
    title(num2str(c(iii)))
    
    subplot(2,3,2)
    mse = xmodel_calculate_mse(permute(d.bias, [3 1 2]), d.template);
    endingmse(iii) = mse(end);
    plot(mse)
    ylim([-0.2, 3])
    ylabel('Mean Squared Error')
    xlabel('Trials')
    
    subplot(2,3,3)
    bins = -5:0.25:0;
    sp = sparseness(d.weights_on_msn_from_hvc');
    spnc = sparseness(nocomp.weights_on_msn_from_hvc');
    meansp(iii) = nanmean(sp);
    n = hist(sp, bins);
    stairs(bins, n, '-k')
    hold on
    n = hist(spnc, bins);
    stairs(bins, n, ':k')
    hold off
    xlabel('Sparseness')
    ylabel('Number of HVC bins')
    
    subplot(2,3,4)
    se = selectivity(d.weights_on_msn_from_hvc');
    senc = selectivity(nocomp.weights_on_msn_from_hvc');
    meanse(iii) = nanmean(se);
    n = hist(se, bins);
    stairs(bins, n, '-k')
    n = hist(senc, bins);
    hold on
    stairs(bins, n, ':k')
    hold off
    xlabel('Selectivity')
    ylabel('Number of MSNs')
    title([int2str(sum(d.competing_msns)) ' msns competing'])
    
    subplot(2,3,5)
    plot(d.template,':')
    hold on
    plot(d.bias(:,end))
    hold off
    xlabel('Time (ms)')
    ylabel('Song')
    
    subplot(2,3,6)
    msn_examples(d, [100 200 300])
    
    pause
end

figure
subplot(3,1,1)
semilogx(c, meanse)
xlabel('Competition Strength')
ylabel('Mean Selectivity')

subplot(3,1,2)
semilogx(c, meansp)
xlabel('Competition Strength')
ylabel('Mean Sparseness')

subplot(3,1,3)
semilogx(c, endingmse)
xlabel('Competition Strength')
ylabel('Mean Squared Error at End of Learning')