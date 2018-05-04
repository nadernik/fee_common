function [pitchRange, dbLoudnessRelSong] = artificialStack(startPitch, endPitch, step, fs, fcn_cafProgram, fAmp, handles)


% calibration parameters
hdwhiten.Numerator = [1];
hdSongSpectra.Numerator = [1];
hdSpeakerTrans.Numerator = [1];
calibrationCurrent = 0.0707; %rms mA Current that generated this loudness.
calibrationLoudness = 94; %dB %Calibration in skull showed that 1V 4kHz sin wave yields this dbSPL signal on the probe microphone.
currentSetting = 1; %Not computed
rmsCalib94dbHeadMic = 1; %Not computed
rmsFilteredNoise =  1; % Not computed

if(~exist('fAmp'))
    fAmp = .02;
end

n = 0;
pitchRange = startPitch:step:endPitch; % pitch range of the artificial harmonic stack
for(pitch = pitchRange)
    n = n + 1;
    %harmPower = rand(1,8) * .04;
    nHarms = floor(fs/2/pitch);
    harmPower = fAmp * ones(1,nHarms);
    audio = getHarmonicStack(pitch, harmPower, fs, .2);
    [t, t, t, amp, dafDB, songDB] = feval(fcn_cafProgram, 'bDebug', false, 'bQuick', true, ...
                                                'audio', audio', ...
                                                'fs', fs, ...
                                                'tdt_fs', fs, ...
                                                'handles',handles); %%% TO                                                          
    %db(n) = mean(dafDB(round(end/2-1000):round(end/2+1000)));
    
    rms = amp.*rmsFilteredNoise;
    SPL = ((rms+eps)/calibrationCurrent).^2;
    dbSPL = calibrationLoudness + 10.*log10(SPL);
    db(n) = mean(dbSPL(round(end/2-1000):round(end/2+1000)));
    song(n) = mean(songDB(round(end/2-1000):round(end/2+1000)));
    pitch; %%% change to waitbar
    
end

m = max(real(db));

%figure(100);
plot(pitchRange, db-m,'linewidth',2);
%figure;
%plot(pitchRange, db-song);
ylim([min(db-m)-20,20])

dbLoudnessRelSong = db-song;    