function plotHVCraster(w, xsort, m, trainingNeurons, PlottingParams)
% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

if length(PlottingParams) == 0; % set PlottingParams = [] to use defaults
    PlottingParams.Syl1Color = [1 0 0]; 
    PlottingParams.Syl2Color = [0 0 1];
    PlottingParams.ProtoSylColor = [1 0 1]; 
    PlottingParams.numFontSize = 10; 
    PlottingParams.labelFontSize = 10; 
end
Syl1Color = PlottingParams.Syl1Color;
Syl2Color = PlottingParams.Syl2Color;
ProtoSylColor = PlottingParams.ProtoSylColor;
numFontSize = PlottingParams.numFontSize;
labelFontSize = PlottingParams.labelFontSize;

Latency = findHVClatency(xsort, m, trainingNeurons);

xplot = zeros(size(w,1),2*m);
for ni = 1:size(w,1) % plotting the mode latency for each syll type
    if Latency{1}.FireDur(ni)
        xplot(ni,Latency{1}.mode(ni)) = 1; 
    end
    if Latency{2}.FireDur(ni)
        xplot(ni,Latency{2}.mode(ni)+m) = 1; 
    end
end
cmap = flipud(gray);
cmap = cmap(1:64,:);
cn = size(cmap,1);
hold on; 
set(gca, 'ydir', 'reverse', 'fontsize', numFontSize)
Red = trainingNeurons{1}.nIDs;
Green = trainingNeurons{2}.nIDs; 
cmap(cn+1,:) = [0 0 0]; 
cmap(cn+2,:) = Syl1Color; % some red training neurons
cmap(cn+3,:) = Syl2Color; % some green training neurons
cmap(cn+4,:) = ProtoSylColor; % sometimes magenta

if issame(xplot(Red,:), xplot(Green,:))
    Red = [Red(:); Green(:)]; 
    Green = [];
    xplot(Red,:) = xplot(Red,:)*(1+4/cn); 
    plot([0.5 7.5]*10, [-3 -3], 'linewidth', 3, 'color', ProtoSylColor)
    plot([8.5 15.5]*10, [-3 -3], 'linewidth', 3, 'color', ProtoSylColor)
else
    xplot(Red,:) = xplot(Red,:)*(1+1/cn); 
    xplot(Green,:) = xplot(Green,:)*(1+2/cn);
    %cmap(cn+1,:) = [1 0 0]; % some red training neurons
    %cmap(cn+2,:) = [0 1 0]; % some green training neurons
    plot([0.5 7.5]*10, [-3 -3], 'linewidth', 3, 'color', Syl1Color)
    plot([8.5 15.5]*10, [-3 -3], 'g', 'linewidth', 3, 'color', Syl2Color)
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
    plot([0 size(xplot,2)*10], [sum(sharedind)+.5 sum(sharedind)+.5], 'k', 'linewidth', PlottingParams.linewidth)
end
plot(85*[1 1], [-4 size(xplot,1)], 'k', 'linewidth', 1)
ylim([-4 size(xplot,1)+1])
axis tight
ylabel('Neuron', 'fontsize', labelFontSize); xlabel('Time (ms)', 'fontsize', labelFontSize); xlim([0 tplot(end-1)])

