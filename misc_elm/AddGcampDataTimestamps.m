function AddGcampDataTimestamps(DataFolder)
    variableInfo = who('-file', fullfile(DataFolder, 'compiled.mat'));
    if ~ismember('Timestamps', variableInfo) 
        display('Calculating timestamps, only need to do once, will take several seconds')
        load(fullfile(DataFolder, 'analysis.mat')); 
        SoundFiles = dbase.SoundFiles; 
        Timestamps = {};
        for fi = 1:length(SoundFiles)
            fname = dbase.SoundFiles(fi).name;
            load(fullfile(DataFolder, fname), 'filenameAUDIO'); 
            [~,nam] = fileparts(filenameAUDIO);
            Timestamps{fi} = datestr(datenum(nam(regexp(nam, 'chan')+([-15:-8 -6:-1])), ...
                'yyyymmddHHMMSS'));
        end
        save(fullfile(DataFolder, 'compiled.mat'), 'Timestamps', '-append')
        display('done calculating timestamps')
    end
end
