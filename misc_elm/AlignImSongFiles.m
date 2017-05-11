%% choose audio and imaging folders to align
audfolder = fullfile('\\feevault\data0\AcqGui\HVCOpto\2017-04-27'); 
load(fullfile(audfolder, 'AcqGui_timestamps.mat'));
audDir = dir('initializingemptydirstruct');
imfolder = fullfile('C:\Users\emackev\inscopix\042717');
imDir = dir(fullfile(imfolder, '\*.tif')); % tif if recording uncompressed.
imDir = imDir(cellfun(@numel,(regexp( {imDir.name}', 'recording_\d+_\d+.tif')))==1);
imTimes = cellfun(@datenum,{imDir.date});

[~,ia,ic] = unique(fnums); fnums = fnums(ia); dnums = dnums(ia); nAudFrames = nAudFrames(ia);

% make sure audDir is right (only relevant files)
for fnumi = 1:length(fnums)
    fnum = fnums(fnumi);
    audDir(fnumi) = dir(fullfile(audfolder,strcat('*', sprintf('%06d',fnum), '*chan0*')));
end
% compile nImFrames
nImFrames = [];
for imi = 1:length(imDir)
    fname = imDir(imi).name;
    fnamexml = fname; 
    fnamexml(end-3:end) = '.xml'; 
    xmlstruct = xml2struct(fullfile(imfolder, fnamexml));
    try % xml format when 1 .tif file
        nImFrames(imi) = str2num(xmlstruct.recording.decompressed.file.Attributes.frames); 
    catch
        try
            nImFrames(imi) = str2num(xmlstruct.Children(4).Children(2).Attributes.Value); 
        end
        try % xml format when >1 .tif file
            nImFrames(imi) = str2num(xmlstruct.recording.decompressed.file{1}.Attributes.frames) ...
                + str2num(xmlstruct.recording.decompressed.file{2}.Attributes.frames);
        catch
            try % xml format when 1 .raw file
                nImFrames(imi) = str2num(xmlstruct.recording.file.Attributes.frames);
            end
        end
    end
end
% figure out alignment
prev = 0;
imnum = zeros(1,numel(nAudFrames));
for fi = 1:numel(nAudFrames) % for each audio file
    try
        MyDur = find(nImFrames==nAudFrames(fi)); 
        MyDur = MyDur(MyDur>prev); 
        imnum(fi) = MyDur(1); 
        prev = MyDur(1);
    catch
        display(['skipping ' num2str(fnums(fi)) ', no match'])
    end
end
iskip = imnum==0; imnum(iskip)=[]; nAudFrames(iskip)=[]; fnums(iskip)=[]; audDir(iskip)=[];dnums(iskip)=[];
plot(nAudFrames,nImFrames(imnum),'.')

% generate list of file names for CalciumData.xls
I = {imDir(imnum).name}'; I = cellfun(@(X) [X(1:end-4) '.tif'], I, 'uniformoutput', 0);
A = {audDir.name}';
[A I]; shg
%% transfer nonsongfiles to temporary folder to delete
trashdir = 'C:\Users\emackev\Downloads\Temp_To_Delete'; 
for fi = 1:length(imDir); %length(imnum)
    if sum(imnum==fi)==0
        fname = imDir(fi).name;
        movefile(fullfile(imfolder, fname),...
            fullfile(trashdir, fname))
        fnamexml = fname; 
        fnamexml(end-3:end) = '.xml'; 
        movefile(fullfile(imfolder, fnamexml),...
            fullfile(trashdir, fnamexml))
        display(['moving ' ...
            fname])
    else
        display(['keeping ' ...
            fname])
    end
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
