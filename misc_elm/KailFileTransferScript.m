%% transfer files over
birdFolder = '\\feevault\data0-shared\kailm\Screening\6973';

AllDays = dir(birdFolder);
AllDays = AllDays([AllDays.isdir]); % just directories
AllDays = AllDays(arrayfun(@(x) x.name(1), AllDays) ~= '.') % take out ., .. listings

% make a new folder 
savehere = fullfile(birdFolder, 'OnePerDay'); 
mkdir(savehere); 

% for each day
tic
for dayi = 1:length(AllDays)
    try
        allfiles = dir(fullfile(birdFolder, AllDays(dayi).name, '*.wav'));
        TooSmall = []; 
        for fi = 1:length(allfiles)
            if allfiles(fi).bytes<300000
                TooSmall = [TooSmall fi]; 
            end
        end
        allfiles(TooSmall) = [];
          
        nTransfer = 1; 
        length(allfiles)
        if length(allfiles) >= nTransfer % if at least 10 files
            ChosenFive = (1:nTransfer) + floor(length(allfiles)/2); % pick 1 examples from the middle
            
            for i = 1:length(ChosenFive)
                copyfile(fullfile(birdFolder, ...
                    AllDays(dayi).name, allfiles(ChosenFive(i)).name), ...
                    fullfile(savehere, [AllDays(dayi).name '_' allfiles(ChosenFive(i)).name]))
            end
        end
% copy them, appending age to the file name
    catch 
        warning(['skipping this folder: ' AllDays(dayi).name ])
    end
    display([AllDays(dayi).name ' ' ])
    toc
end


% sound(sin(sqrt(.1:.1:100))); 