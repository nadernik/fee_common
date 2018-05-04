%% Data is compiled separately in 'datacompilation.m'


%% During tutoring
clear all; close all; 
XLS = importdata('C:/Users/emackev/Documents/NIfDuringTutoring.xlsx');
Fls = XLS.textdata.Sheet1; 

%XLS.data.Sheet1 = XLS.data.Sheet1(1:46,:); 

artSub = XLS.data.Sheet1(:,1); 
putProj = XLS.data.Sheet1(:,2); 
upProj = XLS.data.Sheet1(:,3); 
downProj = XLS.data.Sheet1(:,4); 
Leftovers = (sum(XLS.data.Sheet1(:,2:end),2)==0);
Cats = {upProj downProj Leftovers}; 
CatNames = {'up proj', 'down proj', 'Leftovers'}; 
Colors = [lines(length(Cats)-1); .8*ones(1,3)]; 
figure(1); clf; hold on; title('tutoring') % tut color
figure(2); clf; hold on; title('tutoring') % tut gray
figure(3); clf; hold on; title('artificial subsong') % as color
figure(4); clf; hold on; title('artificial subsong') % as gray
h = []; 

for coni = 1:2 % 1 for tutoring 2 for art subsong
    for cati = 1:length(Cats)
        n = []; 
        x = []; 
        dt = .001;
        timepts = -.2:dt:.3; 
        c = 1; 
        if coni == 1 % tutoring plot
            ind = find(Cats{cati})+1; 
            CatNames{cati} = [CatNames{cati} ', n = ', num2str(numel(ind))];
        else % artificial subsong plot
            ind = intersect(find(Cats{cati}),find(artSub))+1; 
        end
        for fi = 1:length(ind)
            fi = ind(fi);
            bird = Fls{fi,1}; 
            bird = bird(2:end);
            day = Fls{fi,2};
            depth = Fls{fi,3}; 
            if coni == 1 % tutoring plot
                load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'raster'));
            else % artificial subsong plot
                load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'rasteras'));
            end
            times = [];
            for i = 1:numel(trigInfo.eventOnsets{1});
                times = [times; trigInfo.eventOnsets{1}{i}];
            end
            [n1,x1] = hist(times, timepts); 
            n1 = n1/numel(trigInfo.eventOnsets{1});
            %n1 = n1/mean(n1); % normalize
            n1 = smooth(n1,10); x1 = smooth(x1,10); %smooth in dt*10 windows
            n(:,c) = n1; 
            x(:,c) = x1; 
            c = c+1;
        end
        n = n/dt; 
        if length(ind)>0
            if coni == 1 % tutoring plot
                figure(1)
                if issame(ind, find(Leftovers)+1); 
                    h1 = plot(x,n, 'Color', Colors(cati,:)); shg
                    h(cati) = h1(1);
                elseif length(x)>0
                    h(cati) = plot(mean(x,2),mean(n,2), 'Color', Colors(cati,:), 'Linewidth', 2);shg
                    errorpatch(mean(x,2), mean(n,2), std(n'), Colors(cati,:), Colors(cati,:))
                else
                end
                figure(2); hold on
                plot(x,n, 'Color', .8*ones(1,3));
            else % art subsong plot
                figure(3)
                if all(ismember(ind, find(Leftovers)+1)); 
                    h1 = plot(x,n, 'Color', Colors(cati,:)); shg
                    h(cati) = h1(1);
                elseif length(x)>0
                    h(cati) = plot(mean(x,2),mean(n,2), 'Color', Colors(cati,:), 'Linewidth', 2);shg
                    errorpatch(mean(x,2), mean(n,2), std(n'), Colors(cati,:), Colors(cati,:))
                else
                end
                figure(4); hold on
                plot(x,n, 'Color', .8*ones(1,3));
            end
        end
        X{cati,coni} = x; 
        N{cati,coni} = n; 
    end
end

for i = 1:4
    figure(i)
    ylabel('rate (Hz)'); xlabel('time relative to syllable onset(s)'); axis tight
    if mod(i,2) == 1
        legend(h, CatNames)
    end
end

% collecting all the tutoring units to plot...
x = []; 
n = []; 
for i = 1:length(CatNames)
    x = [x X{i,1}];
    n = [n N{i,1}];
end
figure(5); clf;hold on
for ni = 1:size(x,2)
    tmp = smooth(n(:,ni), 5); 
    tmp = (tmp-mean(tmp))/max(tmp); 
    nn(:,ni) = tmp;  
    tmp = tmp(x(:,ni)>-.1&x(:,ni)<.1);
    xtmp = x(x(:,ni)>-.1&x(:,ni)<.1); 
    tmp2 = find(abs(tmp-mean(tmp))>=2*std(tmp));% & x(:,ni)>-.1&x(:,ni)<.1);
    if length(tmp2)>0
        Order(ni) = tmp2(1); 
    else
        Order(ni) = 1; 
    end
    Val(ni) = tmp(Order(ni)); 
    %plot(x(:,ni),n(:,ni)+ni)
end
[~,ind] = sort(Order); 
plot(x,nn(:,ind)+repmat((1:length(Order)), size(nn,1),1))
plot(xtmp(Order(ind)), Val(ind)+(1:length(Order)), 'k.')
xlabel('time (s)')
ylabel('unit (sorted by latency)')


%% During Singing, categories
clear all; close all; clc
XLS = importdata('C:/Users/emackev/Documents/NIfDuringSingingPutProj.xlsx');
Fls = XLS.textdata.Sheet1; 
PutProj = XLS.data.Sheet1(:,1); 
L1 = XLS.data.Sheet1(:,2); 
FastSpiking = XLS.data.Sheet1(:,3); 
T1Proj = XLS.data.Sheet1(:,4); 
T2Proj = XLS.data.Sheet1(:,5); 
T3Proj = XLS.data.Sheet1(:,6); 
T4Proj = XLS.data.Sheet1(:,7); 
Leftovers = (sum(XLS.data.Sheet1,2)==0);
Cats = {L1 FastSpiking T1Proj T2Proj T3Proj T4Proj Leftovers}; 
CatNames = {'L1', 'Fast Spiking', 'T1 Proj', 'T2 Proj', 'T3 Proj', 'T4 Proj', 'Leftovers'}
Colors = [lines(length(Cats)-1); .8*ones(1,3)]; 
figure(1); clf; hold on
figure(2); clf; hold on
h = []; 

for cati = 1:length(Cats)
    n = []; 
    x = []; 
    dt = .001;
    timepts = -.2:dt:.3; 
    c = 1; 
    ind = find(Cats{cati})+1; 
    CatNames{cati} = [CatNames{cati} ', n = ', num2str(numel(ind))];
    for fi = 1:length(ind)
        fi = ind(fi);
        bird = Fls{fi,1}; 
        bird = bird(2:end);
        day = Fls{fi,2};
        depth = Fls{fi,3}; 
        load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'raster'));
        times = [];
        for i = 1:numel(trigInfo.eventOnsets{1});
            times = [times; trigInfo.eventOnsets{1}{i}];
        end
        [n1,x1] = hist(times, timepts); 
        n1 = n1/numel(trigInfo.eventOnsets{1});
        %n1 = n1/mean(n1); % normalize
        n1 = smooth(n1,10); x1 = smooth(x1,10); %smooth in dt*10 windows
        n(:,c) = n1; 
        x(:,c) = x1; 
        c = c+1;
    end
    n = n/dt; 
    figure(1)
    if issame(ind, find(Leftovers)+1); 
        h1 = plot(x,n, 'Color', Colors(cati,:)); shg
        h(cati) = h1(1);
    else
        h(cati) = plot(mean(x,2),mean(n,2), 'Color', Colors(cati,:), 'Linewidth', 2);shg
        errorpatch(mean(x,2), mean(n,2), std(n'), Colors(cati,:), Colors(cati,:))
    end
    figure(2); hold on
    plot(x,n, 'Color', .8*ones(1,3));
    X{cati} = x; 
    N{cati} = n; 
end

for i = 1:2
    figure(i)
    ylabel('rate (Hz)'); xlabel('time relative to syllable onset(s)'); axis tight
    if mod(i,2) == 1
        legend(h, CatNames)
    end
    gcf
    set(gcf, 'Color', [1 1 1], 'papersize', [5 4], 'paperposition', [0 0 5 4])
end

%plotting psth sorted by latency (first time to exceed 2std within 100ms of
%0
% figure(3); clf;hold on
% for ni = 1:size(x,2)
%     tmp = smooth(n(:,ni), 5); 
%     tmp = (tmp-mean(tmp))/max(tmp); 
%     nn(:,ni) = tmp;  
%     tmp = tmp(x(:,ni)>-.1&x(:,ni)<.1);
%     xtmp = x(x(:,ni)>-.1&x(:,ni)<.1); 
%     tmp2 = find(abs(tmp-mean(tmp))>=2*std(tmp));% & x(:,ni)>-.1&x(:,ni)<.1);
%     Order(ni) = tmp2(1); 
%     Val(ni) = tmp(Order(ni)); 
%     %plot(x(:,ni),n(:,ni)+ni)
% end
% [~,ind] = sort(Order); 
% plot(x,nn(:,ind)+repmat((1:length(Order)), size(nn,1),1))
% plot(xtmp(Order(ind)), Val(ind)+(1:length(Order)), 'k.')
% xlabel('time (s)')
% ylabel('unit (sorted by latency)')

% collecting all the singing units to plot...
x = []; 
n = []; 
for i = 1:length(CatNames)
    x = [x X{i}];
    n = [n N{i}];
end
figure(5); clf;hold on
for ni = 1:size(x,2)
    tmp = smooth(n(:,ni), 5); 
    tmp = (tmp-mean(tmp))/max(tmp); 
    nn(:,ni) = tmp;  
    tmp = tmp(x(:,ni)>-.1&x(:,ni)<.1);
    xtmp = x(x(:,ni)>-.1&x(:,ni)<.1); 
    tmp2 = find(abs(tmp-mean(tmp))>=2*std(tmp));% & x(:,ni)>-.1&x(:,ni)<.1);
    if length(tmp2)>0
        Order(ni) = tmp2(1); 
    else
        Order(ni) = 1; 
    end
    Val(ni) = tmp(Order(ni)); 
    %plot(x(:,ni),n(:,ni)+ni)
end
[~,ind] = sort(Order); 
plot(x,nn(:,ind)+repmat((1:length(Order)), size(nn,1),1))
plot(xtmp(Order(ind)), Val(ind)+(1:length(Order)), 'k.')
xlabel('time (s)')
ylabel('unit (sorted by latency)')

%% 

%% testing analyses, from data compiled by datacompilation.mat
clear all; close all; clc
load C:\Users\emackev\Documents\CompiledSinging.mat
D{1} = data.matrix;
ind{1} = 1:size(D{1},2);%find(~data.Categories{strmatch('L1', data.CatNames)});  %find(data.putProj); 
load C:\Users\emackev\Documents\CompiledTutoring.mat
D{2} = data.matrix_tutoring; 
ind{2} = 1:size(D{2},2); %find(data.putProj); 
D{3} = data.matrix_artSubsong;
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
        tmp = (tmp-mean(tmp))/max(tmp);  
        M(:,ni) = tmp; 
        [n x] = max(abs(tmp));
        tmp2 = find(abs(tmp-mean(tmp))>=2*std(tmp)); %find(abs(tmp)>n/2); %
        sum(abs(diff(tmp2))>80);
        if length(tmp2)>0 & sum(abs(diff(tmp2))>.01/dt) == 0 % exclude ...
            % neurons which have multiple regions >2std above mean separated by 10ms
            m(ni) = (T(tmp2(1)));
        else
            m(ni) = 100;
        end
        %[n x] = max(abs(diff(M(:,ni))));%max(M(:,ni));
        %m(ni) = T(x); 
        f(ni) = mean(M(:,ni)); 
    end
    m = m(find(m~=100));% & abs(f)>1))% excluding cells with firing rates less than 1Hz
    size(m)
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
%% svd
% subtract mean
X = data.matrix; 
[n,m] = size(X);
mu=sum(X,2)/m;
MU=repmat(mu,1,m);
Z1=X-MU;
mu=sum(Z1',2)/n;
MU2=repmat(mu,1,n);
Z=(Z1'-MU2)';
%imagesc(Z); shg
% Z = zscore(Z); 
% Z = zscore(Z')';
% svd
Z1 = Z; 
for i = 1:m
    if max(Z(:,i))<max(abs(Z(:,i)))
        Z1(:,i) = -Z1(:,i); 
    end
end
Z = Z1;
[U,S,V] = svd(Z); 
%S(:,3:end) = 0; 
A = U'*Z;
Colors = [lines(length(data.Categories)-1); .8*ones(1,3)]; 
figure(1); clf
hold on
for cati = 1:length(data.Categories)
    ind = find(data.Categories{cati});
    plot(A(1,ind),A(4,ind),'.', 'Color', Colors(cati,:), 'markersize', 20);shg
end
legend(data.CatNames)
figure(2);clf; hold on
plot(data.time,Z1, 'Color', .8*ones(1,3));axis tight; shg
for i = 1:4
    plot(data.time, U(:,i), 'Color', Colors(i,:), 'linewidth', 5)
end
%% kmeans
figure(1); clf;hold on;
k =8; 
Colors = jet(k); 
idx = kmeans(data.matrix',k, 'onlinephase', 'on');
mu = mean(data.matrix); 

D = (data.matrix-repmat(mu,size(data.matrix,1),1));%./repmat(mu,size(data.matrix,1),1); 
for i = 1:k
    M = smooth(mean(D(:,idx == i),2)); 
    S = smooth(std(D(:,idx==i)'));
    errorpatch(data.time, M, S,  Colors(i,:),Colors(i,:))
end
shg

figure(2);clf;  hist(idx)
