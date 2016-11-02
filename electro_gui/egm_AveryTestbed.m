function handles = egm_AveryTestbed(handles)

SEGTIMES = handles.dbase.SegmentTimes{filenum}...
    (handles.dbase.SegmentIsSelected{filenum}==1,:)/fs;
SEGTIMES = SEGTIMES;

FileName = fullfile(handles.dbase.PathName, handles.dbase.SoundFiles(filenum).name); 
FileName = [FileName(1:(end-4)) '_SegTimes']; 
save(FileName,'SEGTIMES'); 

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
fs = handles.fs;
lims = get(handles.axes_Sonogram, 'xlim');
if lims(1) < 1/fs;
    lims(1) = 1/fs;
end
if lims(2)*fs > numel(handles.sound)
    lims(2) = numel(handles.sound)/fs
end
ind_time = lims(1):1/fs:lims(2);
song = handles.sound(round(ind_time*fs));
chan1 = handles.chan1(round(ind_time*fs));

figure(2); plot(chan1); shg
params.Fs = fs; 
NoMore60 = rmlinesc(chan1, params, .05/length(chan1), 0, 60);
NoMore60 = rmlinesc(NoMore60, params, .05/length(chan1), 0, 180);
NoMore60 = rmlinesc(NoMore60, params, .05/length(chan1), 0, 300);

[P,f] = PowerSpectrumELM(NoMore60,fs,4);
plot(f,P); shg
xlim([0 300]); ylabel('power (au)'); xlabel('frequency (Hz)')


%DisplaySpecgramQuick(song,fs); 