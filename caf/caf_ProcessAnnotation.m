function caf_ProcessAnnotation(annotationName, currChan, strPrefix, fcn_cafProgram, strBirdInfo, varargin)
%Takes an annotation and computes various statistics on all of its
%segments.

%Default Parameters
P.preSyllStartBuffer = .015; %seconds before start syll
P.postSyllEndBuffer = .015; %seconds
P.whichAnalyses = [1,3,5]; %[1:5] %1:miscstats 2:cafProgram 3:pitch 4:current 5:rawaudio
P.randFraction = 1;
P.randNumber = 0;
P.bOnlyLabled = false;
P.durationRange = [-Inf,Inf]; %seconds
P.bUse = []; %specify exactly which syllables to use. %Overrides all other selections.
P.minPitchFreq = 400; % minimum pitch that can be estimated
P.maxPitchFreq = 2000; % maximum pitch that can be estimated
P = parseargs(P,varargin{:});

%Load the annotation we just created
annotation = aaLoadHashtable(annotationName);
if(isempty(annotation.elements))
    return;
end
[filenames, annots] = annot_GetOrderedElements(annotation);


%Determine which segments to analyze:
numSylls = 0;
durations = [];
for nAnnot = 1:length(annots)
    numSylls = numSylls + length(annots{nAnnot}.segFileStartTimes);
    durations = [durations, annots{nAnnot}.segFileEndTimes - annots{nAnnot}.segFileStartTimes];
end
bDura = (durations > P.durationRange(1) & durations < P.durationRange(2));
bRand = rand(numSylls,1) <= P.randFraction;
bRand = bRand & bDura';
if(P.randNumber ~= 0)
    bRand = zeros(numSylls,1);
    temp = randperm(sum(bDura));
    ndx = find(bDura);
    if(P.randNumber<=length(ndx))
        bRand(ndx(temp(1:P.randNumber))) = 1;
    else
        error('Requested too many syllables');
    end
end
if(~isempty(P.bUse))
    bRand = P.bUse;
end

%initialize various data stores
cafProgram.annotationName = annotationName;
cafProgram.fcn_cafProgram = fcn_cafProgram;
cafProgram.strBirdInfo = strBirdInfo;
pitch.annotationName = annotationName;
current.annotationName = annotationName;
misc.annotationName = annotationName;
rawaudio.annotationName = annotationName;

%low pass filter for subsampling
fs = annots{1}.exper.desiredInSampRate;
lpSubsamp = v3lp(50, fs, 500, 35);
lpSubsamp.Numerator = lpSubsamp.Numerator ./ sum(lpSubsamp.Numerator);

for(tempn = P.whichAnalyses)
    segNum = 0;
    count = 0;
    h = waitbar(0);
    for nAnnot = 1:length(annots)
        annot = annots{nAnnot};    
        if(annot.exper.desiredInSampRate ~= fs)
            error('caf_ProcessAnnotation assumpes all recording in annotaion have same sampling rate.');
        end
        
        audio = [];
        curr = [];

        for nSeg = 1:length(annot.segFileStartTimes)
            segNum = segNum + 1;
            bRand(segNum) = bRand(segNum) && (~P.bOnlyLabled || (annot.segType(nSeg)~=-1));
            %If selected by rand and meets labling contraints.
            if(bRand(segNum))
                if(isempty(audio))
                    audio = loadAudio(annot.exper, annot.filenum);
                    audio = audio - mean(audio);
                    if(tempn == 4)
                        curr = loadData(annot.exper, annot.filenum, currChan);
                        curr = curr - mean(curr);
                    end
                end
                
                count = count + 1; 
                startNdx = max(1, round(annot.segFileStartTimes(nSeg)*fs - (P.preSyllStartBuffer*fs) + 1)); 
                endNdx = min(length(audio), round(annot.segFileEndTimes(nSeg)*fs + (P.postSyllEndBuffer*fs)+ 1));              
                syllAudio = audio(startNdx:endNdx);

                if(tempn == 1)
                %misc              
                    misc.segs(count).key = filenames{nAnnot};
                    misc.segs(count).absStart = annot.segAbsStartTimes(nSeg);
                    misc.segs(count).duration = (endNdx - startNdx)/fs; %annot.segFileEndTimes(nSeg) - annot.segFileStartTimes(nSeg);
                    misc.segs(count).fStartTime = (startNdx - 1)/fs;%annot.segFileStartTimes(nSeg);
                    misc.segs(count).fEndTime = (endNdx-1)/fs;%annot.segFileEndTimes(nSeg);
                    misc.segs(count).segType = annot.segType(nSeg);
                    misc.segs(count).fs = fs;
                    
                    % find noise in syllable audio
%                     [start_times end_times] = find_noise_in_audio(syllAudio, fs);
%                     misc.segs(count).fNoiseStartTime = start_times;
%                     misc.segs(count).fNoiseEndTime = end_times;
                    
                    %BEGIN: Tatsuo's code for masking and stim.                                       
                    %convert mask times to array of 0s and 1s
                    syllable = zeros(annot.length,1); % array of 0s and 1s
                    syllable(startNdx:endNdx) = 1;

                    %mask info
                    misc.segs(count).maskTime = [];
                    if (isfield(annot, 'maskFileStartTimes'))
                        bMask = zeros(annot.length,1); %(0: no mask, 1: mask)
                        for n=1:length(annot.maskFileStartTimes)
                            bMask(annot.maskFileStartTimes(n):annot.maskFileEndTimes(n)) = 1;
                        end
                        isMask = false; % default
                        SyllMask = syllable & bMask;
                        if sum(SyllMask)~=0
                            isMask = true;
                        end

                        if isMask
                            misc.segs(count).maskTime = ((find(SyllMask)-startNdx-1)/P.fs)'; % relative to syllables onset (s)                 
                        end                            
                    end

                    %stim info
                    misc.segs(count).stimTime = [];
                    misc.segs(count).stimAmp = nan;
                    if (isfield(annot,'stimFileStartTimes')) % masked syllable
                        bStim = zeros(annot.length,1); % array of 0s and 1s. (0: no mask, 1: mask)
                        for n=1:length(annot.stimFileStartTimes) % for all the stim events
                            bStim(annot.stimFileStartTimes(n):annot.stimFileEndTimes(n)) = 1;
                        end                                               
                        isStim = false; % default                                               
                        SyllStim = syllable & bStim;
                        if sum(SyllStim)~=0
                            isStim = true;
                        end                                                                      
                        if isStim
                            misc.segs(count).stimTime = ((find(SyllStim)-startNdx-1)/P.fs)'; % relative to syllables onset (s)
                            if(isfield(annot,'stimAmp'))
                                misc.segs(count).stimAmp = annot.stimAmp;                            
                            end
                        end
                    end 
                    %END: Tatsuo's code for masking and stim.
                    
                elseif(tempn ==2)
                %RMS amplitude
                    cafProgram.segs(count).key = filenames{nAnnot};
                    cafProgram.segs(count).absStart = annot.segAbsStartTimes(nSeg);
                    [t, t, t, t, t, t, ...
                     dafPower, songPower, songStat, intermediates] = feval(fcn_cafProgram, 'bDebug', false, 'bQuick', true, ...
                                                  'fcnBirdInfo', strBirdInfo,...
                                                  'audio', syllAudio, ...
                                                  'fs', fs, ...
                                                  'tdt_fs', fs);
                    %Subsamples to match Pitch time samples.
                    dafPower = dafPower(rem(P.winSize/2,P.winStep):P.winStep:end);
                    songPower = songPower(rem(P.winSize/2,P.winStep):P.winStep:end);
                    songStat = filtfilt(lpSubsamp.Numerator, 1, songStat);
                    songStat = songStat(rem(P.winSize/2,P.winStep):P.winStep:end);
                    fields = fieldnames(intermediates);
                    for(nField = 1:length(fields))
                        sig = intermediates.(fields{nField});
                        sig = filtfilt(lpSubsamp.Numerator, 1, sig);
                        sig = sig(rem(P.winSize/2,P.winStep):P.winStep:end);                    
                        intermediates.(fields{nField})=  sig;
                    end
                    cafProgram.segs(count).dafPower = dafPower;
                    cafProgram.segs(count).songPower = songPower;
                    cafProgram.segs(count).songStat = songStat;
                    cafProgram.segs(count).intermediates = intermediates;
                
                elseif(tempn ==3)
                %Compute pitch
                    pitch.segs(count).key = filenames{nAnnot};
                    pitch.segs(count).absStart = annot.segAbsStartTimes(nSeg);
                    [pi, pg, hp, pt, entropy] = estimatePitch(syllAudio, fs, 'minPitchFreq', P.minPitchFreq, 'maxPitchFreq', P.maxPitchFreq);
                    pitch.segs(count).pitch = pi;
                    pitch.segs(count).pitchGoodness = pg;
                    pitch.segs(count).harmonicPower = hp;
                    pitch.segs(count).pitchTime = pt; 
                    pitch.segs(count).entropy = entropy;

                elseif(tempn ==4)
                %Segment current
                    current.segs(count).key = filenames{nAnnot};
                    current.segs(count).absStart = annot.segAbsStartTimes(nSeg);
                    current.segs(count).curr = curr(startNdx:endNdx);

                elseif(tempn ==5)
                %raw audio (demeaned)
                    rawaudio.segs(count).key = filenames{nAnnot};
                    rawaudio.segs(count).absStart = annot.segAbsStartTimes(nSeg);
                    rawaudio.segs(count).audio = syllAudio;                                        
                end

            end
        end
        waitbar(segNum/numSylls, h, [num2str(nAnnot), ' of ', num2str(length(annots))]);
    end

    %Save the computed values.
    %strRand = '';
    %if(P.randFraction ~= 1)
    %    strRand = [num2str(P.randFraction*100 + rand),'_'];
    %end
    %if(P.randNumber ~= 0)
    %    strRand = [num2str(P.randNumber + rand),'_'];
    %end
    [pathstr, name, ext] = fileparts(annotationName);
    ndxAnnot = strfind(name, 'annotation');
    if(~isempty(ndxAnnot))
        nameStart = name(1:ndxAnnot-1);
        nameEnd = name(ndxAnnot+10:end);
    else
        nameStart = name;
        nameEnd = '';
    end
    if(tempn == 2)
    cafProgram.bRand = bRand;
    save([pathstr,filesep,nameStart,strPrefix,'_cafProgram',nameEnd, ext], 'cafProgram');
    clear powerTotal;
    elseif(tempn == 3)
    pitch.bRand = bRand;      
    save([pathstr,filesep,nameStart,strPrefix,'_pitch',nameEnd,ext], 'pitch');
    clear pitch;
    elseif(tempn == 4)
    current.bRand = bRand;
    save([pathstr,filesep,nameStart,strPrefix,'_current',nameEnd,ext],'current');
    clear current;
    elseif(tempn == 1)
    misc.bRand = bRand;
    save([pathstr,filesep,nameStart,strPrefix,'_misc',nameEnd,ext], 'misc', '-v6');
    clear misc;
    elseif(tempn == 5)
    rawaudio.bRand = bRand;  
    save([pathstr,filesep,nameStart,strPrefix,'_audio',nameEnd,ext], 'rawaudio');
    clear rawaudio;
    end
    close(h);
end
