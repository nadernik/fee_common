function selectedTraces(DataFolder, cnmfeFilePath, indSeqSort, nColors, baselines)
%%
    load(cnmfeFilePath, 'neuron'); 
    load(fullfile(DataFolder, 'compiled.mat'), 'Labels', 'segs', 'VIDEOfs',...
        'SOUNDfs', 'CompSoundSONG', 'FnumBnum');

    if ~exist('SOUNDfs')
        SOUNDfs = 40000; 
    end
    
    % go through raw data
    figure(1); clf; shg
    stepdur = 200; %180; %180;

    PlotC = neuron.C;

    % for stripes between files
    borders = find((diff([0; FnumBnum(:,1)])~=0)|(diff([0; FnumBnum(:,1)])~=0))-1; 
    PlotC(:,borders(borders>0)) = nan; 
    
    
    clims = [0 prctile(neuron.C(:),99)]; %[3 25]; 

    istart = 1; 
    while istart<size(PlotC,2)
        sampsong = CompSoundSONG(ceil(istart*SOUNDfs/VIDEOfs:(istart+stepdur)*SOUNDfs/VIDEOfs)); 
        h(1) = subplot('position', [.1 .85 .8 .05]);cla
        spectrogramELM(sampsong, SOUNDfs, .002, 1); title([num2str(istart) '; file ' num2str(FnumBnum(istart,1))]); 
        SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
            segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
        hold on
        for syli = 1:size(SegsInFrame,1)
            patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
                [6 6 6.5 6.5], 'k')
        end

        axis off
        h(2) = subplot('position', [.1 .1 .8 .75]);cla; hold on; 
        tmp = PlotC(indSeqSort,istart:istart+stepdur-1); 
        tmp1 = tmp(:,~isnan(sum(tmp,1))); 
%         baselines = median(tmp1,2); % overwriting given baselines

        baselines = min(tmp1,[],2); % overwriting given baselines
        tmp = bsxfun(@minus, tmp, baselines); 
%         tmp(tmp<clims(1)) = clims(1); 
%         tmp(tmp>clims(2)) = clims(2); 
        tmp = (tmp-clims(1))/diff(clims); 
        %%
%         N = tmp(18,110:(173)); 
%         X = N-mean(N); 
%         Fs = 30;
% T = 1/Fs;             % Sampling period
% L = length(N);             % Length of signal
% t = (0:L-1)*T;        % Time vector
% Y = fft(X);
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs*(0:(L/2))/L;
% plot(f,P1)
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
%%

%         tmp = bsxfun(@rdivide, tmp, baselines);
%         tmp = bsxfun(@rdivide, tmp, max(tmp,[],2));
%         tmp = bsxfun(@rdivide, tmp, max(tmp,[],2)); 
%         tmp(tmp>prctile(ByMotif(:),satPrc)) = prctile(ByMotif(:),satPrc);
%         ColoredC = cat(3,...
%             PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,1),1,stepdur),...
%             PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,2),1,stepdur),...
%             PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,3),1,stepdur));

        % colored neurons
%         ColoredC = cat(3,...
%             tmp.*repmat(nColors(:,1),1,stepdur),...
%             tmp.*repmat(nColors(:,2),1,stepdur),...
%             tmp.*repmat(nColors(:,3),1,stepdur));
%         image(1-ColoredC, 'xdata', (1:stepdur)/VIDEOfs); 
%         colormap(flipud(gray))
        set(gca, 'colororder', 1-nColors)
        plot((1:stepdur)/VIDEOfs, bsxfun(@plus, tmp/2, (1:size(tmp,1))')')
        
        % jet coloring
%         imagesc(tmp, 'xdata',(1:stepdur)/VIDEOfs,...
%             [prctile(tmp(:),50) prctile(tmp(:),100)])
%         colormap jet
        
        ylabel('neuron'); set(gca, 'ytick', 1:size(PlotC,1))
        xlabel('Time (s)')
        linkaxes(h,'x'); 
        axis tight
        drawnow; shg;
        waitforbuttonpress;
        pressed=double(get(gcf,'CurrentCharacter')); 
        if length(pressed)>0
            switch pressed
                case 29% right
                    istart = min(istart+stepdur/2, size(PlotC,2));
                case 28 % left
                    istart = max(istart-stepdur/2,1);
            end 
        end
    end
end