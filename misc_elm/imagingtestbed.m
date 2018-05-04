%% load and compile data 
% from excel
XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/CalciumData.xlsx');
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
Columns = XLS.textdata.Sheet1(1,:);
% analysis file
load \\feebox6\shared\emackev\GCaMP\TmpForEgui\analysis.mat
AlignSyl = 'b'; 
% define time vector
fs = 40000; 
dt = 1/fs; 
tvec = -.7:dt:1.5; 
motifnum = 1; 
% initialize
nTime = length(tvec); 
nFiles = length(dbase.SoundFiles); 
nROIs = 5; %size(dbase.ChannelFiles,2); 
GCAMP = zeros(nROIs,nTime,100); % 100 is bigger than i need
% for each file
for file = 1:nFiles
    segIsSel = find(dbase.SegmentIsSelected{file});
    segTimes = dbase.SegmentTimes{file}(segIsSel,:); % whole file, just selected segs
    segTitles = dbase.SegmentTitles{file}(segIsSel); % whole file, just selected segs
    if length(segTitles)>0 % if file has any syllables
        MotifSegInd = find(cellfun(@(X) issame(X,AlignSyl), segTitles));
        for motifi = 1:length(MotifSegInd)
            for chani = 1:nROIs
                filename = fullfile(dbase.PathName, dbase.ChannelFiles{chani}(file).name); 
                data = audioread(filename); 
                    tindstart = segTimes(MotifSegInd(motifi),1); 
                    GCAMP(chani,:,motifnum) = data(tindstart+round(tvec*fs));
            end
            motifnum = motifnum+1; 
        end
    end
    file
end
AudEx = audioread(fullfile(dbase.PathName, dbase.SoundFiles(file).name)); 
AudEx = AudEx(tindstart+round(tvec*fs));
GCAMP(:,:,motifnum:end) = []; 
%%
figure(2); clf; 
chancolors = lines(nROIs); 
% for motifi = 1:motifnum-1
%     for chani = 1:nROIs
%         plot(tvec, GCAMP(chani,:,motifi)+chani/10); 
%     end
% end
h(1) = subplot(3,1,1); 
[S,Time,F] = spectrogramELM(AudEx,fs,.001, 0); 
cmap = jet; cmap(1,:) = zeros(1,3); colormap(cmap); % to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
Plot = 10*log10(S+eps); Plot(Plot(:)<prctile(Plot(:),50)) = prctile(Plot(:),50);
imagesc(Time+tvec(1),F/1000,Plot); axis tight; 
set(gca, 'ydir', 'normal'); ylabel('Frequency (kHz)'); 

h(2) = subplot(3,1,2:3); hold on
for chani = nROIs:-1:1
    GCAMPp = (squeeze(GCAMP(chani,:,1:end))); 
    GCAMPp = bsxfun(@minus, GCAMPp, mean(GCAMPp, 1)); 
    plot(tvec, GCAMPp+chani/30, 'color', (chancolors(chani,:)+ ones(1,3))/2)
    plot(tvec, prctile(GCAMPp,40,2)+chani/30, 'color', chancolors(chani,:))
%     errorpatch_asym(tvec, prctile(GCAMPp,50,2), ...
%         prctile(GCAMPp,25,2), ...
%         prctile(GCAMPp,75,2),...
%         chancolors(chani,:), chancolors(chani,:)); 
end
xlabel('Time (s)'); ylabel('F (au), colored by ROI'); axis tight
linkaxes(h, 'x')