function figure_template_vs_learning_rate(do_simulations)
% Question: Do different templates have different learning rates?
% Answer: YES!
% Method: Run model with different sinusoids as the template vary the
% frequency of sinusoids and see how long it takes to learn each template

harmonic_list = 1:16;
filename = @(h) sprintf('c:\\stetner\\data\\xmodel\\template_complexity\\harmonic%02.f.mat', h);

if exist('do_simulations', 'var') && do_simulations
    for ih = 1:length(harmonic_list)
        h = harmonic_list(ih);
        simulation_helper(h, filename(h));
    end
end

for ih = 1:length(harmonic_list)
    d = load(filename(harmonic_list(ih)), 'template', 'bias');
    mse(:, ih) = xmodel_calculate_mse(d.bias, d.template);
    legendstr{ih} = int2str(harmonic_list(ih));
end

plot(mse)
legend(legendstr)

% does the template affect learning speed?
function simulation_helper(harmonic, fname)
    xmodel_parameters
    t = 1:motif_steps;
    template(1, :) = 10*sin(2 * pi * harmonic / motif_steps * t);
    baseline_motifs = 100;
    learning_motifs = 10000;
    ending_motifs = 0;
    xmodel_initialize
    xmodel_run
    xmodel_calculate_bias
    save(fname)

