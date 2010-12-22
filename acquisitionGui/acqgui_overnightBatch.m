function acqgui_overnightBatch(expers)
return % skip everything below. not doing caf.
all_expers = expers;
clear expers

%% parmeters
P.songDetectLength = 0.6;
P.songDetectDensity = 0.6;
P.songDetectPowerThreshold = 3;
rootdir = 'c:\stetner\data\';
%%
for n = 1:length(all_expers) % for each experiment
    expers = all_expers(n); %expers is now a cell array with one element
    annotationName = [rootdir filesep expers{1}.birdname filesep expers{1}.birdname '_annotation_' expers{1}.expername '.mat'];

    % segment
    % use mixed gaussian model to find threshold for one random file. hopefully
    % this file actually has song in it!
    bAnnotate = 0;
    while ~bAnnotate
        file = ceil(rand * getLatestDatafileNumber(expers{1})); %random file number
        audio = loadAudio(expers{1}, file);
        fs = expers{1}.desiredInSampRate;
        bAnnotate = songDetector5(audio, fs, P.songDetectLength, P.songDetectDensity, P.songDetectPowerThreshold, 1000, 7000, false);%All files in training set have sampleRate of 40kHz.
    end
    [syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, thresEdge,thresSyll, soundStd] = aSAP_segSyllablesFromRawAudio(audio, fs, ...
        'method', 'mixture');
    % use newly estimated thresholds to segment all the files. using static
    % thresholds is faster than finding gaussian mixture estimate every time
    filenum = {[]}; %all files
    bDebug = false;
    annotNames = caf_ProcessExperAudio(annotationName, expers, filenum, ...
        'triggerAbs', thresSyll, 'thresholdAbs', thresEdge, 'maxFilesPerAnnotation', 300,'bDebug',bDebug);
    %compute features
    for(nAnnot = 1:length(annotNames))
        caf_ProcessAnnotation(annotNames{nAnnot}, [], 'all', [], ['getinfo_',expers{1}.birdname], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);
    end
end