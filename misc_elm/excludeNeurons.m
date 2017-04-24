function TOEXCLUDE = excludeNeurons(cnmfeFilePath)
    load(cnmfeFilePath, 'neuron'); 
    figure; 
    hold all
    color_palet = 1-[[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
    color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
    nColors = color_palet(mod(1:(size(neuron.C,1)),size(color_palet,1))+1,:); 
    ImAll = reshape(sum(neuron.A,2),300,400)./prctile(sum(neuron.A,2),99); 
    h = image(cat(3,ImAll, ImAll, ImAll)); % colormap gray
    set(gca, 'ydir', 'reverse')
    axis image; axis off; shg
    t = text(100,10, ['click n to reject, y accept, b back'],'color',[1 1 1], ...
           'verticalalignment', 'middle',...
            'horizontalalignment', 'center', 'fontsize', 20); 
    for ni = 1:size(neuron.A,2)
        tmp = reshape(neuron.A(:,(ni)),300,400);
        h.CData = h.CData - ...
            cat(3,tmp*nColors(ni,1), tmp*nColors(ni,2),tmp*nColors(ni,3)); 
        drawnow
    end
    [C,hh] = contour(ImAll>0,1, 'color',[1 1 1]);
    ni = 1; TOEXCLUDE = []; 
    while ni <= size(neuron.A,2)
        tmp = reshape(neuron.A(:,(ni)),300,400);
        hh.LineStyle = 'none';
        [C,hh] = contour(tmp,1, 'color',.8*[1 1 1]); %1-nColors(ni,:));
        t.Color = 1-nColors(ni,:);
        t.Position = [mean(C(1,:)), mean(C(2,:))];
        t.String = num2str(ni); 
        drawnow; shg;
        waitforbuttonpress;
        pressed=double(get(gcf,'CurrentCharacter'))
        if length(pressed)>0
            switch pressed
%                 case 29% right
%                     istart = min(istart+stepdur/2, size(PlotC,2));
%                 case 28 % left
                case 121 % y
                    TOEXCLUDE = setdiff(TOEXCLUDE,ni);
                    ni = ni+1;
                case 110 % n
                    TOEXCLUDE = [TOEXCLUDE ni]
                    h.CData = h.CData + ...
                        cat(3,tmp*nColors(ni,1), tmp*nColors(ni,2),tmp*nColors(ni,3)); 
                    ni = ni+1;
                case 98 % b
                    ni = max(1,ni-1); 
%                 case 30 % up
%                 case 31 % down

            end 
        end
    end
    
end