function competition(do_simulations)
fcomp1 = 'c:\stetner\data\figures\xmodel\competition.mat';
fcomp2 = 'c:\stetner\data\figures\xmodel\competition_cosine.mat';
fnocomp1 = 'c:\stetner\data\figures\xmodel\nocompetition_sine.mat';
fnocomp2 = 'c:\stetner\data\figures\xmodel\nocompetition_cosine_relearnt.mat';

if exist('do_simulations', 'var') && do_simulations
    disp('Doing simulations')
%     competition_simulate_learning_with_competition(fcomp1)
%     competition_simulate_relearning_with_competition(fcomp1, fcomp2)
%     competition_simulate_learning_without_competition(fnocomp1)
    competition_simulate_relearning_without_competition(fnocomp1,fnocomp2)
end

figure
competition_plots(fcomp1, fcomp2, [59   151   324])
figure
competition_plots(fnocomp1, fnocomp2, [59   151   324])
end

%% Make data with competition
function competition_simulate_learning_with_competition(filename)
sparsemodel_parameters
sparsemodel_initialize
sparsemodel_run
save(filename)
end

%% Relearn with competition
function competition_simulate_relearning_with_competition(oldfile, newfile)
sparsemodel_parameters
t = linspace(0, 2*pi, motif_steps);
template = 10*cos(t);
sparsemodel_initialize
load(oldfile, 'weights_on_msn_from_hvc')
sparsemodel_run
save(newfile)
end

%% Make data without competition
function competition_simulate_learning_without_competition(filename)
sparsemodel_parameters
msn_learning_rate = 1e-6;
competition = 0; % turn off competition
sparsemodel_initialize
sparsemodel_run
save(filename)
end

%% Relearning without competition
function competition_simulate_relearning_without_competition(oldfile, newfile)
sparsemodel_parameters
t = linspace(0, 2*pi, motif_steps);
template = 10*cos(t);
msn_learning_rate = 1e-6; % slow learning rate so things don't explode
competition = 0; % turn off competition
sparsemodel_initialize
load(oldfile, 'weights_on_msn_from_hvc')
sparsemodel_run
save(newfile)
end


function competition_plots(filename_learn, filename_relearn, example_msns)
load(filename_learn)
[weights_on_msn_from_hvc, ord] = sortbybursttime(weights_on_msn_from_hvc, .2);
msn_output = msn_output(ord,:,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot a network  diagram
% On top there will be a row of hvc "super-units" and below that a row of 
% msn units. To keep the diagram easy to read, each hvc super-unit
% represents the connections of five consecutive hvc units. Also, only the
% example MSNs are shown.

% (0) Parameters
wscale = 2; % proportionality constant between weight and line width
d = 0.1; % diameter of units
ymsn = 0; %
yhvc = 1; %

% (1) to make the image readable, pool hvc units so that each hvc circle
% represents the combined activity of 5 consecutive units
for jj = 1:length(example_msns)
    m = example_msns(jj);
    w(jj, :) = sum(reshape(weights_on_msn_from_hvc(m,:), 5, []));
end
% (2) Plot the connections from the hvc super-units to the msn units
subplot(4,1,1)
hold all
hmax = size(w,2);
mmax = size(w,1);
xhvc = @(h) h/hmax*7;
xmsn = @(m) m/mmax*7;
for h = 1:hmax
    for m = 1:mmax
        % for each HVC->MSN synapse, make a line from the HVC unit to the
        % MSN unit.
        if w(m,h) > .6
        width = wscale * w(m, h);
        plot([xhvc(h) xmsn(m)], [yhvc ymsn], 'LineWidth', width)
        end
    end
end

% (3) Draw circles for the units
for h = 1:hmax % draw circles for HVC units
    circle('Center', [xhvc(h) yhvc], 'Diameter', d, 'FaceColor', 'y')
end
for m = 1:mmax % draw circles for MSN units
    circle('Center', [xmsn(m) ymsn], 'Diameter', d, 'FaceColor', 'w')
end

axis equal


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% image of weights after learning
subplot(4,1,2)
imagesc(weights_on_msn_from_hvc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% template, bias, and example msns after learning
subplot(4,1,3)
plot(template, 'Color', [.6, .6, .6])
hold on
xmodel_calculate_bias
plot(bias(:,end-5:end), 'Color', 'k')
chsv = rgb2hsv([1 0 0]);
sat = linspace(.5, 1, length(example_msns));
offset = 15;
for ii = 1:length(example_msns)
    m = example_msns(ii);
    c = hsv2rgb([chsv(1), sat(ii), chsv(3)]);
    plot(10*msn_output(m,:,end)-offset, 'Color', c)
    offset = offset +10;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% image of weights after RElearning
load(filename_relearn)
weights_on_msn_from_hvc = weights_on_msn_from_hvc(ord,:);
msn_output = msn_output(ord,:,:);
% subplot(5,1,4)
% imagesc(weights_on_msn_from_hvc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% template, bias, example msns after RElearning
subplot(4,1,4)
plot(template, 'Color', [.6, .6, .6])
hold on
xmodel_calculate_bias
plot(bias(:,end-5:end), 'Color', 'k')
chsv = rgb2hsv([1 0 0]);
sat = linspace(.5, 1, length(example_msns));
offset = 15;
for ii = 1:length(example_msns)
    m = example_msns(ii);
    c = hsv2rgb([chsv(1), sat(ii), chsv(3)]);
    plot(10*msn_output(m,:,end)-offset, 'Color', c)
    offset = offset +10;
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%
% nsmooth = 20;
% error = bias - template' * ones(1, total_motifs);
% mse = mean(error.^2, 1);
% temp = smooth(mse, nsmooth);
% plot(temp)
% 
% %%
% 
% % distribution of weights
% figure
% stairs()
% 
% % selectivity index
% 
% N = length(p);
% selectivity = 1 + sum(p*log(p)) / log(N);