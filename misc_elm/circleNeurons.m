function circleNeurons(cnmfeFilePath, indSeqSort, nColors)
    load(cnmfeFilePath, 'neuron'); 
    figure; hold all
    imagesc(reshape(sum(neuron.A,2),300,400), [0 prctile(sum(neuron.A,2),99.5)]); colormap gray
    neuron.A = neuron.A(:,indSeqSort); 
    for ni = 1:size(neuron.A,2)
        tmp = reshape(neuron.A(:,(ni)),300,400);
        [C,hh] = contour(tmp,1, 'color',1-nColors((ni),:));
        text(mean(C(1,:)), mean(C(2,:)), [num2str((ni)) '     '],'color',1-nColors((ni),:), ...
           'verticalalignment', 'middle',...
            'horizontalalignment', 'center', 'fontsize', 10)
    end
    % clear all; close all; clc
    set(gca, 'ydir', 'reverse')
    axis image; axis off; shg
    papersize = [4 3]
    set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize])
end