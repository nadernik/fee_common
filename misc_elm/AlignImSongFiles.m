%% choose audio and imaging folders to align
audfolder = 'E:\TempFileTransfer\2016-11-12'; 
load(fullfile(audfolder, 'AcqGui_timestamps.mat'));
audDir = dir(fullfile(audfolder,'*chan0*'));
imfolder = 'C:\Users\emackev\inscopix\Testing\ToDecompress';
imDir = dir(fullfile(imfolder, '\*.raw'));
imTimes = cellfun(@datenum,{imDir.date});

% compile nImFrames
clear nImFrames
for imi = 1:length(imDir)
    fname = imDir(imi).name;
    fnamexml = fname; 
    fnamexml(end-3:end) = '.xml'; 
    xmlstruct = xml2struct(fullfile(imfolder, fnamexml));
    nImFrames(imi) = str2num(xmlstruct.recording.file.Attributes.frames);
end
% figure out alignment
prev = 0;
for fi = 1:numel(nAudFrames) % for each audio file
    MyDur = find(nImFrames==nAudFrames(fi)); 
    MyDur = MyDur(MyDur>prev); 
    imnum(fi) = MyDur(1); 
    prev = MyDur(1);
end
plot(nAudFrames,nImFrames(imnum),'.')

% generate list of file names for CalciumData.xls
I = {imDir.name}'; I = cellfun(@(X) [X(1:end-4) '.tif'], I, 'uniformoutput', 0)
A = {audDir.name}';
%% transfer files to folder for easy decompression
mkdir(fullfile(imfolder, 'ToDecompress')); 
for fi = 1:length(imnum)
    fname = imDir(imnum(fi)).name;
    fnamexml = fname; 
    fnamexml(end-3:end) = '.xml'; 
    movefile(fullfile(imfolder, fname),...
        fullfile(imfolder, 'ToDecompress', fname))
    movefile(fullfile(imfolder, fnamexml),...
        fullfile(imfolder, 'ToDecompress', fnamexml))
    display(['moved ' ...
        fullfile(imfolder, 'ToDecompress', fname)])
    
%     try
%         fnametif = fname; 
%         fnametif(end-3:end) = '.tif'; 
%         movefile(fullfile(imfolder, fnametif),...
%             fullfile(imfolder, 'ToDecompress', fnametif))
%         display(['moved tif too'])
%     catch
%         
%     end

end
