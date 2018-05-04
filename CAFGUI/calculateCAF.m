function [h, equalizedSong, equalizedDAF, amp, dafDB, songDB, dafPowerSPL94, songPowerSPL94, songStat,...
    intermediates, tdtParameters] = calculateCAF(varargin) 
%equalizedSong is just the microphone signal and therefore can be converted 
%to dbSPL using rmsCalib94dbHeadMic.
%equalizedDAF is in the same units and equalizedDAF song.

persistent tdtfs; % retained in memory between calls
persistent lpSongPowerFilter;

P.bDebug = true;
P.bQuick = false; % true: inherit previous filter, false: make a new one
P.audio = [];
P.fs = 40000;
P.tdt_fs = 24414; % sampling frequency of the TDT
P.handles = []; % all the information from CAFGUI
P = parseargs(P, varargin{:});

bandFilters = P.handles.bandFilters;
lpBands = P.handles.lpBands;
lpBird = P.handles.lpBird;

%Load bird calibration info (Be sure to set the path)
hdwhiten.Numerator = [1];
hdSongSpectra.Numerator = [1];
hdSpeakerTrans.Numerator = [1];
calibrationCurrent = 0.0707; %rms mA Current that generated this loudness.
calibrationLoudness = 94; %dB %Calibration in skull showed that 1V 4kHz sin wave yields this dbSPL signal on the probe microphone.
currentSetting = 1; %Not computed
rmsCalib94dbHeadMic = 1; %Not computed
rmsFilteredNoise =  1; % Not computed

%Resample audio for the tdt.
audio_daq = P.audio;
audio_daq = audio_daq - mean(audio_daq);
audio_tdt = resample2(audio_daq,P.tdt_fs, P.fs);

%Compute loudness of audio
if(isempty(lpSongPowerFilter) | (tdtfs~=P.tdt_fs) | (~P.bQuick))
    lpSongPowerFilter = v3lp(50, P.tdt_fs, 500, 35); % (Fpass,Fs,P.handles.width,dBdrop)
    lpSongPowerFilter.Numerator = lpSongPowerFilter.Numerator ./ sum(lpSongPowerFilter.Numerator); % normalize
end
songRMS = sqrt(filtfilt(lpSongPowerFilter.Numerator, 1, audio_tdt.^2)); %Not calibrated yet
songPowerSPL94 = ((songRMS + eps) / rmsCalib94dbHeadMic).^2;
songDB = 94 + 10*log10(songPowerSPL94);

%% Generate pitch score and convert to relative loudness.

bUseBinary = true; % use binary CAF

sqSig = audio_tdt.^2;

%get total power estimate (Only use filter and not filtfilt)
birdPower = filter(lpBird.Numerator, 1, audio_tdt.^2);

%get in-band power
for(nharm = 1:length(P.handles.harmonics))
    band = filter(bandFilters.in(nharm).Numerator, 1, sqSig);
    band = band.^2;
    powBandHarm(nharm,:) = filter(lpBands.Numerator, 1, band);
end
powBand = sum(powBandHarm)'; % in-band power

%get out-band power
for(nharm = 1:length(bandFilters.out))
    band = filter(bandFilters.out(nharm).Numerator, 1, sqSig);
    band = band.^2;
    powOutBandHarm(nharm,:) = filter(lpBands.Numerator, 1, band);
end
powOutBand = sum(powOutBandHarm)'; % out-band power


%% modified for binary CAF
%Get pitch score:
pitchScore = (powBand ./ (powBand + powOutBand + eps)); % avoid dividing by zero!

if(~bUseBinary) 
    modPitchScore = pitchScore - P.handles.thres; % pitchScore is proportional to deviation
    modPitchScore(modPitchScore<0) = 0; % set values below P.handles.threshold to zero
    birdPower(birdPower < P.handles.minsongpower) = 0; % don't play FB if birdPower is below P.handles.minsongpower
else % binary
    modPitchScore = pitchScore>P.handles.thres;
    birdPower = birdPower > P.handles.minsongpower;
end

amp = P.handles.beta.*birdPower.*modPitchScore;
amp = (amp).^(1/2); % sqrt
amp(amp>P.handles.maxamp) = P.handles.maxamp; % put cap on amp if goes above P.handles.maxamp

%% Prepare output:
songStat = pitchScore;
intermediates.modPitchScore = modPitchScore;
intermediates.powBand = powBand;
intermediates.powOutBand = powOutBand;

tdtParameters.bandFilters = bandFilters;
tdtParameters.lpBands = lpBands;
tdtParameters.lpBird = lpBird;
tdtParameters.hdwhiten = hdwhiten;
tdtParameters.hdSongSpectra = hdSongSpectra;
tdtParameters.P.handles.thres = P.handles.thres;
tdtParameters.P.handles.maxamp = P.handles.maxamp; 
tdtParameters.P.handles.minsongpower = P.handles.minsongpower;
tdtParameters.P.handles.beta = P.handles.beta;

%% CONVERT AMPLITUDE TO DAF SIGNAL
if(P.bQuick && ~P.bDebug)
    dafRMS = amp.*rmsFilteredNoise*currentSetting;
    dafPower = ((dafRMS+eps)/calibrationCurrent).^2;
    dafDB = calibrationLoudness + 10.*log10(dafPower);
    dafPowerSPL94 = 10.^((dafDB - 94)/10);
    equalizedDAF = [];
    equalizedSong = [];   
else
    %Convert amplitude to feedback signal...
    noise =  rand(length(amp),1).*2 - 1;
    noise = filter(hdwhiten.Numerator, 1, noise); %whiten and filter...
    noise = filter(hdSongSpectra.Numerator, 1, noise);
    dafPreTransfer = amp .* noise;
    noise = filter(hdSpeakerTrans.Numerator, 1, noise); %Apply transfer function of speaker an skull...
    daf = amp .* noise; %whitenoise feedback.

    %Compute final feedback loudness
    dafRMS = sqrt(filtfilt(lpSongPowerFilter.Numerator, 1, (daf*currentSetting).^2));
    dafPower = ((dafRMS+eps)/calibrationCurrent).^2;
    dafDB = calibrationLoudness + 10.*log10(dafPower);
    dafPowerSPL94 = 10.^((dafDB - 94)/10);

    %convert daf and song onto same scale for play back.
    % if daf and mic have the same loudness then
    % 94+20log10(micSig/rmsCalib94dbHeadMic) = calibLoudness+20*log10(currentSetting*dafSig/calibCurrent)
    % from this you can solve for the ratio between micSig and dafSig.
    daf2mic = (rmsCalib94dbHeadMic / (calibrationCurrent/currentSetting)) * 10^((calibrationLoudness - 94)/20);
    equalizedDAF = daf * daf2mic;
    equalizedSong = audio_tdt;    
end

%% PLOT stuff
h = [];
if(P.bDebug)
    h = figure(1);
    clf
    sp = [];
    time = linspace(0,(length(audio_tdt)-1)/P.tdt_fs, length(audio_tdt));
    sp(1) = subplot(3,2,1); 
    displaySpecgramQuick(equalizedSong, P.tdt_fs, [0000,7000], [-15,5]); 
    sp(2) = subplot(3,2,3); 
    displaySpecgramQuick(equalizedSong + equalizedDAF, P.tdt_fs, [0000,7000], [-15,5]);  axis tight;
    sp(3) = subplot(3,2,5); 
    plot(time,songDB); title('song loudness'); axis tight; ylim([30,140]);
    hold on;
    plot(time,dafDB,'r'); title('daf loudness'); axis tight; ylim([30,140]);
    hold off;
    sp(4) = subplot(3,2,2); 
    plot(time,10*log10(powBand)); title('powBand and powBandOut(red)'); axis tight; hold on;
    plot(time,10*log10(powOutBand), 'r'); axis tight; hold off;
    ylim([-100 20])
    sp(5) = subplot(3,2,4);
    %plot(time, modPitchScore); title('Modified Pitch Score'); axis tight; hold on;
    plot(time, pitchScore); axis tight;
    ylim([0.7 1.0])
    hold on
    hh = line(xlim,[P.handles.thres P.handles.thres]); % plot pitch threshold
    set(hh,'color','r');
    sp(6) = subplot(3,2,6); 
    plot(time,amp); title('amp'); axis tight;
    linkaxes(sp,'x');
end

tdtfs = P.tdt_fs;