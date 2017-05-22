function TOEXCLUDE = excludeNeurons_ByLocation(cnmfeFilePath)
    load(cnmfeFilePath, 'neuron'); 
    cla; hold all
    imagesc(reshape(sum(neuron.A,2),300,400), [0 prctile(sum(neuron.A,2),99.5)]); colormap gray
    axis image; set(gca, 'ydir', 'reverse')
    title('click for polygon to exclude, return to stop')
    [x,y] = ginput; 
    hold on; 
    patch(x,y,'r'); 
    for ni = 1:size(neuron.A,2)
        tmp = reshape(neuron.A(:,(ni)),300,400);
        X = mean(find(sum(tmp,1)));
        Y = mean(find(sum(tmp,2)));
        TOEXCLUDE(ni) = inpolygon(X,Y,x,y);
    end
    TOEXCLUDE = find(TOEXCLUDE);