%% load isolate excel sheet
clear all; 
XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NatashaCMLesions.xlsx'); % edit isolate_inventory
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
birdnum = [0; XLS.data.Sheet1(2:end,strmatch('Name', Columns))];

%% transfer files over

for row = 6:12; 
feeboxfolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
AllDays = dir(fullfile(feeboxfolder, num2str(birdnum(row))));
AllDays = AllDays([AllDays.isdir]); % just directories
AllDays = AllDays(arrayfun(@(x) x.name(1), AllDays) ~= '.') % take out ., .. listings
% make a new folder with 5 example files per day
savehere = fullfile('\\feebox6\shared\emackev\AcqGui\NatashaCMLesions', ...
    num2str(birdnum(row)), 'OnePerDay'); 
mkdir(savehere); 
% for each day
tic
for dayi = 1:length(AllDays)
    try
        allfiles = dir(fullfile(feeboxfolder, num2str(birdnum(row)), AllDays(dayi).name, '*.wav'));
        if length(allfiles) > 10 % if at least 10 files
            ChosenFive = (1) + ceil(length(allfiles)/2); % pick 1 examples from the middle
            age = floor(datenum(allfiles(ChosenFive).date) - birthday(row)); % compute age
            copyfile(fullfile(feeboxfolder, num2str(birdnum(row)), ...
                AllDays(dayi).name, allfiles(ChosenFive).name), ...
                fullfile(savehere, [num2str(age) 'dph_', ...
                allfiles(ChosenFive).name]))
        end
% copy them, appending age to the file name
    catch 
        warning(['skipping this folder: ' AllDays(dayi).name ])
    end
    display([AllDays(dayi).name ' ' num2str(birdnum(row))])
    toc
end
end



%% segment song (do this with electro_gui)

%% make pages for binder
for row = 2:12;%[10 11 16 18 23:24]; % eventually go to 24
    try
% load analysis file
load(fullfile('\\feebox6\shared\emackev\AcqGui\NatashaCMLesions', ...
    num2str(birdnum(row)), 'OnePerDay', 'analysis_segmented'));
DumpFigsHere = 'C:\Users\emackev\Documents\MATLAB\code\RasterPlots\CMLesionSpecgrams'
figure(1); clf
c = 1; 
d = 1; 
FilesPerPage = 15; 
SecondsPerFile = 4; 
% sort by age...
clear age
for fi = 1:length(dbase.SoundFiles)
    age(fi) = str2num(dbase.SoundFiles(fi).name (1:regexp(dbase.SoundFiles(fi).name, 'dph')-1)); 
end
[age,sortbyage] = sort(age, 'ascend'); 
dbase.SoundFiles = dbase.SoundFiles(sortbyage);
dbase.SegmentIsSelected = dbase.SegmentIsSelected(sortbyage);
dbase.SegmentTimes = dbase.SegmentTimes(sortbyage);
for fi = 1:length(dbase.SoundFiles)
    if sum(dbase.SegmentIsSelected{fi})>0
    % load one bout
%     [sndOrig fsOrig dt label props] = ...
%         eval(['egl_' dbase.SoundLoader...
%         '([''' fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES', ...
%         num2str(birdnum(row)), 'OnePerDay', ...
%         dbase.SoundFiles(fi).name) '''],1)']);
    [sndOrig fsOrig] = ...
        audioread(fullfile('\\feebox6\shared\emackev\AcqGui\NatashaCMLesions', ...
        num2str(birdnum(row)), 'OnePerDay', ...
        dbase.SoundFiles(fi).name)); 
    axes('Parent',1,'Units','normalized',...
        'Position',[.1 c*.8/FilesPerPage+.1 .8 .8/FilesPerPage]);
%     subplot('position', [.1 c*.8/10+.1 .8 .09]);
    sndOrig = [sndOrig; zeros(round(fsOrig*SecondsPerFile),1)]; 
    sndOrig = sndOrig(1:round(fsOrig*SecondsPerFile)); 
    [S,Time,F] = spectrogramELM(sndOrig,fsOrig,.005, 1); 
    % plot segments
    hold on
    for si = 1:size(dbase.SegmentTimes{fi},1)
        if dbase.SegmentIsSelected{fi}(si)&&dbase.SegmentTimes{fi}(si,2)/fsOrig<=SecondsPerFile
            patch(dbase.SegmentTimes{fi}(si,[1 2 2 1 1])/fsOrig, 6+.5*[0 0 1 1 0],...
                [1 0 0], 'Edgecolor','none', 'facecolor', [1 0 0])
        end
    end
    
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
    papersize = [8 10]; 
    set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
    if c == FilesPerPage || fi == length(dbase.SoundFiles)
        title(num2str(birdnum(row)))
        saveas(gcf, fullfile(DumpFigsHere, ...
            ['Isolate' num2str(birdnum(row)) '_' num2str(d) '.jpg'])); 
        clf
        d = d+1; 
        c = 1;
    end
    end
end


    catch
    end
end
