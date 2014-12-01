function [pshared,SharedPhase] = mygraph_elm(w, xdyn, m, makeplot)
% A = w;
% n=length(A);
% A(A<.05) = 0;

% first exclude all neurons that don't fire at a consistent phase
x = zeros(1,size(w,1));
y = zeros(1,size(w,1));
for ni = 1:size(w,1)
    tmp = find(xdyn(ni,:)); 
    if length(tmp)>2 & max(diff(mod(tmp-1,m)))==0 % fire at least 3 times, and consistently fire at same phase
        x(ni) = mode(mod(tmp-1,m));
    else
        if numel(tmp)== 40 % persistent seed neurons
            x(ni) = 0; 
        else
            x(ni) = NaN;
        end
    end
end
indkeep = ~isnan(x); 
y = y(indkeep); 
w = w(indkeep,indkeep); 
xdyn = xdyn(indkeep,:); 
x = x(indkeep); 


trainingset1 = 1:(m/2);
trainingset2 = (m/2+1):m;

tmp1 = (xdyn(trainingset1(1),:));
tmp2 = (xdyn(trainingset2(1),:));

if sum(tmp1)~=sum(tmp2) % deal with bout onset exception
    tind1 = 1:m;
    tind2 = (m+1):2*m;
else
    tind1 = tmp1(1)==1;
    tind2 = tmp2(1)==1; 
    for ti = 2:length(tmp1)
        if tmp1(ti)
            tind2(ti) = mod(tind2(ti-1)+1,2);
            tind1(ti) = mod(tind1(ti-1)+1,2);
            if tmp2(ti)
                tind2(ti) = mod(tind2(ti)+1,2);
                tind1(ti) = mod(tind1(ti)+1,2);
            end
        else
            if tmp2(ti)
                tind2(ti) = mod(tind2(ti-1)+1,2);
                tind1(ti) = mod(tind1(ti-1)+1,2);
            else
                tind1(ti) = tind1(ti-1);
                tind2(ti) = tind2(ti-1);
            end
        end
    end
    tind1 = find(tind1); 
    tind2 = find(tind2);
end
% tind1 = 1:(tmp1(1)+m-1);%1:m; %
% tind2 = tmp2(1):(tmp2(1)+m-1);%(m+1):2*m; % 
FireDur1 = (sum(xdyn(:,tind1),2))>0; 
FireDur2 = (sum(xdyn(:,tind2),2))>0;

% tmp1 = find(xdyn(trainingset1(1),:));
% tmp2 = find(xdyn(trainingset2(1),:));
% tind1 = 1:(tmp1(1)+m-1);%1:m; %
% tind2 = tmp2(1):(tmp2(1)+m-1);%(m+1):2*m; % 
% FireDur1 = (sum(xdyn(:,tind1),2)); 
% FireDur2 = (sum(xdyn(:,tind2),2));

Specific1 = FireDur1&~FireDur2;
Specific2 = FireDur2&~FireDur1; 
Shared = (FireDur1&FireDur2); 
% finding phases of shared neurons... now excluding neurons without
% consistent phase, so don't use for phase analysis
indshared = find(Shared);
SharedPhase = [];
for i = 1:sum(Shared)
    tmp = find(xdyn(indshared(i),:)); 
    tmp1 = intersect(tmp,tind1);
    tmp2 = intersect(tmp,tind2);
    SharedPhase(i,1) = tmp1(1);
    SharedPhase(i,2) = tmp2(1)-m; 
end
%%
c1 = zeros(1,length(x));
c2 = zeros(1,length(x));
for ni = 1:size(w,1)
    tmp = find(xdyn(ni,:)); 
    if length(tmp)>0 & max(diff(mod(tmp-1,m)))==0 % consistently fire at same phase
        if sum(w(ni,:))>0
            c1(ni) = sum(w(ni,Specific1))/sum(w(ni,:));%+(sum(Specific1)==0);
            c2(ni) = sum(w(ni,Specific2))/sum(w(ni,:));%+(sum(Specific2)==0);
        end
        %y(ni) = c1(ni)-c2(ni); 
    else
        x(ni) = NaN;
    end
end
ux = unique(x); 
ux = ux(~isnan(ux));
y1 = zeros(1,size(w,1)); 
for ui = 1:length(ux)
    indshared = (x==ux(ui))&Shared';
    ind1 = (x==ux(ui))&Specific1'; 
    ind2 = (x==ux(ui))&Specific2';
    [~,y1(indshared)] = sort(y(indshared));
    tocentershared = 1+(numel(find(indshared))-1)/2;
    y1(indshared) = y1(indshared)-tocentershared;
    [~,y1(ind1)] = sort(y(ind1));
    y1(ind1) = y1(ind1) + (numel(find(indshared)))/2;%y1(ind1)-numel(find(ind1))/2+ sum(x==ux(ui))/4 + (numel(find(indshared)))/4;
    [~,y1(ind2)] = sort(y(ind2));
    y1(ind2) = y1(ind2) -numel(find(ind2))-1- (numel(find(indshared)))/2;%y1(ind2) -numel(find(ind2))/2-1- sum(x==ux(ui))/4- (numel(find(indshared)))/4;
end
y1 = y1+0*(Specific1'-Specific2');

if makeplot
    %clf; 
    hold on
    pltprct = 0; 
    wplot = w-prctile(w(:),pltprct);
    wplot(wplot<0) = 0;
    wplot = wplot/max(wplot(:));
    jitter = .05; 
    x = x+jitter*randn(1,length(x));
    y1 = y1+jitter*randn(1,length(x)); 
    for i = 1: length(w)
        for j = 1:length(w)
            if wplot(j,i)>0
                ff = x(i)<=x(j); 
                longrange = abs(x(i)-x(j))>2; 
                if ff & ~longrange
                    C = ones(1,3)-wplot(j,i)*ones(1,3);
                    plot([x(i), x(j)], [y1(i),y1(j)], 'color', C)
                else
                    C = ones(1,3); 
                end
                
            end
        end
    end
    if max(c1)>0
        m1 = max(c1);
    else
        m1 = 1;
    end
    if max(c2)>0
        m2 = max(c2);
    else
        m2 = 1;
    end
    msize = 5;

    for pli = 1:length(x)
        plot(x(pli),y1(pli), 'marker', '.', 'color', [c1(pli)'/m1 c2(pli)'/m2 0], 'markersize', msize)
    end
    xlim([-1 m+1])
    if sum(Specific1)>0
        plot(x(trainingset1),y1(trainingset1), 'r.', 'markersize', msize)
        plot(x(trainingset2),y1(trainingset2), 'g.', 'markersize', msize)
    else
        plot(x([trainingset1 trainingset2]),y1([trainingset1 trainingset2]), 'm.', 'markersize', msize)
    end
    
    axis tight; 
    xlim([-.2 8.2]);
    axis off; 
    set(gcf, 'color', [1 1 1],'papersize', [4 4], 'paperposition', [0 0 4 4])
    set(gca, 'color', 'none')
end
pshared = sum(Shared)/(sum(Shared)+sum(Specific1)+sum(Specific2))*100;