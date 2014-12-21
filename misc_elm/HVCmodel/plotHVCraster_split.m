function plotHVCraster_split(w, xsort, m, trainingNeurons, PlottingParams)
% Makes network activity plot, called by RunHVC_split 
% w: weight matrix
% xsort: activity of network
% m: duration of one syllable, in timesteps
% trainingNeurons: cell array of structures containing neuron and time indices for each syllable type
% PlottingParams: sets linewidth, etc.  See RunHVC_split
%
% Emily Mackevicius 12/10/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

Syl1Color = PlottingParams.Syl1Color;
Syl2Color = PlottingParams.Syl2Color;
ProtoSylColor = PlottingParams.ProtoSylColor;
numFontSize = PlottingParams.numFontSize;
labelFontSize = PlottingParams.labelFontSize;

Latency = findHVClatency(xsort, m, trainingNeurons);

% plotting the mode latency for each syll type
xplot = zeros(size(w,1),2*m);
for ni = 1:size(w,1) 
    if Latency{1}.FireDur(ni) & ~isnan(Latency{1}.mode(ni))
        xplot(ni,Latency{1}.mode(ni)) = 1; 
    end
    if Latency{2}.FireDur(ni) & ~isnan(Latency{2}.mode(ni))
        xplot(ni,Latency{2}.mode(ni)+m) = 1; 
    end
end
cmap = flipud(gray);
cmap = cmap(1:64,:);
cn = size(cmap,1);

% determining the training neuron inputs (Red is syl 1, Green is syl 2)
Red = trainingNeurons{1}.nIDs;
Green = trainingNeurons{2}.nIDs; 

% setting colormap
cmap(cn+1,:) = [0 0 0]; 
cmap(cn+2,:) = Syl1Color; % some red training neurons
cmap(cn+3,:) = Syl2Color; % some green training neurons
cmap(cn+4,:) = ProtoSylColor; % sometimes magenta
cmap(cn+5,:) = PlottingParams.SubsongSylColor;

% If protosyllable stage, just plot all training neurons ProtoSylColor
if issame(xplot(Red,:), xplot(Green,:))
    Red = [Red(:); Green(:)]; 
    Green = [];
    xplot(Red,:) = xplot(Red,:)*(1+4/cn); 
else
    xplot(Red,:) = xplot(Red,:)*(1+1/cn); 
    xplot(Green,:) = xplot(Green,:)*(1+2/cn);
end

% if protosyl stage, sort based on mean activity for both rasters
if length(Green)==0
    tmp= xplot>0;
    tmpXplot = tmp(:,1:(size(xplot,2)/2))+tmp(:,(size(xplot,2)/2+1):end);
else
    tmpXplot = xplot>0;
end
[~,sortind] = sortrows(tmpXplot); 
xplot = xplot(flipud(sortind),:);
w = w(flipud(sortind),flipud(sortind));

% if differentiated, sort shared neurons first, then specific neurons
if length(Green)>0
    sharedind = (sum(xplot,2)>=2)&(sum(xplot,2)<8);
else
    sharedind = zeros(1,size(xplot,1)); 
end
rest = find(~sharedind); 
xplotall = xplot([find(sharedind); (rest)],:);

% plotting the activity for the two syll types
for i = 1:2
    axesPos = PlottingParams.axesPosition;
    axesPos(1) = axesPos(1)+(i-1)*axesPos(3)/2; 
    axesPos(3) = axesPos(3)*.4;
    subplot('position', axesPos); 
    xplot = xplotall(:,(1:(size(xplotall,2)/2))+(i-1)*(size(xplotall,2)/2));
    xplot(end+1,end+1) = 1+6/cn; %to rescale colormap
    tplot = (1:(size(xplot,2)))*10; % assuming each bin is 10ms
    imagesc(xplot, 'xdata', tplot); colormap(gca, cmap); hold on
    
    % plot line between each syl type
    if length(Green)>0
        Syl2Ind = find(mod(sum(xplotall,2),(1+2/cn))==0); 
        Syl2Ind = min(Syl2Ind);
        plot([0 size(xplot,2)*10], [Syl2Ind-.5 Syl2Ind-.5], 'k', 'linewidth', PlottingParams.linewidth)
    end
    
    % plot line between shared and specific neurons
    if length(rest)>0 & sum(sharedind)>0 & length(Green)>0
        plot([0 size(xplot,2)*10], [sum(sharedind)+.5 sum(sharedind)+.5], 'k', 'linewidth', PlottingParams.linewidth)
    end
    
    % plot colored bars above each syllable
    if length(Green) == 0
        plot([0.5 9.5]*10, [-3 -3], 'linewidth', 3, 'color', ProtoSylColor)
    elseif i == 1
        plot([0.5 9.5]*10, [-3 -3], 'linewidth', 3, 'color', Syl1Color)
    else
        plot([0.5 9.5]*10, [-3 -3], 'linewidth', 3, 'color', Syl2Color)
    end
    
    % plotting parameters
    ylim([-4 size(xplot,1)+1]); 
    if i == 2; 
        set(gca, 'yticklabel', {})
    else
        ylabel('Neuron', 'fontsize', labelFontSize);
    end
    axis tight
    set(gca, 'color', 'none', 'xtick', [5 55], 'xticklabel', {'0', '50'}, 'ydir', 'reverse', 'fontsize', numFontSize)
    xlim([5 tplot(end-1)+5])
end
