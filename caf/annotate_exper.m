function annotate_exper(birdname, expername, varargin)
P.rootdir = 'c:\stetner\data\';
P.triggerSyllThreshold = -11;
P.edgeSyllThreshold = -14;
P.filenum = [];
P.bDebug = false;
P.maxFilesPerAnnotation = 300;
P.fMinSyllDuration = .016; %secs
P.fMinIntervalDuration = .007; %secs
P.fMaxSyllDuration = 1; %sec
P = parseargs(P,varargin{:});

P.filenum = {P.filenum};

expers{1} = loadExper(birdname, expername, P.rootdir);
expers{1}.dir = [P.rootdir birdname filesep expername filesep];
annotationName = [P.rootdir filesep birdname filesep birdname '_annotation_' expername '.mat'];

%segment
annotNames = caf_ProcessExperAudio(annotationName, expers, P.filenum, ...
    'triggerAbs', P.triggerSyllThreshold, ...
    'thresholdAbs', P.edgeSyllThreshold, ...
    'maxFilesPerAnnotation', P.maxFilesPerAnnotation, ...
    'fMinSyllDuration', P.fMinSyllDuration, ...
    'fMinIntervalDuration', P.fMinIntervalDuration, ...
    'fMaxSyllDuration', P.fMaxSyllDuration, ...
    'bDebug', P.bDebug);

if P.bDebug
     return
end

%compute features
for(nAnnot = 1:length(annotNames))
    caf_ProcessAnnotation(annotNames{nAnnot}, [], 'all', [], ['getinfo_',birdname], 'bOnlyLabled', false, 'whichAnalyses', [1,3,5]);
end
