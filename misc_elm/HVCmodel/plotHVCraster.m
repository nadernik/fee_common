function plotHVCraster(w, xsort, m, trainingNeurons)
% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

Latency = findHVClatency(xsort, m, trainingNeurons);

xplot = zeros(size(w,1),2*m);
for ni = 1:size(w,1) % plotting the mode latency for each syll type
    if Latency{1}.FireDur(ni)
        xplot(ni,Latency{1}.mode(ni)+1) = 1; 
    end
    if Latency{2}.FireDur(ni)
        xplot(ni,Latency{2}.mode(ni)+1+m) = 1; 
    end
end
cmap = flipud(gray);
cmap = cmap(1:64,:);
cn = size(cmap,1);
hold on; 
set(gca, 'ydir', 'reverse')
Red = trainingNeurons{1}.nIDs;
Green = trainingNeurons{2}.nIDs; 
cmap(cn+1,:) = [0 0 0]; 
cmap(cn+2,:) = [1 0 0]; % some red training neurons
cmap(cn+3,:) = [0 1 0]; % some green training neurons
cmap(cn+4,:) = [1 0 1]; % sometimes magenta

if issame(xplot(Red,:), xplot(Green,:))
    Red = [Red(:); Green(:)]; 
    Green = [];
    xplot(Red,:) = xplot(Red,:)*(1+4/cn); 
    plot([0.5 7.5]*10, [-3 -3], 'm', 'linewidth', 3)
    plot([8.5 15.5]*10, [-3 -3], 'm', 'linewidth', 3)
else
    xplot(Red,:) = xplot(Red,:)*(1+1/cn); 
    xplot(Green,:) = xplot(Green,:)*(1+2/cn);
    %cmap(cn+1,:) = [1 0 0]; % some red training neurons
    %cmap(cn+2,:) = [0 1 0]; % some green training neurons
    plot([0.5 7.5]*10, [-3 -3], 'r', 'linewidth', 3)
    plot([8.5 15.5]*10, [-3 -3], 'g', 'linewidth', 3)
end

hold on;
[~,sortind] = sortrows(xplot>0); 
xplot = xplot(flipud(sortind),:);
w = w(flipud(sortind),flipud(sortind));

if length(Green)>0
    sharedind = (sum(xplot,2)>=2)&(sum(xplot,2)<8);
else
    sharedind = zeros(1,size(xplot,1)); 
end
rest = find(~sharedind); 
xplot = xplot([find(sharedind); (rest)],:);
w = w([find(sharedind); (rest)],[find(sharedind); (rest)]);
xplot(end+1,end+1) = 1+4/cn; %to rescale colormap
tplot = (1:(size(xplot,2)))*10; % assuming each bin is 10ms
imagesc(xplot, 'xdata', tplot); colormap(gca, cmap)
if length(rest)>0 & sum(sharedind)>0 & length(Green)>0
    plot([0 size(xplot,2)*10], [sum(sharedind)+.5 sum(sharedind)+.5], 'k', 'linewidth', 1)
end
plot(85*[1 1], [-4 size(xplot,1)], 'k', 'linewidth', 1)
ylim([-4 size(xplot,1)+1])
axis tight
ylabel('neuron'); xlabel('time (ms)'); xlim([0 tplot(end-1)])

