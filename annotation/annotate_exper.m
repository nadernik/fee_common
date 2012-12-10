function annotate_exper(birdname, expername, varargin)
%ANNOTATE_EXPER Segment audio into syllables and calculate features
%Audio files must be part of an acquisitionGui experiment. This will
%segment the audio files into syllables based on a fixed threshold that you
%specify and 
%
%Syntax:
% annotate_exper(birdname, expername)
% annotate_exper(birdname, expername, 'ParameterName', value, ...)
%
%List of parameters:
%   rootdir = Root directory for acquisitionGui. Your exper.mat should be
%             located in rootdir/birdname/expername.
%   filenum = File numbers to annotate. Leave blank for all files (default)
%   bDebug = If set to true, shows spectrograms of files to help you set
%            segmentation parameters.
%   maxFilesPerAnnotation = number of acquisitionGui files to store in each
%                           annotation file. Decrease this number if you
%                           are running out of memory in vectorClust.
%   triggerSyllThreshold = Every syllable must cross this threshold at
%                          least once.
%   edgeSyllThreshold = Threshold to detect syllable onsets and offsets.
%   fMinSyllDuration = Minimum syllable duration in seconds
%   fMinIntervalDuration = Minimum gap duration in seconds
%   fMaxSyllDuration = Maximum syllable duration in seconds


%% Default parameter values. 
% All of these values can be set by supplying the parameter name (as a string) 
% and a parameter value as arguments to annotate_exper(). For example: 
% annotate_exper(birdname, expername, 'rootdir', 'c:\path\to\data')

P.rootdir = 'c:\stetner\data\';
P.filenum = []; % blank to annotate all files
P.bDebug = false; 
P.maxFilesPerAnnotation = 300; 

% Segmentation parameters
P.triggerSyllThreshold = -11; 
P.edgeSyllThreshold = -14; 
P.fMinSyllDuration = .016; %secs
P.fMinIntervalDuration = .007; %secs
P.fMaxSyllDuration = 1; %sec

P = parseargs(P,varargin{:});

%%
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
