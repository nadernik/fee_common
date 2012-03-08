function competition_and_relearning(do_simulations)
%COMPETITION_AND_RELEARNING learn a new template with initial conditions of
%an already learned song

if exist('do_simulations', 'var') && (do_simulations == 1)
    disp('Doing simulations...')
    
    % With competition
    load('c:\stetner\data\figures\xmodel\competition.mat')
    old_template = template;
    t = linspace(0, 2*pi, motif_steps);
    template = 2*cos(t);
    assert(~all(template == old_template))
    sparsemodel_run;
    save('c:\stetner\data\figures\xmodel\competition_relearnt.mat')
    
    % Without competition
    load('c:\stetner\data\figures\xmodel\nocompetition.mat')
    old_template = template;
    t = linspace(0, 2*pi, motif_steps);
    template = 2*cos(t);
    assert(~all(template == old_template))
    sparsemodel_run;
    save('c:\stetner\data\figures\xmodel\nocompetition_relearnt.mat')
end

%% Load data
comp = load('c:\stetner\data\figures\xmodel\competition_relearnt.mat');
nocomp = load('c:\stetner\data\figures\xmodel\nocompetition_relearnt.mat');

%% Show image of weights after relearning
figure
subplot(2,1,1)
weightimage(comp)
subplot(2,1,2)
weightimage(nocomp)

%% Show template, bias, and example MSNs after relearning
figure
mlist = [50, 80, 160];
msn_examples(comp, mlist);
figure
msn_examples(nocomp, mlist);

%% Show learning rates during relearning
figure
plotmsebias(comp)
hold all
plotmsebias(nocomp)
legend({'Competition', 'No competition'})