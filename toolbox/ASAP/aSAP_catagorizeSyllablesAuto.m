function [templateNdxAssigned, matchScores] = aSAP_catagorizeSyllablesAuto(sylls, templates)

%The templates struct should be generated using aSAP_TemplateDesigner and
%loaded from the saved file.  Multiple templates can be combined for
%simultaneous sorting.

%sylls is returned by getRawBoutAndSyllSummaryForWavFiles.

jitterMS = .010;
matchThreshold = 1;

currfilename = '';
for(nSyll = 1:length(sylls.startTFile))
    if(~strcmp(sylls.filename{nSyll},currfilename))
        currfilepath = sylls.filepath{nSyll};
        currfilename = sylls.filename{nSyll};
        if(~strcmp(currfilepath,''))
            currfilename = [currfilepath,filesep,currfilename];
        end
        [path,name,ext] = fileparts(currfilename);
        featfilename = [path,filesep,name,'.feat','.mat'];
        d = dir(featfilename);
        if(length(d)==0)
            aSAP_generateASAPFeatureFileFromWav(currfilename);        
        end
        load(featfilename);
    end
    
    startTime = sylls.startTFile(nSyll) - .015;
    endTime = sylls.endTFile(nSyll) + .005;
    feats = aSAP_clipSAPFeats(SAPFeats, startTime, endTime);
    feats = feats{1};
    
    for(nTemp = 1:length(templates))
        matchScores(nSyll, nTemp) = aSAP_computeMatchScore1(feats, templates{nTemp}, jitterMS, false);   
    end
    nSyll
end

[topScore, templateNdxAssigned] = max(matchScores, [], 2);
templateNdxAssigned(topScore<matchThreshold) = 0 ;