function singingSumm = getRawBoutSummary(wavfilenames, path)

bDebug = false;

singingSumm.path = path;
sec2dn = (24*60*60);

for(nFile = 1:length(wavfilenames))
    [audio,fs] = wavread([path,filesep,wavfilenames{nFile}]);
    time = aSAP_extractTimeFromSAPFileName(wavfilenames{nFile});
    [syllStartTimes, syllEndTimes, uNoise, sdNoise, uSound, sdSound] = aSAP_segSyllablesFromRawAudio(audio, fs);
    [boutStartSyll, boutEndSyll] = aSAP_segBoutsFromRawAudio(syllStartTimes, syllEndTimes);
    
    singingSumm.fileinfo(nFile).filename =  wavfilenames{nFile};
    singingSumm.fileinfo(nFile).rawSyllStartTimes = syllStartTimes;
    singingSumm.fileinfo(nFile).rawSyllEndTimes = syllEndTimes; 
    singingSumm.fileinfo(nFile).boutStartSyll = boutStartSyll;
    singingSumm.fileinfo(nFile).boutEndSyll = boutEndSyll;
    singingSumm.fileinfo(nFile).rawSyllStartTimesAbs = (syllStartTimes/sec2dn) + time;
    singingSumm.fileinfo(nFile).rawSyllEndTimesAbs = (syllEndTimes/sec2dn) + time; 
    singingSumm.fileinfo(nFile).uNoise = uNoise;
    singingSumm.fileinfo(nFile).sdNoise = sdNoise;
    singingSumm.fileinfo(nFile).uSound = uSound;
    singingSumm.fileinfo(nFile).sdSound = sdSound;
    

    disp([num2str(nFile),'/',num2str(length(wavfilenames))]);
    
    if(bDebug)
        figure(1116);
        clf;
        [SAP_Feats, m_spec_deriv] = aSAP_generateASAPFeatures(audio, fs);
        aSAP_displaySpectralDerivative(m_spec_deriv, Parameters);
        allCross = [syllStartTimes, syllEndTimes];
        for(i = 1:length(allCross))
            line([allCross(i), allCross(i)], ylim, 'Color', 'red');
        end
        for(i = 1:length(boutStartSyll))
            boutStartT = syllStartTimes(boutStartSyll(i));
            boutEndT = syllEndTimes(boutEndSyll(i));
            polyX = [boutStartT, boutEndT, boutEndT, boutStartT];
            y = ylim;
            polyY = [y(1), y(1), y(2), y(2)];
            p = patch(polyX, polyY, 'b');
			set(p,'FaceAlpha',.2);
        end
        figure(gcf);
        keyboard;
    end

end

