function aSAP_sylls2concatwav(sylls, syllNums, fullfilename, preBuffSec, postBuffSec, resampFs)

concatAudio = [];
for(nSyll = syllNums)
    if(strcmp(sylls.filepath{nSyll},''))
        filename = sylls.filename{nSyll};
    else
        filename = [sylls.filepath{nSyll}, filesep, sylls.filename{nSyll}];
    end
    [path,name,ext] = fileparts(filename);
    try
        %if(strcmp(ext,'wav'))
            [audio,fs] = wavread(filename);
        %else
    catch
        warning(['sylls2wavs: syllable file not found: ',filename]);
    end
    startNdx = max(1,round((sylls.startTFile(nSyll) - preBuffSec)*fs) + 1);
    endNdx = min(length(audio), round((sylls.endTFile(nSyll) + postBuffSec)*fs) + 1);
    audioSyll = audio(startNdx:endNdx);
    
    if(exist('resampFs') && fs~=resampFs)
        [p,q] = rat(resampFs / fs);
        audioSyll = resample(audioSyll, p, q);
    else
        resampFs = fs;
    end

    concatAudio = [concatAudio; audioSyll];
end

wavwrite(concatAudio, resampFs, fullfilename);


