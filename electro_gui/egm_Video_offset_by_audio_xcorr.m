function handles = egm_Video_offset_by_audio_xcorr(handles)
VIDEO_FILENAME_PROPERTY = 'VideoFile';
OFFSET_PROPERTY = 'VideoOffsetSeconds';

% Filter parameters
p.linespecWebcam = 'c';
p.linespecExper = 'b';
p.highPassCutoff = 2000; %Hz, cutoff frequency for audio high pass filter 
p.highPassOrder = 50;
p.smoothingCutoff = 50; % Hz, cutoff frequency for low pass filter for audio log power
p.smoothingOrder = 100;

% currently selected file number in electro_gui
filenum = str2double(get(handles.edit_FileNumber, 'String'));

% Load audio from video file
propnames = handles.Properties.Names{filenum};
propvalues = handles.Properties.Values{filenum};
ndx = strcmp(VIDEO_FILENAME_PROPERTY, propnames);
if ~any(ndx)
    warndlg(sprintf('No video specified! Expected video filename to be in property ''%s''', VIDEO_FILENAME_PROPERTY))
    return
end
filename = propvalues{ndx};
[stereoaudio, fs1] = audioread(filename);
audio1 = stereoaudio(:,1);

% Load audio from current file in electro_gui
audio2 = handles.sound;
fs2 = round(handles.fs);

% Resample so both are at the same (higher) sampling frequency.
if fs1 > fs2
    fs = fs1;
    audio2 = resample(audio2, fs, fs2);
elseif fs2 > fs1
    fs = fs2;
    audio1 = resample(audio1, fs, fs1);
else %fs1 == fs2 (no resampling required)
    fs = fs1;
end

% High pass filter audio signals to remove low frequency sounds that aren't
% singing. Singing is in the range 500-8000 Hz.
nyquistRate = fs / 2;
n  = p.highPassOrder;
Wn = p.highPassCutoff / nyquistRate;
coefsHighPass = fir1(n, Wn, 'high'); % this takes a long time
hpf1 = filtfilt(coefsHighPass, 1, audio1);
hpf2 = filtfilt(coefsHighPass, 1, audio2);

% Log power of audio signal
logpow1 = log(hpf1 .^ 2 + eps);
logpow2 = log(hpf2 .^ 2 + eps);

% Smooth log power with low-pass filter
n = p.smoothingOrder;
Wn = p.smoothingCutoff / nyquistRate;
coefsSmoothing = fir1(n, Wn);
y1 = filtfilt(coefsSmoothing, 1, logpow1);
y2 = filtfilt(coefsSmoothing, 1, logpow2);

offsetSeconds = getOffsetFromXcorrGUI(y1, y2, fs);

% Store the result as a property in electro_gui
formatt = ['%.' int2str(-log10(1/fs)) 'f'];
val = num2str(offsetSeconds, formatt);
handles = electro_gui('eg_AddProperty', handles, 1, OFFSET_PROPERTY, val, filenum);