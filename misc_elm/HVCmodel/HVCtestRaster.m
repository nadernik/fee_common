function HVCtestRaster(xdyn,Input,w, plottingParams)

if nargin < 4
    plottingParams.totalPanels = 1;
    plottingParams.thisPanel = 1; 
    plottingParams.numFontSize = 5; 
    plottingParams.labelFontSize = 6; 
end;

numFontSize = plottingParams.numFontSize;
labelFontSize = plottingParams.labelFontSize;


k = size(Input,1);
thres = 1; 

indA = find(Input(1,:));
indB = find(Input(end,:));
cmap = flipud(hot);
cmap(1,:) = ones(1,3);

subplot(2,plottingParams.totalPanels,plottingParams.thisPanel)
cla; 
k = size(Input,1);
tind = 1:80; 
bOnOffset = diff(find(sum(Input,1)));
trainint = bOnOffset(2);
bOnOffset = bOnOffset(1);
n = size(xdyn,1); 
set(gca, 'color', 'none')
xplot = xdyn(:, tind);
xplot = xplot+repmat(.05*(sum(Input(:,1:size(xplot,2))>0,1)>0), size(xplot,1),1);
if issame(plottingParams.sortby, 'activity')
    sortFrom = find(Input(end,:)>0); sortFrom = sortFrom(1); 
    [~,sortInd] = sortrows(xdyn((k+1):n,sortFrom:end)); 
    sortInd = [(1:k)'; k+flipud(sortInd)];
else % sort by weight matrix
    sortInd = [1:(k-1) flipud(sortbyCorr(w(k:end,k:end))+k-1)]; 
end
xplot = xplot((sortInd),tind);
imagesc(xplot, 'xdata',tind*10); colormap(cmap)%(flipud(gray))
xlabel('Time (ms)', 'fontsize', labelFontSize)
ylabel('Neuron', 'fontsize', labelFontSize)
set(gca, 'fontsize', numFontSize)


subplot(2,plottingParams.totalPanels,plottingParams.totalPanels+plottingParams.thisPanel)
imagesc(w(sortInd,sortInd))
ylabel('Neuron', 'fontsize', labelFontSize)
xlabel('Neuron', 'fontsize', labelFontSize)
set(gca, 'fontsize', numFontSize)