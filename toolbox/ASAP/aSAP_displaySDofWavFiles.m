function hFigs = aSAP_displaySDofWavFiles(wavFullFilenames, fScale, figTitle, pageHeight, bPauseBetweenPages)
%see aSAP_printSD for device options.

if(~exist('figTitle'))
    figTitle = '';
end
if(~exist('pageHeight'))
    pageHeight = 7;
end
if(~exist('bPauseBetweenPages'))
    bPauseBetweenPages = true;
end

for(nFile=1:length(wavFullFilenames))
    wavfilename = wavFullFilenames{nFile};
    [path,name,ext] = fileparts(wavfilename);
    featfilename = [path,filesep,name,'.feat','.mat'];
    d = dir(featfilename);
    if(length(d)==0)
        aSAP_generateASAPFeatureFileFromWav(wavfilename);        
    end
    load(featfilename);
    m_spec_derivs{nFile} = aSAP_uncompressSpectralDeriv(SAPFeats.specDerivFileName);
    inLineText{nFile} = name;
    startTime(nFile) = 0;
    startPos(nFile) = 0;
    endPos(nFile) = Inf;
    bSigmoid = true;
end
    
inchPerSec = 4;
inchPerkHz = .1;
fWrapWidthInches = 7;
hFigs = aSAP_displayMultipleSDwithPageBreaks(m_spec_derivs, ...
        SAPFeats.param, inchPerSec, inchPerkHz, fWrapWidthInches, ...
        figTitle, pageHeight, bPauseBetweenPages, ...
        startTime, startPos, endPos, bSigmoid, fScale, ...
        inLineText);