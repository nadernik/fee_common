function sylls = aSAP_appendFeatures2Sylls(sylls, overridePath)

sylls.mu_AM = repmat(NaN,length(sylls.filename), 1);
sylls.var_AM = repmat(NaN,length(sylls.filename), 1);
sylls.mu_FM = repmat(NaN,length(sylls.filename), 1);
sylls.var_FM = repmat(NaN,length(sylls.filename), 1);
sylls.mu_Entropy = repmat(NaN,length(sylls.filename), 1);
sylls.var_Entropy = repmat(NaN,length(sylls.filename), 1);
sylls.mu_gravity_center = repmat(NaN,length(sylls.filename), 1);
sylls.var_gravity_center = repmat(NaN,length(sylls.filename), 1);
sylls.mu_PitchGoodness = repmat(NaN,length(sylls.filename), 1);
sylls.var_PitchGoodness = repmat(NaN,length(sylls.filename), 1);
sylls.mu_Pitch = repmat(NaN,length(sylls.filename), 1);
sylls.var_Pitch = repmat(NaN,length(sylls.filename), 1);

currFeaturesFilename = '';
for(nSyll = 1:length(sylls.filename))
    if(~strcmp(sylls.filename{nSyll}, currFeaturesFilename))
        if(exist('overridePath'))
            sylls.filepath{nSyll} = overridePath;
            path = overridePath;
        else
            path = sylls.filepath{nSyll};
        end
        [p,name,ext] = fileparts(sylls.filename{nSyll});
        featfilename = [path,filesep,name,'.feat','.mat'];
        d = dir(featfilename);
        if(length(d) == 0)
            aSAP_generateASAPFeatureFileFromWav([path,filesep,sylls.filename{nSyll}],Parameters);
        end
        try
            load(featfilename);       
            bLoaded = true;
        catch
            bLoaded = false;
        end
    end
    
    if(bLoaded)
        startNdx = aSAP_conTime2FeatNdx(sylls.startTFile(nSyll), SAPFeats.param.fs, SAPFeats.param.winstep);
        endNdx = aSAP_conTime2FeatNdx(sylls.endTFile(nSyll), SAPFeats.param.fs, SAPFeats.param.winstep);

        %Otherwise syllable is very close to end of file.
        if(endNdx <= length(SAPFeats.m_AM))    
            sylls.mu_AM(nSyll) = mean(SAPFeats.m_AM(startNdx:endNdx));
            sylls.var_AM(nSyll) = var(SAPFeats.m_AM(startNdx:endNdx));
            sylls.mu_FM(nSyll) = mean(SAPFeats.m_FM(startNdx:endNdx));
            sylls.var_FM(nSyll) = var(SAPFeats.m_FM(startNdx:endNdx));
            sylls.mu_Entropy(nSyll) = mean(SAPFeats.m_Entropy(startNdx:endNdx));
            sylls.var_Entropy(nSyll) = var(SAPFeats.m_Entropy(startNdx:endNdx));
            sylls.mu_gravity_center(nSyll) = mean(SAPFeats.gravity_center(startNdx:endNdx));
            sylls.var_gravity_center(nSyll) = var(SAPFeats.gravity_center(startNdx:endNdx));
            sylls.mu_PitchGoodness(nSyll) = mean(SAPFeats.m_PitchGoodness(startNdx:endNdx));
            sylls.var_PitchGoodness(nSyll) = var(SAPFeats.m_PitchGoodness(startNdx:endNdx));
            sylls.mu_Pitch(nSyll) = mean(SAPFeats.m_Pitch(startNdx:endNdx));
            sylls.var_Pitch(nSyll) = var(SAPFeats.m_Pitch(startNdx:endNdx));     
        end
    end
    nSyll
end
