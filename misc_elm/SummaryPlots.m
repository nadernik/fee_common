%% testing analyses, from data compiled by datacompilation.mat
clear all; close all; clc
putProj = cell(1,4);
load C:\Users\emackev\Documents\CompiledSinging.mat
D{1} = data.matrix;
putProj{1} = (data.putProj); 
ind{1} = 1:size(D{1},2);%find(~data.Categories{strmatch('L1', data.CatNames)});  %find(data.putProj); 
load C:\Users\emackev\Documents\CompiledTutoring.mat
D{2} = data.matrix_tutoring; 
putProj{2} = (data.putProj); 
ind{2} = 1:size(D{2},2); %find(data.putProj); 
D{3} = data.matrix_artSubsong;
putProj{3} = (data.putProj); 
ind{3} =1:size(D{3},2); %tmp = data.indArtSub(find(data.putProj)); ind{3} = data.indArtSub(tmp>0); %
load C:\Users\emackev\Documents\CompiledHVClesion.mat
D{4} = data.matrix; 
ind{4}  = 1:size(D{4},2); 
labels = {'singing', 'tutoring', 'random syllables', 'singing, HVC lesion'};
grps = []; 
figure(1); clf; hold on; 
Colors = lines(length(D));
dt = data.time(2)-data.time(1); 
tcheck = .15; 
comp = []; 

conds = 1:4; 
D1 = {};L1 = {}; I1 = {}; emptylabels = {};
Colors = Colors(conds,:); 
for i = 1:length(conds)
    D1{i} = D{conds(i)}; 
    L1{i} = labels{conds(i)}; 
    I1{i} = ind{conds(i)}; 
    emptylabels{i} = ''; 
end
D = D1; 
labels = L1; 
ind = I1; 

for i = 1:length(D)
    m = []; 
    f = []; 
    M = D{i};
    M = M(:,ind{i}); 
    T = data.time; 
    M = M(T>=-tcheck&T<=tcheck,:); 
    T = T(T>=-tcheck&T<=tcheck,:);
    MU = repmat(mean(M,1), size(M,1),1); 
    %M = (M-MU); 
    %imagesc(M); 
    for ni = 1:size(M,2)
        M(:,ni) = smooth(M(:,ni), 5); 
        tmp = M(:,ni); 
        tmp = zscore(tmp);  
        M(:,ni) = tmp; 
        [n x] = max(abs(tmp));
%         tmp1 = tmp; tmp1(tmp<0) = 0; 
%         tmp2 = round(sum(tmp1.*(1:numel(tmp1))')/sum(tmp1))
        tmp2 = find((tmp-mean(tmp))>=2*std(tmp)); %find(abs(tmp)>n/2); %
        sum(abs(diff(tmp2))>80);
        if length(tmp2)>0 & sum(abs(diff(tmp2))>.01/dt) == 0 % exclude ...
            % neurons which have multiple regions >2std above mean separated by 10ms
            % and also excluding neurons that never deviate by 2std
            m(ni) = (T(tmp2(1)));
        else
            m(ni) = 100;
        end
        %[n x] = max(abs(diff(M(:,ni))));%max(M(:,ni));
        %m(ni) = T(x); 
        f(ni) = mean(M(:,ni)); 
    end
    indkeep = find(m~=100); 
    m = m(indkeep);% 
    M = M(:,indkeep); 
    if length(putProj{i})>1
        putProj{i} = putProj{i}(indkeep); 
    end
    M1{i} = M; 
    m1{i} = m; 
    grps = [grps i*ones(1,length(m))];
    comp = [comp m]; 
    f1{i} = f; 
    figure(1); a = subplot(2,1,2); hold on; 
    plot(T, M,'Color', Colors(i,:)); 
    plot([0 0], [min(min(M))-std(std(M)) max(max(M))+std(std(M))], 'k', 'linewidth', 2); axis tight
    xlabel('time to syllable onset (s)'); ylabel('normalized rate (au)')
    [nh,xh] = hist(m, -.1:.03:.1);
    nh = nh/sum(nh); 
    %plot(xh,nh, 'Color', Colors(i,:)); shg; 
    %bar(xh,nh, 'edgeColor', Colors(i,:)); shg
    %plot(m,f, '.', 'Color', Colors(i,:)); 
    b = subplot(2,1,1); hold on; axis off
    %bar(i,mean(m),'edgeColor', Colors(i,:));
    %errorbar(i,mean(m), std(m), 'Color', Colors(i,:));
    %boxplot(m, 'Color', Colors(i,:), 'label', labels{i}); 
    h(i) = plot(m,i*ones(1,length(m))+(rand(1,length(m))-.5)/4, '.','Color', Colors(i,:), 'markersize',10);
    text(T(1), i, labels{i},'Color', Colors(i,:))
    %ylim([-.15 .15])
end
linkaxes([a b], 'x')
boxplot(comp, grps, 'color', Colors, 'orientation', 'horizontal', 'labelorientation', 'inline',  'labels', emptylabels);
%legend(h, labels);
plot([0 0], [0 length(D)+1], 'k', 'linewidth', 2)
xlim([T(1) T(end)])
set(gcf, 'Color', [1 1 1], 'papersize', [5 4], 'paperposition', [0 0 5 4])
% total number of neurons is 96: 50 during singing, 41 during tutoring
% (and some during artificial subsong), and 5 during HVC lesion

%% 


for i = 1:length(D)
    figure(i); clf; hold on
    [~,ind] = sort(m1{i}); 
    [~,unsort] = sort(ind); 
    
%     plot(repmat(T,1,size(M1{i},2)), M1{i}(:,ind)+repmat(1:length(ind),length(T),1))
%     %ValatCrossing = sum(M1{i}(round(m1{i}(ind)/dt-T(1)/dt),ind).*eye(length(ind)));
%     ValatCrossing = [];
%     for j = 1:length(ind)
%         ValatCrossing(j) = M1{i}(round(m1{i}(ind(j))/dt-T(1)/dt),ind(j)); 
%     end
%     plot(m1{i}(ind),ValatCrossing + (1:length(ind)),'k.')
    title(labels{i})
    Mplot = [M1{i}(:,ind)' max(abs(M1{i}(:)))*ones(length(ind),1) -1*max(abs(M1{i}(:)))*ones(length(ind),1)];
    Tplot = [T; T(end)+dt; T(end) + 2*dt]; 
    imagesc(Mplot, 'xdata', Tplot)
    plot([0 0], [.5 length(ind)+.5], 'r', 'linewidth', 2); axis tight
    if length(putProj{i})>0
%         projInd = zeros(1,length(ind)); 
%         projInd(putProj{i}) = 1; 
        projInd = putProj{i}(ind)'; 
        plot(0*ones(1,length(ind)), projInd.*(1:length(ind)), 'r.', 'markersize', 15)
    end
    cvec = [zeros(128,1);(1:128)'/128];
    CMAP = [cvec cvec+flipud(cvec) flipud(cvec)];
    colormap(CMAP)
    set(colorbar, 'ytick', [-2 0 2], 'yticklabel', {'-2 std', 'mean', '+2 std'})
    set(gca, 'ytick', 0:10:length(M1{i}))
    ylabel('unit #')
    xlim([T(1) T(end)])
    xlabel('time (s) before syllable onset')
    set(gcf, 'Color', [1 1 1], 'papersize', [7.5 4], 'paperposition', [0 0 7.5 4])
    %figure(i+4); plot(m1{i})
end