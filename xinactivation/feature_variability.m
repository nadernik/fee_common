function feature_variability(birdname,expername,t0)

% t0 is time of manipulation

% list of features to analyze
P.sf_list = {'mean_pitch','std_pitch'};
% optional plots to show
P.show_more_plots = true;
P.rootdir = 'c:\stetner\data';
P.cluster = 1;
P.prefix = 'all';

%% Load vectorClust data (most of this is borrowed from vcQuickCluster.m)


%Get all the relevant files.
fileSearch = [P.rootdir, filesep, birdname, filesep, birdname, '_',P.prefix,'_misc_', expername, '*'];
dFiles = dir(fileSearch);

sf_all = zeros(0,length(P.sf_list));
t_all = [];
for(nFile = 1:length(dFiles))
    
    %load data from processed annotation file
    searchString = [P.rootdir, filesep, birdname, filesep, strrep(dFiles(nFile).name, '_misc_', '_*_')];
    [v, sf, vf, icn, t, i, sfname, vfname] = vc_imp_ProcessedAnnotationFiles('batch', searchString, false, false, false);
    
    % select only features that we want
    sf_temp = nan(length(v),length(P.sf_list));
    for n_sf = 1:length(P.sf_list)
        idx = strcmp(P.sf_list{n_sf}, sfname);
        if all(idx == 0)
            warning(['Feature ' P.sf_list{n_sf} ' does not exist']);
            continue
        end
        sf_temp(:,n_sf) = sf(:,idx);
    end
    
    % select only syllables in cluster
    idx_incluster = icn == P.cluster;
    t_temp = t(idx_incluster);
    sf_temp = sf_temp(idx_incluster,:);
    
    % add data from this file to the rest of the data
    t_all = [t_all; t_temp];
    sf_all = [sf_all; sf_temp];
end
%% Results!!

    idx_before = t_all < t0;
    idx_after = t_all > t0;
    
    any(icn ~= -1)%%%DEBUG
    
% for each feature we are interested in
for n_sf = 1:length(P.sf_list)
    if P.show_more_plots

        % distributions
        figure(2*n_sf-1 + 200)
        hist(sf_all(idx_before,n_sf))
        hold on
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','k')
        set(h,'FaceAlpha',0.5)
        hist(sf_all(idx_after,n_sf))
        h = findobj(gca,'Type','patch','-and','FaceAlpha',1);
        set(h,'FaceColor','r')
        set(h,'FaceAlpha',0.5)
        xlabel(P.sf_list{n_sf},'FontSize',20)
        ylabel('Count','FontSize',20)
        hold off
        
        % time course
        figure(2*n_sf + 200)
        time_in_hours = (t_all(idx_before) - t0) * 24;
        scatter(time_in_hours,sf_all(idx_before,n_sf),'k')
        hold on
        time_in_hours = (t_all(idx_after ) - t0) * 24;
        scatter(time_in_hours,sf_all(idx_after ,n_sf),'r')
        hold off
        xlabel('time','FontSize',20)
        ylabel(P.sf_list{n_sf},'FontSize',20)
    end
    
    fprintf(1,'Feature: %s\nBefore: %g ± %g\nAfter: %g ± %g\n\n', ...
        P.sf_list{n_sf}, ...
        mean(sf_all(idx_before,n_sf)), std(sf_all(idx_before,n_sf)), ...
        mean(sf_all(idx_after ,n_sf)), std(sf_all(idx_after ,n_sf)))
end