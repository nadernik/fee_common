foldername = '2017-04-18'
OldDir = fullfile('C:\Users\Emily\Documents\MATLAB\AcqGui3\HVCOpto',foldername); 
NewDir = fullfile('Z:\AcqGui\HVCOpto',foldername); 
fnums = [17 18 20 21 25 28 34 397:405 407:409 661 663:666];

fnums = sort(fnums, 'ascend');
fnums = unique(fnums);
mkdir(NewDir); % make new folder
for fnumi = 1:length(fnums)
    fnum = fnums(fnumi);
    Fls = dir(fullfile(OldDir, strcat('*', sprintf('%06d',fnum), '*')));
    for fi = 1:length(Fls)
        copyfile(fullfile(OldDir, Fls(fi).name), fullfile(NewDir, Fls(fi).name))
        display(['copied ' Fls(fi).name...% transfer files
            ' to ' NewDir]); 
    end
end

% compile list of file numbers and dates and nframes
clear dnums nAudFrames
for fnumi = 1:length(fnums)
    fnum = fnums(fnumi);
    Fls = dir(fullfile(NewDir, strcat('*', sprintf('%06d',fnum), '*')));
    dnums(fnumi) = datenum(Fls(1).name(17:31), 'yyyymmddTHHMMSS'); 
    % how many frames
    filenameSYNC = Fls(2).name; filenameSYNC(end-4) = '5'; % chan 5 contains sync input
    [SYNC SOUNDfs SOUNDabsstarttime label props] = ...
        egl_AA_daq(fullfile(NewDir,filenameSYNC), 1); 
     AudBinWhenFrameStarts = find(SYNC(2:end)>1 & SYNC(1:end-1)<1 & ...
        [SYNC(3:end); SYNC(end)] > 1 & ...
        [SYNC(4:end); SYNC(end); SYNC(end)] > 1 & ...
        [SYNC(5:end); SYNC(end); SYNC(end); SYNC(end)] > 1); % to prevent false reads when sync is finicky
    nAudFrames(fnumi) = length(AudBinWhenFrameStarts); 
end
save(fullfile(NewDir,'AcqGui_timestamps.mat'), 'fnums', 'dnums', 'nAudFrames');
display('done!')