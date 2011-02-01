function [bout_derivs, bout_files] = aSAP_getRawBoutSDsForWavFiles(path, wavfilenames, bDisplay, bPauseBetweenDisplays, bQuick)

boutBuffer = .050; %secs
param = Parameters;

hFigs = [];
bout_derivs = {};
bout_files = {};
for(nFile = 1:length(wavfilenames))
    wavfilename = wavfilenames{nFile};
    [junk,name,ext] = fileparts(wavfilename);
    [audio, fs] = wavread([path,filesep,wavfilename]);
    
    %Segment the file into bouts ...
    [syllStartTimes, syllEndTimes, noiseEst, noiseStd, soundEst, soundStd] = aSAP_segSyllablesFromRawAudio(audio, fs);
    [boutStartSyll, boutEndSyll] = aSAP_segBoutsFromRawAudio(syllStartTimes, syllEndTimes);
    
    %If there is at least one bout in the file, then cont...
    if(length(boutStartSyll) >0)    

        %Compute the SDs...
        featfilename = [path,filesep,name,'.feat','.mat'];
        d = dir(featfilename);
        if((length(d)>0) | ~bQuick)
            %If the SD has already been computed or bQuick is false, then
            %clip bouts from files complete SD.
            if(length(d)==0)
                aSAP_generateASAPFeatureFileFromWav([path,filesep,wavfilename]); 
            end
            load(featfilename);
            m_spec_deriv = aSAP_uncompressSpectralDeriv(SAPFeats.specDerivFileName);
            bout_derivs = [bout_derivs, aSAP_clipBoutsFromSD(m_spec_deriv, SAPFeats.param, boutStartSyll, boutEndSyll, syllStartTimes, syllEndTimes, boutBuffer)];
            bout_files = [bout_files, repmat({wavfilename},1,length(bout_derivs))];
        else
            %Otherwise compute the SD on just the bout clips
            startAudNdx = max(round((syllStartTimes(boutStartSyll) - boutBuffer).*fs + 1),1);
            endAudNdx = min(round((syllEndTimes(boutEndSyll) + boutBuffer).*fs + 1),length(audio)); 
            for(nBout = 1:length(boutStartSyll))
                m_spec_deriv = deriv(audio(startAudNdx(nBout):endAudNdx(nBout)),fs);
                bout_derivs = [bout_derivs, {m_spec_deriv}];
                bout_files = [bout_files, {wavfilename}];
            end
        end
        
        disp([num2str(nFile),'/',num2str(length(wavfilenames))]);
       
        %The SD of the bouts in the files have been extracted
        %Display the results if requested.
        if(bDisplay)
            close(hFigs);
            nb = length(bout_derivs);
            for(nBout = 1:nb)
                inlineText{nBout} = ['bout',num2str(nBout)];
            end
            hFigs = aSAP_displayMultipleSDwithPageBreaks(bout_derivs, ...
                            param, 7, .1, 7, ...
                            name, 7, bPauseBetweenDisplays, ...
                            zeros(1,nb), zeros(1,nb), repmat(Inf,1,nb), true, 0, ...
                            inlineText);
        end
    end 
end
    

