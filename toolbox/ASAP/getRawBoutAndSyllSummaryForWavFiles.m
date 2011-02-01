function [fileSummary, syllables, bouts] = getRawBoutAndSyllSummaryForWavFiles(wavfilenames, path)

%generates three highly redundant data structures.

bDebug = false;

sec2dn = (24*60*60);

%initFileSumm
fileSummary.fileinfo = [];

%init syllables
syllables.filename = [];
syllables.filetime = [];
syllables.filepath = []; 
syllables.rawAudFs = [];
syllables.startTFile = [];
syllables.endTFile = [];
syllables.startTAbs = [];
syllables.endTAbs = [];
syllables.meth = [];
syllables.fileNoise = [];
syllables.fileNoiseVar = [];

%init bouts
bouts.filename = [];
bouts.filepath = []; 
bouts.filetime = [];
bouts.rawAudFs = [];
bouts.numSylls = [];
bouts.startTFile = []; 
bouts.endTFile = [];
bouts.startTAbs = [];
bouts.endTAbs = [];
bouts.meth = [];

%init bouts

for(nFile = 1:length(wavfilenames))
    if(strcmp(path,''))
        [audio,fs] = wavread(wavfilenames{nFile});
    else
        [audio,fs] = wavread([path,filesep,wavfilenames{nFile}]);
    end
    time = aSAP_extractTimeFromSAPFileName(wavfilenames{nFile});
    [syllStartTimes, syllEndTimes, uNoise, sdNoise, uSound, sdSound] = aSAP_segSyllablesFromRawAudio(audio, fs);
    [boutStartSyll, boutEndSyll] = aSAP_segBoutsFromRawAudio(syllStartTimes, syllEndTimes);
    syllStartTimesAbs = (syllStartTimes/sec2dn) + time;
    syllEndTimesAbs = (syllEndTimes/sec2dn) + time;
    
    %Generates several redundant structures... one of them will be useful.
    fileSummary.fileinfo(nFile).filename =  wavfilenames{nFile};
    fileSummary.fileinfo(nFile).filepath =  path;
    fileSummary.fileinfo(nFile).rawAudioFs = fs;
    fileSummary.fileinfo(nFile).rawSyllStartTimes = syllStartTimes;
    fileSummary.fileinfo(nFile).rawSyllEndTimes = syllEndTimes; 
    fileSummary.fileinfo(nFile).rawBoutStartSyll = boutStartSyll;
    fileSummary.fileinfo(nFile).rawBoutEndSyll = boutEndSyll;
    fileSummary.fileinfo(nFile).rawSyllStartTimesAbs = syllStartTimesAbs;
    fileSummary.fileinfo(nFile).rawSyllEndTimesAbs = syllEndTimesAbs;
    fileSummary.fileinfo(nFile).uNoise = uNoise;
    fileSummary.fileinfo(nFile).sdNoise = sdNoise;
    fileSummary.fileinfo(nFile).uSound = uSound;
    fileSummary.fileinfo(nFile).sdSound = sdSound;
    
    ns = length(syllStartTimes);
    syllables.filename = [syllables.filename, repmat(wavfilenames(nFile),1,ns)];
    syllables.filepath = [syllables.filepath, repmat({path},1,ns)]; 
    syllables.filetime = [syllables.filetime, repmat(time, 1,ns)];
    syllables.rawAudFs = [syllables.rawAudFs, repmat(uint16(fs), 1, ns)];
    syllables.startTFile = [syllables.startTFile, syllStartTimes];
    syllables.endTFile = [syllables.endTFile, syllEndTimes];
    syllables.startTAbs = [syllables.startTAbs, syllStartTimesAbs];
    syllables.endTAbs = [syllables.endTAbs, syllEndTimesAbs];
    syllables.meth = [syllables.meth, repmat({'rawAud'},1,ns)];
    syllables.fileNoise = [syllables.fileNoise, repmat(uNoise,1,ns)];
    syllables.fileNoiseVar = [syllables.fileNoiseVar, repmat(sdNoise^2,1,ns)];
    
    nb = length(boutStartSyll);
    bouts.filename = [bouts.filename, repmat(wavfilenames(nFile),1,nb)];
    bouts.filepath = [bouts.filepath, repmat({path},1,nb)]; 
    bouts.filetime = [bouts.filetime, repmat(time, 1,nb)];
    bouts.rawAudFs = [bouts.rawAudFs, repmat(uint16(fs), 1, nb)];
    bouts.numSylls = [bouts.numSylls, boutEndSyll - boutStartSyll + 1]; 
    bouts.startTFile = [bouts.startTFile, syllStartTimes(boutStartSyll)];
    bouts.endTFile = [bouts.endTFile, syllEndTimes(boutEndSyll)];
    bouts.startTAbs = [bouts.startTAbs, syllStartTimesAbs(boutStartSyll)];
    bouts.endTAbs = [bouts.endTAbs, syllEndTimesAbs(boutEndSyll)];
    bouts.meth = [bouts.meth, repmat({'rawAud'},1,nb)];

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

