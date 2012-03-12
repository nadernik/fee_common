function test_inhibition_strength(do_simulations)

inhibstrs = [0, logspace(-4,-2,11)];

savefile = @(n) ['c:\stetner\data\sparsemodel_inhibition_strength_test_' int2str(n) '.mat'];

bins = -5:0.25:0; % for histograms of selectivity and sparseness

%% Do simulations if requested
if exist('do_simulations', 'var') && (do_simulations == 1)
    for iii = 1:length(inhibstrs)
        fprintf('Starting run %g of %g \n', iii, length(inhibstrs));
        
        % Clear all simulation variables, but keep the loop variables
        save temp.mat inhibstrs iii savefile bins
        clear all
        load temp.mat
        
        % Run the model
        sparsemodel_parameters
        lman_rand = 2; % At Michale's request, use a low level of randomness in LMAN-X connections
        inhibition_strength = inhibstrs(iii); % Different inhibition strength on every iteration
        sparsemodel_initialize
        sparsemodel_run
        
        
        save(savefile(iii))
    end
end

%% Show info for each simualtion and aggregate data for summary plots

nc = @(n) round(interp1q(linspace(0,length(inhibstrs),64), (1:64)', n));
mycolormap = colormap('jet');
msecolor = @(n) mycolormap(nc(n),:);

figure(111)
d = load('c:\stetner\data\sparsemodel\lman_rand_test_5.mat', ...
    'bias', 'template');
h = plotmsebias(d);
set(h, 'Color', msecolor(0));
hold on


for iii = 1:length(inhibstrs)
    d = load(savefile(iii), 'weights_on_msn_from_hvc', 'bias', 'template', 'competing_msns');

    figure(222)
    subplot(2,2,1)
    weightimage(d)
    title(savefile(iii))
    
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
    
    figure(111)
    h = plotmsebias(d);
    set(h, 'Color', msecolor(iii));
    
    %pause
end

%% Summary plots
figure
plot(inhibstrs, avgse)
hold all
plot(inhibstrs, avgsp)
legend({'Selectivity', 'Sparseness'})
xlabel('Inhibition Strength')
ylabel('Sparseness or Selectivity')

figure
plot(inhibstrs, pctcomp)
xlabel('Inhibition Strength')
ylabel('Fraction MSNs competing at end of 5000 iterations')

figure
plot(inhibstrs, lrate)
xlabel('Inhibition Strength')
ylabel('Trials to reach MSE of 0.2')