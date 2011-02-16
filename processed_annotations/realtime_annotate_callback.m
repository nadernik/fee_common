function realtime_annotate_callback(exper)
persistent last_file_annotated
if isempty(last_file_annotated)
    last_file_annotated = 0;
end
latest_file = getLatestDatafileNumber(exper);
filecount = 0;
segcount = 0;
for filenum = (last_file_annotated + 1):latest_file
    filecount = filecount + 1;
    % segment
    [audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper,filenum);
    time = extractExperFilenumTime(exper,file);
    [syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, thresSyll,thresTrig, soundStd, audioLogPow] = aSAP_segSyllablesFromRawAudio(audio, info.fs);
    % annotation
    keys{filecount} = 
    elements{filecount}.recorder = 'Exper';%specifies acquistion gui vs SAP
    elements{filecount}.exper = exper;
    elements{filecount}.filenum = filenum;
    elements{filecount}.segAbsStartTimes =
    elements{filecount}.segAbsEndTimes =
    elements{filecount}.segFileStartNdx =
    elements{filecount}.segFileEndNdx =
    elements{filecount}.segFileStartTimes =
    elements{filecount}.segFileEndTimes =
    elements{filecount}.segType = -1;
    elements{filecount}.fs = info.fs;
    elements{filecount}.length = length(audio);
    elements{filecount}.segmentationMethod.method
    elements{filecount}.segmentationMethod.thresholdRelative
    elements{filecount}.segmentationMethod.triggerRelative
    elements{filecount}.segmentationMethod.thresholdAbs
    elements{filecount}.segmentationMethod.triggerAbs
    elements{filecount}.segmentationMethod.fMinSyllDuration
    elements{filecount}.segmentationMethod.fMinIntervalDuration
    elements{filecount}.segmentationMethod.fMaxSyllDuration
    elements{filecount}.segmentationMethod.created = 
    
    % for each segment
    for syll = 1:length(syllStartTimes)
        segcount = segcount + 1;
        % audio
        rawaudio.segs(segcount).key = 
        rawaudio.segs(segcount).absStart
        rawaudio.segs(segcount).audio
        % pitch
        pitch.segs(segcount).key
        pitch.segs(segcount).absStart
        pitch.segs(segcount).pitch
        pitch.segs(segcount).pitchGoodness
        pitch.segs(segcount).harmonicPower
        pitch.segs(segcount).pitchTime
        pitch.segs(segcount).entropy
        % misc
        misc.segs(segcount).key
        misc.segs(segcount).absStart = startTime + syllStartTimes(syll)/60/60/24;
        misc.segs(segcount).duration = syllEndTimes(syll) - syllStartTimes(syll);
        misc.segs(segcount).fStartTime = syllStartTimes(syll);
        misc.segs(segcount).fEndTime = syllEndTimes(syll);
        misc.segs(segcount).segType = -1;
        misc.segs(segcount).fs = info.fs;
    end
end
rawaudio.bRand = true(segcount, 1);
pitch.bRand    = true(segcount, 1);
misc.bRand     = true(segcount, 1);
append_annotation(exper, newanno, 'pitch', pitch, 'misc', misc, 'audio', rawaudio)
last_file_annotated = latest_file;