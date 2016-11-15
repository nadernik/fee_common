foldername = '2016-11-12'
OldDir = fullfile('C:\Users\Emily\Documents\MATLAB\AcqGui3\HVCOpto',foldername); 
NewDir = fullfile('E:\TempFileTransfer',foldername); 
fnums = [1 5 6 8:11 14 15 17:24 26:29 31:36 38:41 64 65 68 71 72 74]; 
% fnums = [165 169 170:172 217 218 221:226 230:242 244:258 261:266 268:269 271 273:286]; % array of files to be analyzed, convert from string to number

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