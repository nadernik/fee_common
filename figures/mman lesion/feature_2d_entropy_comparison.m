function [entropy_tutor, entropy_lesion, axh] = feature_2d_entropy_comparison(vcdb_tutor, vcdb_lesion, xfeat, yfeat)

Nbins = 20;
Npts = 300; %number of points to plot in scatter plots.

%% vcdb arguments can be the filenames of mat files containing the vcdb data structure, or the vcdb data structure itself. if it is a string, treat it as a file name and try to load the vcdb data structure from it.

if ischar(vcdb_tutor)
    temp = load(vcdb_tutor);
    vcdb_tutor = temp.vcdb;
	clear temp
end

if ischar(vcdb_lesion)
    temp = load(vcdb_lesion);
    vcdb_lesion = temp.vcdb;
	clear temp
end

%% get feature data
tutor_x = getsf(vcdb_tutor, xfeat);
tutor_y = getsf(vcdb_tutor, yfeat);

lesion_x = getsf(vcdb_lesion, xfeat);
lesion_y = getsf(vcdb_lesion, yfeat);

%% find max and min values for features across all subjects
all_xfeat = [tutor_x; lesion_x];
all_yfeat = [tutor_y; lesion_y];
         
max_xfeat = max(all_xfeat);
min_xfeat = min(all_xfeat);
max_yfeat = max(all_yfeat);
min_yfeat = min(all_yfeat);

%% scatter plot of features in 2D
figure
axh.scatter_tutor = subplot(1,2,1);
mask = randmask(length(tutor_x), Npts);
scatter(tutor_x(mask), tutor_y(mask), '.')
xlabel(varname2str(xfeat))
ylabel(varname2str(yfeat))
axis square
xlim([min_xfeat, max_xfeat])
ylim([min_yfeat, max_yfeat])
set(gca, 'XTick', [min_xfeat, max_xfeat], 'YTick', [min_yfeat, max_yfeat])
title('Tutor')

axh.scatter_lesion = subplot(1,2,2);
mask = randmask(length(lesion_x), Npts);
scatter(lesion_x(mask), lesion_y(mask), '.')
xlabel(varname2str(xfeat))
ylabel(varname2str(yfeat))
axis square
xlim([min_xfeat, max_xfeat])
ylim([min_yfeat, max_yfeat])
set(gca, 'XTick', [min_xfeat, max_xfeat], 'YTick', [min_yfeat, max_yfeat])
title('Lesion')


%% histogram of features in 2D
xedges = linspace(min_xfeat, max_xfeat, Nbins);
yedges = linspace(min_yfeat, max_yfeat, Nbins);

figure
axh.hist_tutor = subplot(1,2,1);
hdata_tutor = hist2(tutor_x, tutor_y, xedges, yedges);
pcolor(xedges,yedges,hdata_tutor'); colorbar ; axis square tight;
title('Tutor')

axh.hist_lesion = subplot(1,2,2);
hdata_lesion = hist2(lesion_x, lesion_y, xedges, yedges);
pcolor(xedges,yedges,hdata_lesion'); colorbar ; axis square tight;
title('Lesion')

%% Entropy of 2D histograms
N_tutor = sum(hdata_tutor(:));
P_tutor = hdata_tutor ./ N_tutor;
entropy_tutor = -sum(plogp(P_tutor(:)));
fprintf('%g total syllables for tutor.\n', N_tutor)

N_lesion = sum(hdata_lesion(:));
P_lesion = hdata_lesion ./ N_lesion;
entropy_lesion = -sum(plogp(P_lesion(:)));
fprintf('%g total syllables for lesion.\n', N_lesion)

figure
axh.entropy = axes;
bar([entropy_tutor, entropy_lesion])
set(gca, 'XTick', [1 2], 'XTickLabel', {'Tutor', 'Lesion'})