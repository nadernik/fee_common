function aSAP_batchExperFeatureCompute(exper,filenums)

%Author Aaron Andalman 2006.01
%
%Batch computation of SAP features for experiment audio
%using SAM ver 1.0.  

param = Parameters;
[path,name,ext] = fileparts(exper.dir);

for(numFile = filenums)
    %Load the file...
    [audio] = loadAudio(exper,numFile);
    fs = exper.desiredInSampRate;
    
    %compute the features...
    [m_spec_deriv , m_AM, m_FM ,m_Entropy , m_amplitude ,gravity_center, m_PitchGoodness , m_Pitch , Pitch_chose , Pitch_weight ]= deriv(audio,fs);

    %Put file information into feature structure
    SAPFeats.experdir = exper.dir;
    SAPFeats.experFilenum = numFile;
    SAPFeats.lengthAudio = length(audio);
    SAPFeats.audioSampRate = fs;

    %extract date from SAP wav name
    SAPFeats.time = extractExperFilenumTime(exper,numFile);

    %Put the features into the file
    SAPFeats.param = param;
    SAPFeats.m_AM = m_AM;
    SAPFeats.m_FM = m_FM;
    SAPFeats.m_Entropy = m_Entropy;
    SAPFeats.m_amplitude = m_amplitude;
    SAPFeats.gravity_center = gravity_center;
    SAPFeats.m_PitchGoodness = m_PitchGoodness;
    SAPFeats.m_Pitch = m_Pitch;
    SAPFeats.Pitch_chose = Pitch_chose;
    SAPFeats.Pitch_weight = Pitch_weight;   

    %Compress and store the spectral derivative
    [path,fname,ext] = getExperDatafile(exper,numFile,exper.audioCh);
    SAPFeats.specDerivFileName = [fname,'.sd'];
    compressSpectralDeriv(m_spec_deriv, SAPFeats.specDerivFileName);        

    %Store in a .mat file.
    matname = [fname,'.feat','.mat'];
    save(matname, 'SAPFeats');
end
