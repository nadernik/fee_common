function [data, fs, datetime, label, props] = eg_LoadData(dbase, filenum, src)

if strcmp(src, 'Sound')
    [data, fs, datetime, label, props] = feval(['egl_' dbase.SoundLoader], ...
          fullfile(dbase.PathName, dbase.SoundFiles(filenum).name), 1);
elseif ~isempty(regexp(src, '^Channel \d+$', 'ONCE'))  % like 'Channel N'
    chan = str2double(src(9:end));
    assert(chan >= 1 && chan <= length(dbase.ChannelFiles), ...
        'Channel must be between 1 and %g', length(dbase.ChannelFiles))
    assert(filenum >= 1 && filenum <= length(dbase.ChannelFiles{chan}), ...
        'Invalid file number for channel %g', chan)
    [data, fs, datetime, label, props] = feval(...
        ['egl_' dbase.ChannelLoader{chan}], ...
        fullfile(dbase.PathName, dbase.ChannelFiles{chan}(filenum).name), 1);
elseif any(strcmp(src, dbaseEventNames(dbase)))
    error('not implemented') %fixme
else
    data = [];
    fs = [];
    datetime = nan;
    label = '';
    props = {};
end
