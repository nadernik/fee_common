function handles = egm_pageofspectrograms(handles)
%%
birthday = '10/26/2016';
FilesPerPage = 15; 
SecondsPerFile = 4; 
age = [];
dbase = handles.dbase;
for fi = 1:length(dbase.SoundFiles)
    age(fi) = datenum(dbase.SoundFiles(fi).name(regexp(dbase.SoundFiles(fi).name, 'chan')+(-15:-8)), ...
        'yyyymmdd') - ...
        datenum(birthday); 
end
[age,sortbyage] = sort(age, 'ascend'); 
dbase.SoundFiles = dbase.SoundFiles(sortbyage);
figure; papersize = [8 10]; set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
c = 1; 
d = 1; 
for fi = 1:length(dbase.SoundFiles)
    % load one bout
%     if issame(dbase.SoundFiles(fi).name(end), 'v') % if it's a wav file
%         [sndOrig fsOrig] = ...
%             audioread(fullfile(rootSaveHere, ...
%             (num2str(birdnum(row))), 'OnePerDay', ...
%             dbase.SoundFiles(fi).name)); 
%     else
    [sndOrig fsOrig dt label props] = ...
        eval(['egl_AA_daq' ...
        '([''' fullfile(dbase.PathName, ...
        dbase.SoundFiles(fi).name) '''],1)']);
%     end

    axes('Parent',gcf,'Units','normalized',...
        'Position',[.1 c*.8/FilesPerPage+.1 .8 .8/FilesPerPage]);
%     subplot('position', [.1 c*.8/10+.1 .8 .09]);
    sndOrig = [sndOrig; max(sndOrig(:))*ones(round(fsOrig*SecondsPerFile),1)]; 
    sndOrig = sndOrig(1:round(fsOrig*SecondsPerFile)); 
    [S,Time,F] = spectrogramELM(sndOrig,fsOrig,.005, 1); 
    
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
        saveas(gcf, fullfile(dbase.PathName, ...
            ['Spectrograms _' num2str(d) '.jpg'])); 
        figure
        set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
        d = d+1; 
        c = 1;
    end
end




