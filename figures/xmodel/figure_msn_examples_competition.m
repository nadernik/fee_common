function figure_msn_examples_competition
% Finds MSNs that are active in both learning and relearning conditions

th = .2; % threshold. good msns must have sum of weights greater than this threshold.
varnames = {'weights_on_msn_from_hvc', 'template', 'bias', 'msn_output'};

% d(1) = load('c:\stetner\data\figures\xmodel\competition.mat', varnames{:}); 
% d(2) = load('c:\stetner\data\figures\xmodel\competition_relearnt.mat', varnames{:});

d(1) = load('c:\stetner\data\figures\xmodel\nocompetition.mat', varnames{:});
d(2) = load('c:\stetner\data\figures\xmodel\nocompetition_relearnt.mat', varnames{:});


mgood = find_good_msns(d);

while true
    m = mgood(randsample(length(mgood), 3));
    subplot(1,2,1)
    msn_examples(d(1), m)
    subplot(1,2,2)
    msn_examples(d(2), m)
    title(num2str(m))
    pause
end
    

function allgood = find_good_msns(d)
allgood = 1:300;
for n = 1:length(d)
    newgood = find(sum(d(n).weights_on_msn_from_hvc, 2) > th);
    allgood = intersect(allgood, newgood);
end
end
end

