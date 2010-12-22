function testFile(path, filenum, tdtSamplingRate, daqFS, optAudioCh, handles)

if(~exist('optAudioCh'))
    optAudioCh = 0;
end

CAF_handles = handles;
%%load sample
h = figure(1);
ud.path =  path;
d = dir([ud.path,'*chan',num2str(optAudioCh),'.dat']);
ud.d = d;
ud.filenum = filenum;
ud.tdtSamplingRate = tdtSamplingRate;
ud.sampRate = daqFS;
set(h,'UserData',ud);
updatefilt(h,CAF_handles);

function updatefilt(h,CAF_handles)
ud = get(h,'UserData');
[junk, Song] = daq_readDatafile([ud.path,ud.d(ud.filenum).name]);

[h, equalizedSong, equalizedDAF, amp, dafDB, songDB, dafPowerSPL94, songPowerSPL94, songStat, intermediates] = feval('calculateCAF', ...
                                         'bDebug', true, ...
                                         'audio', Song, ...
                                         'fs', ud.sampRate, ...
                                         'tdt_fs', ud.tdtSamplingRate,...
                                         'handles',CAF_handles);
ud.equalizedDAF = equalizedDAF;
ud.equalizedSong = equalizedSong;
set(h,'UserData',ud);
set(h,'KeyPressFcn',@cb_press);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_press(src, evnt)
ud = get(src,'UserData');
x = xlim;
s = ceil(x(1) * ud.tdtSamplingRate);
e = floor(x(2) * ud.tdtSamplingRate);
if(strcmp(evnt.Key,'period'))
    ud.filenum = ud.filenum + 1;
elseif(strcmp(evnt.Key,'comma'))
    ud.filenum = ud.filenum - 1;
elseif(strcmp(evnt.Key,'j'))
    b = inputdlg('Enter a file number:');
    ud.filenum = str2num(b{1});
elseif(strcmp(evnt.Key,'p'))
    soundsc(ud.equalizedDAF(s:e) + ud.equalizedSong(s:e), 24414/4);
    return
elseif(strcmp(evnt.Key,'o'))
    soundsc(ud.equalizedSong(s:e), 24414/4);
    return
elseif(strcmp(evnt.Key,'i'))
    soundsc(ud.equalizedDAF(s:e), 24414/4);
    return
end
set(src,'UserData',ud);
updatefilt(src);