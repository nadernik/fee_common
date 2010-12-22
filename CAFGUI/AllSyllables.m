function AllSyllables(birdname,datestr, filePrefix,varargin)
%Takes an annotation and computes various statistics on all of its
%segments.

%Default Parameters
P.rootdir = 'c:\aadata\AuditoryFeedback\';
P.randFraction = 1; %don't change this if you randNumber is greater than 0.
P.randNumber = 0;
P.syllType = []; %if empty then process all.
P.lastN = 0; % process only the last N syllables
P.winSize = 1024;
P.winStep = 40;
P.fs = 40000;
P.handles = [];
P = parseargs(P,varargin{:});

CAF_handles = P.handles;

if(~iscell(filePrefix))
    temp = filePrefix; clear filePrefix;
    filePrefix{1} = temp;
end
    
d{1} = [];
d{2} = [];
for(nPrefix = 1:length(filePrefix))
    d{1} = [d{1};dir([P.rootdir, birdname, filesep, birdname, '_', filePrefix{nPrefix}, '_misc_', datestr, '*.mat'])];
    d{2} = [d{2};dir([P.rootdir, birdname, filesep, birdname, '_', filePrefix{nPrefix}, '_audio_', datestr, '*.mat'])];
end

%low pass filter for subsampling
lpSubsamp = v3lp(50, P.fs, 500, 35);
lpSubsamp.Numerator = lpSubsamp.Numerator ./ sum(lpSubsamp.Numerator);

for nFile = 1:length(d{1})
    %load the audio file.
    load([P.rootdir, birdname, filesep, d{1}(nFile).name]);
    load([P.rootdir, birdname, filesep, d{2}(nFile).name]);
   
    %initialize cafProgram
    cafProgram = [];
    cafProgram.annotationName = rawaudio.annotationName;
    %cafProgram.fcn_cafProgram = fcn_cafProgram;
    %cafProgram.strBirdInfo = strBirdInfo;
    cafProgram.bRand = rawaudio.bRand;

    %determine which segs to process
    bAnalyze = true(length(rawaudio.segs),1);
    if(~isempty(P.syllType)) % syllable to be analyzed is specified
        bAnalyze = bAnalyze & (ismember([misc.segs.segType],P.syllType))';
    end
    if P.lastN==0 % lastN not specified 
        % TO DO: error when last N is greater than the # of syllables
        if(P.randFraction < 1)
            bAnalyze = bAnalyze & (rand(length(rawaudio.segs),1) <= P.randFraction);
        elseif(P.randNumber ~= 0)
            temp = randperm(sum(bAnalyze));
            temp2 = find(bAnalyze);
            if(round(P.randNumber)<=length(temp2))
                bAnalyze = false(size(bAnalyze));
                bAnalyze(temp2(temp(1:P.randNumber))) = true;
            else
                error('Requested more syllables to be analyzed than exist.');
            end
        end
    else % lastN specified
        temp = find(bAnalyze); % find segments to be analyzed
        List = temp(end-P.lastN+1:end); % extract the last N segments
        IsLastN = zeros(size(bAnalyze)); % same as IsLastN
        for n=1:length(List)
            IsLastN(List(n)) = 1;
        end
        bAnalyze = logical(IsLastN); % convert to logical
    end
        
    h = waitbar(0);    
    for nSeg = 1:length(rawaudio.segs) % for all the segments
        cafProgram.segs(nSeg).key = rawaudio.segs(nSeg).key;
        cafProgram.segs(nSeg).absStart = rawaudio.segs(nSeg).absStart;
        cafProgram.segs(nSeg).dafPower = [];
        cafProgram.segs(nSeg).songPower = [];
        cafProgram.segs(nSeg).songStat = [];
        cafProgram.segs(nSeg).intermediates = [];
        if(bAnalyze(nSeg))
            syllAudio = rawaudio.segs(nSeg).audio;

            %RMS amplitude
            fs = P.fs;
            [t, t, t, t, t, t, dafPower, songPower, songStat, intermediates] = feval('calculateCAF',...
                'bDebug', false,...
                'bQuick', true, ...
                'audio', syllAudio, ...
                'fs', fs, ...
                'handles',CAF_handles);

            %Subsamples to match Pitch time samples.
            dafPower = dafPower(rem(P.winSize/2,P.winStep):P.winStep:end);
            songPower = songPower(rem(P.winSize/2,P.winStep):P.winStep:end);
            songStat = filtfilt(lpSubsamp.Numerator, 1, songStat);
            songStat = songStat(rem(P.winSize/2,P.winStep):P.winStep:end);
            fields = fieldnames(intermediates);
            for nField = 1:length(fields)
                sig = intermediates.(fields{nField});
                sig = filtfilt(lpSubsamp.Numerator, 1, sig);
                sig = sig(rem(P.winSize/2,P.winStep):P.winStep:end);
                intermediates.(fields{nField})=  sig;
            end
            cafProgram.segs(nSeg).dafPower = dafPower;
            cafProgram.segs(nSeg).songPower = songPower;
            cafProgram.segs(nSeg).songStat = songStat;
            cafProgram.segs(nSeg).intermediates = intermediates;
        end
        
        waitbar(nSeg/length(rawaudio.segs), h, ['file: ', d{1}(nFile).name]);
        % TO DO, fix waitbar to show only the analyzed syllables
    end
    clear misc;
    clear rawaudio;
    
    miscFilename = [P.rootdir, birdname, filesep, d{1}(nFile).name];
    cafProgramFilename = regexprep(miscFilename,'_misc_','_cafProgram_');
    save(cafProgramFilename, 'cafProgram');
    close(h);
end