function [filename, path] = aSAP_getRandSampSAPFilenames(numSamples, birdId, dateDir, startTime, endTime, rootDir)
%see aSAP_printSD for device options.

if(~exist('rootDir'))
    rootDir = 'C:\aarecordings';
end

[filenames,path] = aSAP_getSAPFilenames(birdId, dateDir, '.wav', startTime, endTime, rootDir);

if(length(filenames)>0 & numSamples>0)
	%Select a set of then at random.
	selectedFileNdx = ceil(rand(numSamples, 1).*length(filenames));
	selectedFileNdx = sort(selectedFileNdx);

    filename = filenames(selectedFileNdx);
else
    filename = {};
end