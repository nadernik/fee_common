%% load isolate excel sheet
clear all; 
XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/MMANLesions.xlsx'); % edit isolate_inventory
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
birdnum = (XLS.data.Sheet1(:,strmatch('Name', Columns)));

%% transfer files over
% DO NOT JUST RUN THIS... REMOVED NOISE FILES, ADDED EXTRA YOUNG FILES
rootSaveHere = '\\feebox6\shared\emackev\AcqGui\StetnersMMANLesions'; 
for row = 2:5
feeboxfolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
AllDays = dir(fullfile(feeboxfolder, num2str(birdnum(row))));
AllDays = AllDays([AllDays.isdir]); % just directories
AllDays = AllDays(arrayfun(@(x) x.name(1), AllDays) ~= '.') % take out ., .. listings
% make a new folder with 5 example files per day
savehere = fullfile(rootSaveHere, ...
    num2str(birdnum(row)), 'OnePerDay'); 
mkdir(savehere); 
% for each day
tic
for dayi = 1:length(AllDays)
    try
        Wav = dir(fullfile(feeboxfolder, num2str(birdnum(row)), AllDays(dayi).name, '*.wav'));
        Dat = dir(fullfile(feeboxfolder, num2str(birdnum(row)), AllDays(dayi).name, '*.dat'));
        allfiles = [Wav; Dat]; 
        
        nTransfer = 2; 
        if length(allfiles) > nTransfer % if at least 10 files
            ChosenFive = (1:nTransfer) + ceil(length(allfiles)/2); % pick 1 examples from the middle
            
            for i = 1:length(ChosenFive)
                age = floor(datenum(allfiles(ChosenFive(i)).date) - birthday(row)); % compute age
                if 1; %age>=90
                copyfile(fullfile(feeboxfolder, num2str(birdnum(row)), ...
                    AllDays(dayi).name, allfiles(ChosenFive(i)).name), ...
                    fullfile(savehere, [num2str(age) 'dph_', ...
                    allfiles(ChosenFive(i)).name]))
                end
            end
        end
% copy them, appending age to the file name
    catch 
        warning(['skipping this folder: ' AllDays(dayi).name ])
    end
    display([AllDays(dayi).name ' ' num2str(birdnum(row))])
    toc
end
end

sound(sin(.1:.3:4000)); 


%% segment song (do this with electro_gui)

%% make pages for binder
DumpFigsHere = 'C:\Users\emackev\Documents\MATLAB\code\RasterPlots\StetnersMMANLesions';
mkdir(DumpFigsHere); 
FilesPerPage = 15; 
SecondsPerFile = 4; 
for row = 2:5;
    try
% load analysis file
Wav = dir(fullfile(rootSaveHere, (num2str(birdnum(row))), 'OnePerDay', '*.wav'));
Dat = dir(fullfile(rootSaveHere, (num2str(birdnum(row))), 'OnePerDay', '*.dat'));
dbase.SoundFiles = [Wav; Dat]; 

figure(1); clf
c = 1; 
d = 1; 

% sort by age...
clear age
for fi = 1:length(dbase.SoundFiles)
    age(fi) = str2num(dbase.SoundFiles(fi).name (1:regexp(dbase.SoundFiles(fi).name, 'dph')-1)); 
end
[age,sortbyage] = sort(age, 'ascend'); 
dbase.SoundFiles = dbase.SoundFiles(sortbyage);

for fi = 1:length(dbase.SoundFiles)
    % load one bout
    if issame(dbase.SoundFiles(fi).name(end), 'v') % if it's a wav file
        [sndOrig fsOrig] = ...
            audioread(fullfile(rootSaveHere, ...
            (num2str(birdnum(row))), 'OnePerDay', ...
            dbase.SoundFiles(fi).name)); 
    else
        [sndOrig fsOrig dt label props] = ...
            eval(['egl_AA_daq' ...
            '([''' fullfile(rootSaveHere, ...
            (num2str(birdnum(row))), 'OnePerDay', ...
            dbase.SoundFiles(fi).name) '''],1)']);
    end

    axes('Parent',1,'Units','normalized',...
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
    papersize = [8 10]; 
    set(gcf, 'papersize', papersize, 'paperposition', [0 0 papersize]); 
    if c == FilesPerPage || fi == length(dbase.SoundFiles)
        title((num2str(birdnum(row))))
        saveas(gcf, fullfile(DumpFigsHere, ...
            ['ControlBird' (num2str(birdnum(row))) '_' num2str(d) '.jpg'])); 
        clf
        d = d+1; 
        c = 1;
    end
end


    catch exception
        warning(exception.message)
    end
end
