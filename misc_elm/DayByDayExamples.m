%% transfer files over
% rootSaveHere = '\\feevault\data0\AcqGui\6865'; 
% rootFromHere = '\\feevault\data0\AcqGui\HVCOpto';
rootSaveHere = '\\feevault\data0\AcqGui\6962'; 
rootFromHere = '\\feevault\data0\AcqGui\6962';
birthday = '2/23/2017';
AllDays = dir(rootFromHere);
AllDays = AllDays([AllDays.isdir]); % just directories
AllDays = AllDays(arrayfun(@(x) x.name(1), AllDays) ~= '.') % take out ., .. listings
DateMin = datenum('4/29/2016');
DateMax = datenum('4/29/2017'); 
% make a new folder with 5 example files per day
savehere = fullfile(rootSaveHere, 'OnePerDay'); 
mkdir(savehere); 
% for each day
tic
for dayi = 1:length(AllDays)
    try
        folderdate = datenum(AllDays(dayi).name); 
        if (folderdate>DateMin) & (folderdate<DateMax);
        Wav = dir(fullfile(rootFromHere, AllDays(dayi).name, '*.wav'));
        Dat = dir(fullfile(rootFromHere, AllDays(dayi).name, '*chan0.dat'));
        allfiles = [Wav; Dat]; 
        
        nTransfer = 3; 
        length(allfiles)
        if length(allfiles) > nTransfer % if at least 10 files
            ChosenFive = (1:nTransfer) + ceil(length(allfiles)/2); % pick 1 examples from the middle
            
            for i = 1:length(ChosenFive)
                age = floor(datenum(allfiles(ChosenFive(i)).date) - datenum(birthday)); % compute age
                if 1; %age>=90
                copyfile(fullfile(rootFromHere, ...
                    AllDays(dayi).name, allfiles(ChosenFive(i)).name), ...
                    fullfile(savehere, [num2str(age) 'dph_', ...
                    allfiles(ChosenFive(i)).name]))
                end
            end
        end
        end
% copy them, appending age to the file name
    catch 
        warning(['skipping this folder: ' AllDays(dayi).name ])
    end
    display([AllDays(dayi).name ' ' ])
    toc
end


sound(sin(.1:.3:4000)); 