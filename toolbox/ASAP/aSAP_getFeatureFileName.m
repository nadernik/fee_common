function featfilename = aSAP_getFeatureFileName(wavfilename)
[path,name,ext] = fileparts(wavfilename);
featfilename = [path,filesep,name,'.feat','.mat'];
