function learning_simple_song(do_simulations)
datapath = 'c:\stetner\data\figures\xmodel\';


if exist('do_simulations', 'var') && do_simulations
    disp('simulating')
    xmodel_parameters_simplesong
    xmodel_initialize
    xmodel_run
    xmodel_calculate_bias
    filename = sprintf('%slearning_simple_song%s.mat', datapath, datestr(now, 30));
    save(filename);
end

% load latest data file
files = dir([datapath 'learning_simple_song*.mat']);
filename = files(end).name
load([datapath filename])
arrowlen = 20;

plottrials = baseline_motifs + [10, 70, learning_motifs];
colors = linspace(0.5, 0, length(plottrials))' * ones(1,3);
figure
hold all
for ii = 1:length(plottrials)
    plot(bias(:,plottrials(ii)), 'Color', colors(ii,:))
end
plot(template, 'Color', 'b')

figure
e = bias - template' * ones(1,total_motifs);
mse = mean(e.^2);
plot(mse(baseline_motifs+1:end))
hold on
for ii = 1:length(plottrials) % place an arrow marking each trial that was plotted in A
    xx = plottrials(ii) * ones(1,2);
    yy = mse(xx) + [arrowlen 0];
   
    [nx, ny] = dsxy2figxy(xx- baseline_motifs, yy);
    annotation('arrow', nx, ny, 'Color', colors(ii,:))
end

figure
imagesc(bias')

figure
subplot(2,1,1)
hold all
ymax = globalmax(msn_output(:,:,end));
plot((bias(:,end)), '--', 'Color', [0 0 .6], 'LineWidth', 4)
plot((template), 'Color', [.6 0 .6], 'LineWidth', 4)

subplot(2,1,2)
hold all
offset=1.5;
for h = 5:10:hvc_units
    p = msn_output(h,:,end) / ymax;
    n = -msn_output(h+hvc_units,:,end)/ymax;
    plot(p - offset, 'Color', [.6 .6 0], 'LineWidth', 3)
    %plot(n - offset, 'r')
    %plot(p+n - offset, 'k')
    offset = offset +1.5;
end
