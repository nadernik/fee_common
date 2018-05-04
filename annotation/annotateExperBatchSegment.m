function annotateExperBatchSegment(annotationFullFileName, exper, filenums, varargin)

%Default Parameters P

%for song detection...
P.bScreenForSong = {'manual', 'auto', 'none'};
P.displayClim = [0 20];
P.displayFreqRange = [0 8000];
P.songDetectDensity = .4;
P.songDetectLength = .6;
P.songDetectPowerThreshold = 2.5;

%for segmentation
P.method = {'fixed', 'mixture'}; %Mixture using EM to fit levels for noise and sound.
P.thresholdAbs = -7; %if using fixed thresholds.
P.triggerAbs = -10; %if using fixed thresholds.
P.thresholdRelative = 0.8; %if using Mixture Model
P.triggerRelative = 0.6; %if using Mixture Model
P.fMinSyllDuration = .016; %secs
P.fMinIntervalDuration = .007; %secs
P.fMaxSyllDuration = 1; %sec
P.audioFilt = []; % TO
P.notchFilt = []; %filter audio with this filter before segmenting.
P.bDebug = false;

% for stim and mask detection (TO)
P.ChanMask = []; % hardware channel for masking (leave it [] if there are none)
P.ChanStim = []; % hardware channel for stim (leave it [] if there are none)
P.ThresMask = 0.5; % threshold for event detection (V)
P.ThresStim = 0.01; % threshold for stim detection

%modify defaults according to varargin
P = parseargs(P,varargin{:});

%set up waitbar
waitLim = length(filenums)+.1;
i = 1;
h = waitbar(0);
set(h,'Name','Segmenting...')

%Load the hashtable and start the batch...
audioAnnotation = aaLoadHashtable(annotationFullFileName);
fs = exper.desiredInSampRate;
for file = filenums
    waitbar(i/waitLim,h,[num2str(i),'/',num2str(waitLim),' : ', exper.birdname, ' , ', exper.expername, ',filenum: ', num2str(file)]); i = i + 1;
    try
        filename = getExperDatafile(exper,file,exper.audioCh);
        audio = loadAudio(exper, file);
        [pow, filtAud] = aSAP_getLogPower(audio, fs);
        audio = filtAud;    
    
        if(strcmp(P.bScreenForSong, 'auto'))
            bAnnotate = songDetector5(audio, fs, P.songDetectLength, P.songDetectDensity, P.songDetectPowerThreshold, 1000, 7000, false);%All files in training set have sampleRate of 40kHz.
        elseif(strcmp(P.bScreenForSong, 'manual'))
            figure(3893);
            displaySpecgramQuick(audio, fs, P.displayFreqRange, P.displayClim);
            button = questdlg('Should this file be annotated?');
            bAnnotate = strcmp(button, 'Yes');
        else
            bAnnotate = true;
        end


        if(bAnnotate)                
            startTime = 0;
            [syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, thresEdge,thresSyll, soundStd] = aSAP_segSyllablesFromRawAudio(audio, fs, ...
                                    'method', P.method, ...                                  
                                    'thresholdAbs', P.thresholdAbs, ...
                                    'triggerAbs', P.triggerAbs, ...
                                    'thresholdRelative', P.thresholdRelative, ...
                                    'triggerRelative', P.triggerRelative, ...
                                    'fMinSyllDuration' , P.fMinSyllDuration, ...
                                    'fMinIntervalDuration', P.fMinIntervalDuration, ...
                                    'fMaxSyllDuration', P.fMaxSyllDuration, ...
                                    'audioFilt',P.audioFilt,...
                                    'notchFilt', P.notchFilt, ...
                                    'bDebug', P.bDebug);
            syllStartTimes=syllStartTimes+startTime;
            syllEndTimes=syllEndTimes+startTime;
            time = extractExperFilenumTime(exper,file);
            segType=repmat(-1,length(syllStartTimes), 1); % default value of the segType is -1

            % detect mask events
            if ~isempty(P.ChanMask)
                [maskStartTimes,maskEndTimes] = BatchThresholdCrossing_TO(exper,file,...
                    'Chan', P.ChanMask, ...
                    'Thres', P.ThresMask, ...
                    'bDebug', P.bDebug);
            else
                maskStartTimes = [];
                maskEndTimes = [];
            end
            
            % detect stim events
            if ~isempty(P.ChanStim)
                [stimStartTimes,stimEndTimes,stimAmp] = BatchThresholdCrossing_TO(exper,file,...
                    'Chan', P.ChanStim, ...
                    'Thres', P.ThresStim, ...
                    'bDebug', P.bDebug);
            else
                stimStartTimes = [];
                stimEndTimes = [];
                stimAmp = 0;
            end
            
            segMeth.method = P.method;
            segMeth.thresholdRelative = P.thresholdRelative;
            segMeth.triggerRelative = P.triggerRelative;
            segMeth.thresholdAbs = thresEdge;
            segMeth.triggerAbs = thresSyll;
            segMeth.fMinSyllDuration = P.fMinSyllDuration;
            segMeth.fMinIntervalDuration = P.fMinIntervalDuration;
            segMeth.fMaxSyllDuration =  P.fMaxSyllDuration;
            segMeth.created = now;  

            currAnnot.recorder = 'Exper'; %specifies acquistion gui vs SAP
            currAnnot.exper = exper;
            currAnnot.filenum = file;                   
            currAnnot.segAbsStartTimes = time + (syllStartTimes/(24*60*60));
            currAnnot.segAbsEndTimes = time + (syllEndTimes/(24*60*60));            
            currAnnot.segFileStartNdx = round(syllStartTimes*fs + 1);
            currAnnot.segFileEndNdx = round(syllEndTimes*fs + 1);
            currAnnot.segFileStartTimes = syllStartTimes;
            currAnnot.segFileEndTimes = syllEndTimes;
            currAnnot.maskFileStartTimes = maskStartTimes; %%% TO
            currAnnot.maskFileEndTimes = maskEndTimes; %%% TO
            currAnnot.stimFileStartTimes = stimStartTimes; %%% TO
            currAnnot.stimFileEndTimes = stimEndTimes; %%% TO 
            currAnnot.stimAmp = stimAmp; % assuming stim amp is constant within file TO
            currAnnot.segType = segType;
            currAnnot.fs = fs;
            currAnnot.length = length(audio);
            currAnnot.drugstatus='No Drug';
            currAnnot.segmentationMethod = repmat(segMeth, 1, length(syllStartTimes));
            currAnnot.drugindex=1;
            %display(currAnnot); %display currAnnot for debugging

            audioAnnotation.put(filename, currAnnot);              
        end
    catch
        disp(['Not processed: ', exper.birdname, ' , ', exper.expername, ',filenum: ', num2str(file), ' because ', lasterr]);
    end
end
aaSaveHashtable(annotationFullFileName, audioAnnotation);       
close(h);
