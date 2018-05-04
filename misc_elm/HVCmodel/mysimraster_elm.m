function mysimraster_elm(w, xsort, m)
xplot = xsort(:,1:16); 
cmap = flipud(gray);
cmap = cmap(1:64,:);
cn = size(cmap,1);
hold on; 
set(gca, 'ydir', 'reverse')
Red = 1:4;
Green = 5:8; 
cmap(cn+1,:) = [0 0 0]; 
cmap(cn+2,:) = [1 0 0]; % some red training neurons
cmap(cn+3,:) = [0 1 0]; % some green training neurons
cmap(cn+4,:) = [1 0 1]; % sometimes magenta

if issame(xplot(Red,:), xplot(Green,:))
    Green = [];
    Red = 1:8; 
    xplot(Red,:) = xplot(Red,:)*(1+4/cn); 
    %cmap(cn+1,:) = [1 0 1]; % some red training neurons
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
sharedind = (sum(xplot,2)>=2)&(sum(xplot,2)<8);
rest = find(~sharedind); 
xplot = xplot([find(sharedind); (rest)],:);
w = w([find(sharedind); (rest)],[find(sharedind); (rest)]);
xplot(end+1,end+1) = 1+4/cn; %to rescale colormap
tplot = (1:(size(xplot,2)))*10; % assuming each bin is 10ms
imagesc(xplot, 'xdata', tplot); colormap(gca, cmap)
if length(rest)>0 & sum(sharedind)>0
    plot([0 size(xplot,2)*10], [sum(sharedind)+.5 sum(sharedind)+.5], 'k', 'linewidth', 1)
end
plot(85*[1 1], [-4 size(xplot,1)], 'k', 'linewidth', 1)
%plot([.5 16.5], [8 8], 'k'); axis tight


ylim([-4 size(xplot,1)+1])
axis tight
ylabel('neuron'); xlabel('time (ms)'); xlim([0 tplot(end-1)])
%ylim([-3.5 size(xplot,1)+.5]); 
%set(gcf, 'color', [1 1 1],'papersize', [4 6], 'paperposition', [0 0 4 6])
%figure(2); clf; [pshared,sp] = mygraph_elm(wsort,xsort,8, 1);

