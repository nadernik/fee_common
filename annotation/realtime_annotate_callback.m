function realtime_annotate_callback(exper, last_file_annotated)

%% Segmentation parameters
P.method = {'mixture', 'fixed'}; %Mixture using EM to fit levels for noise and sound.
P.thresholdRelative = 0.8; %if using Mixture Model
P.triggerRelative = 0.6; %if using Mixture Model
P.thresholdAbs = -10; %if using fixed thresholds.
P.triggerAbs = -7; %if using fixed thresholds.
P.fMinSyllDuration = .016; %secs
P.fMinIntervalDuration = .007; %secs
P.fMaxSyllDuration = 1; %sec
P.bDebug = false;
P.audioFilt = [];
P.notchFilt = [];
P.noiseFilt = [];
P.noiseThres = [];
P.noiseFrac = 0; %if noise is greater than threshold for more than this fraction of time then the syllable is excluded.
P.bUseNoiseRatio = false;
P.entropyThres = [];
P.entropyFrac = 0; %if entropy is greater than threshold for more than this fraction of time then the syllable is excluded.
P.entropyWinSize = 256;
P.entropyWinStep = 40;

%% process annotation parameters
%Default Parameters
P.preSyllStartBuffer = .015; %seconds before start syll
P.postSyllEndBuffer = .015; %seconds
P.whichAnalyses = [1,3,5]; %[1:5] %1:miscstats 2:cafProgram 3:pitch 4:current 5:rawaudio
P.randFraction = 1;
P.randNumber = 0;
P.bOnlyLabled = false;
P.durationRange = [-Inf,Inf]; %seconds
P.bUse = []; %specify exactly which syllables to use. %Overrides all other selections.
P = parseargs(P,varargin{:});

%%
latest_file = getLatestDatafileNumber(exper);
filecount = 0;
segcount = 0;
for filenum = (last_file_annotated + 1):latest_file
    filecount = filecount + 1;
    
    % segment
    [audio, timeFileCreated, startTime, startSamp, names, values, info] = loadAudio(exper, filenum);
    time = extractExperFilenumTime(exper, filenum);
    filename = getExperAudioFilename(exper, filenum);
    [syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, thresSyll,thresTrig, soundStd, audioLogPow] = aSAP_segSyllablesFromRawAudio(audio, info.fs);
    
    % annotation
    keys{filecount} = filename;
    elements{filecount}.recorder = 'Exper';%specifies acquistion gui vs SAP
    elements{filecount}.exper = exper;
    elements{filecount}.filenum = filenum;
    elements{filecount}.segAbsStartTimes = time + syllStartTimes/60/60/24;
    elements{filecount}.segAbsEndTimes = time + syllEndTimes/60/60/24;
    elements{filecount}.segFileStartNdx = syllStartTimes * info.fs;
    elements{filecount}.segFileEndNdx = syllEndTimes * info.fs;
    elements{filecount}.segFileStartTimes = syllStartTimes;
    elements{filecount}.segFileEndTimes = syllEndTimes;
    elements{filecount}.segType = -1;
    elements{filecount}.fs = info.fs;
    elements{filecount}.length = length(audio);
    elements{filecount}.segmentationMethod.method = 
    elements{filecount}.segmentationMethod.thresholdRelative =
    elements{filecount}.segmentationMethod.triggerRelative =
    elements{filecount}.segmentationMethod.thresholdAbs =
    elements{filecount}.segmentationMethod.triggerAbs =
    elements{filecount}.segmentationMethod.fMinSyllDuration =
    elements{filecount}.segmentationMethod.fMinIntervalDuration =
    elements{filecount}.segmentationMethod.fMaxSyllDuration =
    elements{filecount}.segmentationMethod.created = 
    
    % for each segment
    for syll = 1:length(syllStartTimes)
        segcount = segcount + 1;
        % audio
        rawaudio.segs(segcount).key = filename;
        rawaudio.segs(segcount).absStart = elements{filecount}.segAbsStartTimes(syll);
        rawaudio.segs(segcount).audio = audio(elements{filecount}.segFileStartNdx(syll):elements{filecount}.segFileEndNdx(syll));
        % pitch
        pitch.segs(segcount).key = filename;
        pitch.segs(segcount).absStart = elements{filecount}.segAbsStartTimes(syll);
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
annoappend(exper, newanno, 'pitch', pitch, 'misc', misc, 'audio', rawaudio)
last_file_annotated = latest_file;