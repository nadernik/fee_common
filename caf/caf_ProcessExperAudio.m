function annotFileNames = caf_ProcessExperAudio(annotationName, expers, filenums, varargin)


%% Default Parameters
P.triggerAbs = -8.5;
P.thresholdAbs = -11;
P.fMinSyllDuration = .016; %secs
P.fMinIntervalDuration = .007; %secs
P.fMaxSyllDuration = 1; %sec
P.audioFilt = []; %audioFilt.numerator
P.notchFilt = []; %filter audio with this filter before segmenting.
P.bDebug = false; %to visualize segmentation
P.maxFilesPerAnnotation = Inf;
%P.maxSegDuraPerAnnotFile = Inf; 1500; %max segment duration per annotation file in seconds

%for stim and mask detection (TO)
P.ChanMask = []; % hardware channel for masking (leave it [] if there are none)
P.ChanStim = []; % hardware channel for stim (leave it [] if there are none)
P.ThresMask = 0.5; % threshold for event detection (V)
P.ThresStim = 0.01; % threshold for stim detection

P = parseargs(P,varargin{:});




%% find out the file number
if(isempty(expers{1}))
    expers{1} = uiloadExper;
    filenums{1} = 1:getLatestDatafileNumber(expers(1));
end

for i = 1:length(expers)
    if(length(filenums) < i)
        filenums{i} = 1:getLatestDatafileNumber(expers{i});
    elseif (isempty(filenums{i}))
        filenums{i} = 1:getLatestDatafileNumber(expers{i});
    end
end

%% Process the annotation name...
[annotPath, annotName, annotExt] = fileparts(annotationName);
if(isempty(annotExt))
    annotExt = '.mat';
end
if(strcmp(annotName(end-5:end-3),'-pt')) % month
    annotName = annotName(1:end-6);
    currPartNum = str2num(annotName(end-2:end));
else
    currPartNum = 1;
end

%Create the first annotation file if it doesn't exist
annotFileNames{1} = annotationName;
if(isempty(dir(annotationName)))    
    hash = mhashtable;
    aaSaveHashtable(annotationName, hash);
end

%Process all the expers
for i = 1:length(expers)
    processedNdx = 0;
    while(processedNdx < length(filenums{i}))
        %If current annotation exceeds max number of files then start a new one
        currAnnot = aaLoadHashtable(annotationName);
        if(currAnnot.size >= P.maxFilesPerAnnotation)
            currPartNum = currPartNum + 1;
            annotationName = [annotPath, filesep, annotName, '-pt', sprintf('%03d',currPartNum), annotExt];
            annotFileNames{end + 1} = annotationName;
            if(isempty(dir(annotationName)))    
                hash = mhashtable;
                aaSaveHashtable(annotationName, hash);
            end
            currAnnot = aaLoadHashtable(annotationName);
        end

        %Process as many files as will fit in the current annot.
        toProcess = filenums{i}(processedNdx+1:min(length(filenums{i}),processedNdx + P.maxFilesPerAnnotation - currAnnot.size));
        processedNdx = min(length(filenums{i}),processedNdx + P.maxFilesPerAnnotation - currAnnot.size);
        annotateExperBatchSegment(annotationName, expers{i}, toProcess , ...
                                  'bScreenForSong', 'none', ...
                                  'method', 'fixed', ...
                                  'thresholdAbs',P.thresholdAbs, ...
                                  'triggerAbs',P.triggerAbs, ...
                                  'fMinSyllDuration', P.fMinSyllDuration, ...
                                  'fMinIntervalDuration', P.fMinIntervalDuration, ...
                                  'fMaxSyllDuration', P.fMaxSyllDuration, ...
                                  'audioFilt', P.audioFilt, ...
                                  'notchFilt', P.notchFilt, ...
                                  'ChanMask', P.ChanMask, ...
                                  'ChanStim', P.ChanStim, ...
                                  'ThresMask', P.ThresMask, ...
                                  'ThresStim', P.ThresStim, ...
                                  'bDebug', P.bDebug);
    end
end

for(nAnnot = 1:length(annotFileNames))
    %Load the annotation we just created
    annotation = aaLoadHashtable(annotFileNames{nAnnot});
    annotation = annot_removeFileOverlaps(annotation);

    %%Resave the annotation with overlaps removed.
    aaSaveHashtable(annotFileNames{nAnnot}, annotation);
end
