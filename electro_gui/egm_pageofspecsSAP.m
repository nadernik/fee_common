function handles = egm_pageofspecsSAP(handles)
%%

FilesPerPage = 15; 
SecondsPerFile = 4; 
age = [];
dbase = handles.dbase;
for fi = 1:length(dbase.SoundFiles)
    try
        FirstUnderscore = regexp(dbase.SoundFiles(fi).name, '_'); 
        age(fi) = str2num(dbase.SoundFiles(fi).name(1:(FirstUnderscore(1)-1)));
    catch 
        age(fi) = 0; 
    end
end
[age,sortbyage] = sort(age, 'ascend'); 
dbase.SoundFiles = dbase.SoundFiles(sortbyage);
figure; papersize = [8 10]; set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
c = 1; 
d = 1; 
for fi = 1:length(dbase.SoundFiles)
    % load one bout
%     if issame(dbase.SoundFiles(fi).name(end), 'v') % if it's a wav file
        [sndOrig fsOrig] = ...
            audioread(fullfile(dbase.PathName, ...
        dbase.SoundFiles(fi).name)); 
%     else

    axes('Parent',gcf,'Units','normalized',...
        'Position',[.1 c*.8/FilesPerPage+.1 .8 .8/FilesPerPage]);
%     subplot('position', [.1 c*.8/10+.1 .8 .09]);
    len = length(sndOrig); 
    sndOrig = [sndOrig; max(sndOrig(:))*ones(round(fsOrig*SecondsPerFile),1)]; 
    if length(dbase.SegmentTimes{sortbyage(fi)})>0
        istart = dbase.SegmentTimes{sortbyage(fi)}(min(find(dbase.SegmentIsSelected{sortbyage(fi)})),1); 
    else
        istart = 1; %
    end
    sndOrig = sndOrig(istart:istart+round(fsOrig*SecondsPerFile)); 
    [S,Time,F] = spectrogramELM(sndOrig,fsOrig,.005, 0); 
    S(:,Time>(len/fsOrig)) = median(reshape(S(:,Time<(len/fsOrig)),1,size(S,1)*sum(Time<(len/fsOrig)))); 
    cmap = jet; 
    % to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
    cmap(1,:) = zeros(1,3);
    colormap(cmap);
    Plot = 10*log10(S+eps);
    Plot(Plot(:)<prctile(Plot(:),50)) = prctile(Plot(:),50);
    imagesc(Time,F/1000,Plot); axis tight; 
    set(gca, 'ydir', 'normal')
%     surf(Time, F/1000, Plot,'edgecolor','none'); axis tight; view(0,90);
    ylabel('Frequency (kHz)'); xlabel('Time (s)')
    if c~=1; 
        set(gca,'xtick', []); set(gca,'ytick', []); xlabel('')
    else
        set(gca,'ytick', []);
    end

    set(gca, 'tickdir','out','ticklength',[0.025 0.01]); grid off; box off
    ylim([.5 7])
    ylabel([num2str(age(fi)) 'dph'], 'fontsize', 6)
%     text(0,1,dbase.SoundFiles(fi).name, 'Color','w', ...
%         'verticalalignment', 'bottom', 'fontsize', 6, ...
%         'interpreter', 'none'); 
    c = c+1;
    shg
    drawnow
    
    
    if c == FilesPerPage || fi == length(dbase.SoundFiles)
%         title((num2str(birdnum(row))))
        try % if you have permissions
            saveas(gcf, fullfile(dbase.PathName, ...
                ['Spectrograms _' num2str(d) '.jpg'])); 
        end
        if fi<length(dbase.SoundFiles)
            figure
            set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
        end
        d = d+1; 
        c = 1;
    end
end




