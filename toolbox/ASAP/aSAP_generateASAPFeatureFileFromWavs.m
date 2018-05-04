function aSAP_generateASAPFeatureFileFromWavs(wavfilenames, path)

%First make sure that Features have been computed for all the wavs.
for(nFile = 1:length(wavfilenames))
    wavfilename = wavfilenames{nFile};
    
    %Check if feature file already exists...
    [path,name,ext] = fileparts(wavfilename);
    featfilename = [path,filesep,name,'.feat','.mat'];
    d = dir(featfilename);
    if(length(d)==0)
        aSAP_generateASAPFeatureFileFromWav(wavfilename);        
    end
end