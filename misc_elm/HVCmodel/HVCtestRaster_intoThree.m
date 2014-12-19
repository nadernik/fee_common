function HVCtestRaster_intoThree(xdyn,Input,w, plottingParams)
%%
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

subplot(1,plottingParams.totalPanels,plottingParams.thisPanel)
cla; 
k = size(Input,1);
tind = 1:60; 
bOnOffset = diff(find(sum(Input,1)));
trainint = bOnOffset(2);
bOnOffset = bOnOffset(1);
n = size(xdyn,1); 
set(gca, 'color', 'none')
xplot = xdyn(:, tind);
xplot = xplot+repmat(.2*mod(cumsum(sum(Input(:,1:size(xplot,2))>0,1)>0)+2,3), size(xplot,1),1);
xplot(xplot>1)=1; 
if issame(plottingParams.sortby, 'activity')
    sortFrom = find(Input(1,:)>0); sortFrom = sortFrom(1); 
    [~,sortInd] = sortrows(xdyn((k+1):n,sortFrom:end)); 
    sortInd = [(1:k)'; k+flipud(sortInd)];
else % sort by weight matrix
    sortInd = [1:(k-1) flipud(sortbyCorr(w(k:end,k:end))+k-1)]; 
end
xplot = xplot(sortInd,:);
%
if ~issame(Input(1,:), Input(end,:)) % if in splitting phase
    indSharedThree = sum(xplot((k+1):n,:)==1,2)>4;
    indSharedTwo = (sum(xplot((k+1):n,:)==1,2)>2)&(sum(xplot((k+1):n,:)==1,2)<5); 
    rest = (~indSharedThree)&(~indSharedTwo);
    sortInd = ([(1:k)'; find(indSharedThree)+k; find(indSharedTwo)+k; find(rest)+k]);
    xplot = xplot(sortInd,:); 
end
xplot = xplot(:,tind);
imagesc(xplot, 'xdata',tind*10); colormap(cmap)%(flipud(gray))
xlabel('Time (ms)', 'fontsize', labelFontSize)
ylabel('Neuron', 'fontsize', labelFontSize)
hold on
plot([-.5 size(xplot,2)*10+.5], (.5+k)*ones(1,2), 'k', 'linewidth',  plottingParams.linewidth); 
if ~issame(Input(1,:), Input(end,:)) % if in splitting phase
    plot([-.5 size(xplot,2)*10+.5], (.5+k+sum(indSharedThree)+sum(indSharedTwo))*ones(1,2), 'k', 'linewidth', plottingParams.linewidth); 
end
set(gca, 'fontsize', numFontSize)
axis tight


% subplot(2,plottingParams.totalPanels,plottingParams.totalPanels+plottingParams.thisPanel)
% imagesc(w(sortInd,sortInd))
% ylabel('Neuron', 'fontsize', labelFontSize)
% xlabel('Neuron', 'fontsize', labelFontSize)
% set(gca, 'fontsize', numFontSize)