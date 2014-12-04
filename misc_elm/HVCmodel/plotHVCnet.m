function plotHVCnet(w, xdyn, m, trainingNeurons, PlottingParams)
% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

if length(PlottingParams) == 0; % set PlottingParams = [] to use defaults
    PlottingParams.msize = 5;
    PlottingParams.linewidth = 1; 
    PlottingParams.Syl1Color = [1 0 0]; 
    PlottingParams.Syl2Color = [0 0 1];
    PlottingParams.ProtoSylColor = [1 0 1]; 
    PlottingParams.pltprct = 0; % plot connections > this percentile
end
msize = PlottingParams.msize;
linewidth = PlottingParams.linewidth;
Syl1Color = PlottingParams.Syl1Color;
Syl2Color = PlottingParams.Syl2Color;
ProtoSylColor = PlottingParams.ProtoSylColor;
pltprct = PlottingParams.pltprct; 

Latency = findHVClatency(xdyn, m, trainingNeurons);
% first exclude all neurons that don't fire at a consistent phase
cla; hold on
x = zeros(1,size(w,1));
y = zeros(1,size(w,1));
for ni = 1:size(w,1)
    if Latency{1}.FireDur(ni)|Latency{2}.FireDur(ni) % if it fired during either syll
        if (Latency{1}.FireDur(ni)&Latency{2}.FireDur(ni)) % if it fired during both sylls
            if (Latency{1}.mode(ni)==Latency{2}.mode(ni)) % if fired during both sylls at same phase
                x(ni) = Latency{1}.mode(ni);
            else % exclude from plot if different phases for both sylls
                x(ni) = NaN;
            end
        elseif Latency{1}.FireDur(ni) % if it fired during syll 1 
            x(ni) = Latency{1}.mode(ni);
        else % fired during syll 2 only
            x(ni) = Latency{2}.mode(ni);
        end
    else % if it fired during neither syll
        x(ni) = NaN;
    end
%     tmp = find(xdyn(ni,:)); 
%     if length(tmp)>2 & sum(diff(mod(tmp-1,m))~=0)<length(tmp)/4 % fire at least 3 times, and mostly at same phase
%         x(ni) = mode(mod(tmp-1,m));
%     else
%         if numel(tmp)== 40 % persistent seed neurons
%             x(ni) = 0; 
%         else
%             x(ni) = NaN;
%         end
%     end
end
indkeep = ~isnan(x); 
y = y(indkeep); 
w = w(indkeep,indkeep); 
xdyn = xdyn(indkeep,:); 
x = x(indkeep); 
ux = unique(x); 

trainingset1 = trainingNeurons{1}.nIDs;
trainingset2 = trainingNeurons{2}.nIDs; 
tind1 = find(trainingNeurons{1}.tind);
tind2 = find(trainingNeurons{2}.tind);
% for ni = 1:length(x)
%     FireDur1(ni) = sum(xdyn(ni,tind1(mod(tind1-1,m)==x(ni))),2)>1; % did it fire at the correct phase in syl 1 at least twice?
%     FireDur2(ni) = sum(xdyn(ni,tind2(mod(tind2-1,m)==x(ni))),2)>1;
% end
FireDur1 = Latency{1}.FireDur(indkeep); 
FireDur2= Latency{2}.FireDur(indkeep); 

Specific1 = FireDur1&~FireDur2;
Specific2 = FireDur2&~FireDur1; 
Shared = (FireDur1&FireDur2); 
indshared = find(Shared);
%%
c1 = zeros(1,length(x));
c2 = zeros(1,length(x));
for ni = 1:size(w,1)
    tmp = find(xdyn(ni,:)); 
    if sum(w(ni,:))>0
        c1(ni) = sum(w(ni,Specific1))/sum(w(ni,:));
        c2(ni) = sum(w(ni,Specific2))/sum(w(ni,:));
    end
    y(ni) = c1(ni)-c2(ni);
end

y1 = zeros(1,size(w,1)); 
for ui = 1:length(ux)
    indshared = (x==ux(ui))&Shared;
    ind1 = (x==ux(ui))&Specific1; 
    ind2 = (x==ux(ui))&Specific2;
    [~,y1(indshared)] = sort(y(indshared));
    tocentershared = 1+(numel(find(indshared))-1)/2;
    y1(indshared) = y1(indshared)-tocentershared;
    [~,y1(ind1)] = sort(y(ind1));
    y1(ind1) = y1(ind1) + (numel(find(indshared)))/2;
    [~,y1(ind2)] = sort(y(ind2));
    y1(ind2) = y1(ind2) -numel(find(ind2))-1- (numel(find(indshared)))/2;
end
y1 = y1+0*(Specific1-Specific2);

cla; hold on

wplot = w-prctile(w(:),pltprct);
wplot(wplot<0) = 0;
wplot = wplot/max(wplot(:));
jitter = .05; 
x = x+jitter*randn(1,length(x));
y1 = y1+jitter*randn(1,length(x)); 
% trying to plot w in order from weakest to strongest
n = size(wplot,1); 
js = repmat((1:n)',1,n); 
is = repmat((1:n),n,1); 
isVec = is(:);
jsVec = js(:); 
wVec = wplot(:); 
[wSort,indSort] = sort(wVec, 'ascend'); 

for k = 1:length(wSort)
    i = isVec(indSort(k)); 
    j = jsVec(indSort(k)); 
    if wplot(j,i)>0
        ff = x(i)<=x(j); 
        longrange = abs(x(i)-x(j))>2; 
        loopback = (round(x(j)) == round(max(x)))&(round(x(i)) == round(min(x)));
        if (ff & ~longrange)|loopback
            C = ones(1,3)-wplot(j,i)*ones(1,3);
            plot([x(i), x(j)], [y1(i),y1(j)], 'color', C, 'linewidth', linewidth)
        end
    end
end


% for i = 1: length(w)
%     for j = 1:length(w)
%         if wplot(j,i)>0
%             ff = x(i)<=x(j); 
%             longrange = abs(x(i)-x(j))>2; 
%             if ff & ~longrange
%                 C = ones(1,3)-wplot(j,i)*ones(1,3);
%                 plot([x(i), x(j)], [y1(i),y1(j)], 'color', C, 'linewidth', linewidth)
%             end
%         end
%     end
% end
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



for pli = 1:length(x)
    tmpC = c1(pli)'/m1*Syl1Color+c2(pli)'/m2*Syl2Color; 
    plot(x(pli),y1(pli), 'marker', '.', 'color', tmpC, 'markersize', msize)
end

xlim([-1 m+1])

if sum(Specific1)>0
    plot(x(trainingset1),y1(trainingset1), '.', 'markersize', msize, 'color', Syl1Color)
    plot(x(trainingset2),y1(trainingset2), '.', 'markersize', msize, 'color', Syl2Color)
else
    plot(x([trainingset1 trainingset2]),y1([trainingset1 trainingset2]), '.', 'markersize', msize, 'color', ProtoSylColor)
end

axis tight; 
xlim([-.2 m+.2]);
axis off; 
set(gcf, 'color', [1 1 1],'papersize', [4 4], 'paperposition', [0 0 4 4])
set(gca, 'color', 'none')