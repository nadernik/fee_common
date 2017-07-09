    function UpdatePlot
        global istart w pressed patches h SpecIm ExtraIm Tit npat ...
        slines1 slines2 dbase FnumBnum Timestamps ; 
        % spectrogram plot
        subplot(h(1))
        indSpec = find(SpecTime>=(istart/VIDEOfs) & SpecTime<((istart+stepdur)/VIDEOfs));
        Plot = SongSpec(:,indSpec);      
        SpecIm.CData = Plot; axis tight; 
        [~,nam,~] = fileparts(DataFolder);
        %fnam = dbase.SoundFiles(FnumBnum(istart,1)).name; 
        Tit.String = ([nam '; ' num2str(istart) '/' num2str(size(PlotC,2))]); 
        for i = 1:length(patches)
            delete(patches{i}); 
            delete(slines1{i});
            delete(slines2{i});
        end
        SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
            segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
        SegsInFrame(SegsInFrame<0) = 0;
        SegsInFrame(SegsInFrame>stepdur/VIDEOfs) = stepdur/VIDEOfs;
     
        for syli = 1:size(SegsInFrame,1)
            patches{syli} = patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
                [6 6 6.5 6.5], 'k');
        end
        
        % traces plot
        subplot(h(2));
        tmp = PlotC(indSeqSort,istart:istart+stepdur-1); 
        tmp1 = tmp(:,~isnan(sum(tmp,1))); 
        baselines = min(tmp1,[],2); 
        tmp = bsxfun(@minus, tmp, baselines); 
        tmp = bsxfun(@rdivide, (tmp-clims(1)), max(diff(clims), max(tmp,[],2)));
        tmp = 3*tmp/4; 
        tmp(isnan(tmp)) = 0; % file borders
        tmp = bsxfun(@plus, tmp, (1:size(tmp,1))');
        steps = 1:stepdur; 
        for i = size(tmp,1):-1:1
            npat{i}.Vertices = [[1 steps stepdur]'/VIDEOfs [i tmp(i,:) i]'];
        end
        for syli = 1:size(SegsInFrame,1)
            subplot(h(2))
            slines1{syli} = plot(SegsInFrame(syli,1)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1]);
            slines2{syli} = plot(SegsInFrame(syli,2)*[1 1], [0 length(indSeqSort)], ':', 'color', .7*[1 1 1]);
        end
        
        % extra plot, if applicable
        if length(ExtraMatrixToPlot)>0
            ExtraIm.CData = ExtraMatrixToPlot(:,istart:istart+stepdur-1);
        end
        drawnow; 
    end