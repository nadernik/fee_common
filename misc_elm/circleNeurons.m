function circleNeurons(cnmfeFilePath, indSeqSort, nColors)
    load(cnmfeFilePath, 'neuron'); 
    neuron.A = neuron.A(:,indSeqSort); 
    figure; hold all
    imagesc(reshape(sum(neuron.A,2),300,400), [0 max(neuron.A(:))]); colormap gray
    for ni = 1:size(neuron.A,2)
        tmp = reshape(neuron.A(:,(ni)),300,400);
        [C,hh] = contour(tmp,1, 'color',1-nColors((ni),:));
        text(mean(C(1,:)), mean(C(2,:)), num2str((ni)),'color',1-nColors((ni),:), ...
           'verticalalignment', 'middle',...
            'horizontalalignment', 'center')
    end
    % clear all; close all; clc
    set(gca, 'ydir', 'reverse')
    axis image; axis off
end