function [sd, param] = aSAP_getSyllSD(sylls,n)
featfilename = aSAP_getFeatureFileName([sylls.filepath{n},filesep,sylls.filename{n}]);

d = dir(featfilename);
if(length(d)==0)
    [audio,fs] = aSAP_getSyllAudio(sylls,n)
    [SAPFeats, sd] = aSAP_generateASAPFeature(audio, fs, Parameters);
    param = SAPFeats.param;
else
    load(featfilename);
    try
        sd = aSAP_uncompressSpectralDeriv(SAPFeats.specDerivFileName);
    catch
        [path,t,t] = fileparts(featfilename);
        [t,name,ext] = fileparts(SAPFeats.specDerivFileName);
        sd = aSAP_uncompressSpectralDeriv([path,filesep,name,ext]);
    end
    startndx = aSAP_conTime2FeatNdx(sylls.startTFile(n), SAPFeats.param.fs, SAPFeats.param.winstep);
    endndx = aSAP_conTime2FeatNdx(sylls.endTFile(n), SAPFeats.param.fs, SAPFeats.param.winstep);
    sd = sd(startndx:endndx,:);
    param = SAPFeats.param;
end