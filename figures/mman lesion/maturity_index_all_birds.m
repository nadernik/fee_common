clear all

%%
dbase_file_names = {'C:\stetner\data\tutors\Cage 44\LBlue18(current)\2084\bouts\analysis_selected.mat', ...
    'c:\stetner\data\mman lesion\2296\2313\bouts\analysis_selected.mat'};
file_nums = {1:107, 1:282};
[mi_2296, axh_2296] = compare_maturity_index(dbase_file_names, file_nums);
title('2296')
set(gca, 'XTick', [1 2], 'XTickLabel', {'Tutor', 'Lesion'})

%%
dbase_file_names = {'c:\stetner\data\tutors\Cage 75\Black256(previous)\undirected\2011-04-20\bouts\analysis_selected.mat', ...
    'c:\stetner\data\mman lesion\2303\2313\bouts\analysis_selected.mat'};
file_nums = {1:101, 1:100};
[mi_2303, axh_2303] = compare_maturity_index(dbase_file_names, file_nums);
title('2303')
set(gca, 'XTick', [1 2], 'XTickLabel', {'Tutor', 'Lesion'})

%% lumped
close all

sem = @(v) std(v) ./ length(v);
mi_lumped_tutor = [mi_2296{1}, mi_2303{1}];
mi_lumped_lesion = [mi_2296{2}, mi_2303{2}];

figure
bar([mean(mi_lumped_tutor), mean(mi_lumped_lesion)])
hold on
errorbar([1 2], [mean(mi_lumped_tutor), mean(mi_lumped_lesion)], [sem(mi_lumped_tutor), sem(mi_lumped_lesion)], '.')
xlim([0.5 2.5])
setticklimy([0 0.4])
set(gca, 'XTickLabel', {'Tutor' 'Lesion'})
ylabel('Maturity index')
axis square

figure
hold on
x = repmat(1, size(mi_2296{1})) + 0.1*(rand(size(mi_2296{1}))-0.5);
scatter(x, mi_2296{1}, 'ob')
scatter(2*x, mi_2296{2}, 'ob')
x = repmat(1, size(mi_2303{1})) + 0.1*(rand(size(mi_2296{1}))-0.5);
scatter(x, mi_2303{1}, 'or')
scatter(2*x, mi_2303{2}, 'or')
setticklimy([0 0.6])
xlim([0.5, 2.5])
set(gca, 'XTick', [1 2], 'XTickLabel', {'Tutor' 'Lesion'})
ylabel('Maturity index')

axis square

%%
% [p, h] = ranksum(mi_lumped_tutor, mi_lumped_lesion);
[h, p] = ttest2(mi_lumped_tutor, mi_lumped_lesion);
if h == 1
    disp('Rejected null hypothesis that maturity index of tutor and lesion are the same.')
    p
else
    disp('Could not reject null hypothesis that maturity index of tutor and lesion are the same')
    p
end

%%
save('c:\stetner\data\mman lesion\maturity_index.mat')