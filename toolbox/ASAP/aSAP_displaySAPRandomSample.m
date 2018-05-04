function hFigs = aSAP_displaySAPRandomSample(numSamples, rootDir, birdId, dateDir, startTime, endTime, fScale, figTitle, pageHeight, bPauseBetweenPages)
%see aSAP_printSD for device options.

if(~exist('figTitle'))
    figTitle = sprintf('random%s%s%s%g-%g', rootDir, birdId, dateDir, startTime, endTime);
end
if(~exist('pageHeight'))
    pageHeight = 7;
end
if(~exist('bPauseBetweenPages'))
    bPauseBetweenPages = true;
end

[filenames,path] = aSAP_getSAPFilenames(birdId, dateDir, '.wav', startTime, endTime, rootDir);

%Select a set of then at random.
selectedFileNdx = ceil(rand(numSamples, 1).*length(filenames));
selectedFileNdx = sort(selectedFileNdx);

for(nSelFile = 1:length(selectedFileNdx))
    wavfilename{nSelFile} = [path, filesep, filenames{selectedFileNdx(nSelFile)}];
end

hFigs = aSAP_displaySDofWavFiles(wavfilename, fScale, figTitle, pageHeight, bPauseBetweenPages);