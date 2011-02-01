function aSAP_printSAPRandomSample(numSamples, rootDir, birdId, dateDir, dnStartTime, dnEndTime)

path = [rootDir, filesep, birdId, filesep, dateDir];
d = dir(path,filesep,'*.wav']);
[modDate{1:length(d)}] = deal(d.date);
[fileName{1:length(d)}] = deal(d.name);
modDateSamp = datenum(modDate(end/2));
[year, junk] = datevec(modDateSamp);

for(nFile = 1:length(fileName))
    time(nFile) = aSAP_extractTimeFromSAPFileName(fileName{nFile}, year);
end

%Get the indices of the files that meet the criteria.
validFileNdx = find((time>dnStartTime) & (time<dnEndtime));

%Select a set of then at random.
selectedFileNdx = validFileNdx(ceil(rand(numSamples, 1).*length(validFileNdx)));

%print parameters
device = '-dwin'; %default printer
printfile = ''; %not saving to file
inchPerSec = 4;
inchPerkHz = inchPerSec/25;
wrapWidth = 7;
startTime = 0;
startPos = 0;
endPos = Inf;
bSigmoid = 1;
fScale = 7e9; %use the autoscale value of the first file  

%concat and print...
for(nSelFile = 1:length(selectedFileNdx))
    wavfilename = [path, filesep, fileName{selectedFileNdx(nSelFile)}];
    [path,name,ext] = fileparts(wavfilename);
    featfilename = [path,filesep,name,'.feat','.mat'];
    d = dir(featfilename);
    if(length(d)==0)
        aSAP_generateASAPFeatureFileFromWav(wavfilename);        
    end
    load(featfilename);
    m_spec_deriv = aSAP_uncompressSpectralDeriv(handles.SAPFeats.specDerivFileName);

    if(nSelFile == 1)
        fScale = aSAP_getSDAutoscale(m_spec_deriv);
    end
  
    printPrefix = [birdId,'-',datestr(time(selectedFileNdx(nSelFile)),30)];
    printSuffix = sprintf('-%g-%d', fScale, bSigmoid);
    
    aSAP_printSD('-dwin', printfile, m_spec_deriv, ...
        SAPFeats.param, inchPerSec, inchPerkHz, wrapWidth, ...
        startTime, startPos, endPos, bSigmoid, fScale, ...
        [printPrefix,printSuffix]);
end
