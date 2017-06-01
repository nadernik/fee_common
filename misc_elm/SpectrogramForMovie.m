function SpecForMov = SpectrogramForMovie(DataFolder, indSong); 
if isstr(DataFolder)
    load(fullfile(DataFolder, 'compiled.mat'), 'SongSpec', 'CompSoundSONG', 'SOUNDfs','VIDEOfs');
    display('loaded spectrogram')
else
    SongSpec = DataFolder;
    VIDEOfs = 30; 
end

if nargin<2; indSong = 1:size(SongSpec,2)/200*VIDEOfs; end %specfs is 200hz

SpecForMov = zeros(size(SongSpec(1:3:end,:),1),400, 3,length(indSong));
for fi = 1:length(indSong)
    istart = ceil(indSong(fi)/VIDEOfs*200); %specfs is 200hz
    iend = min(istart+400-1, size(SongSpec,2)); 
    tmpsnp = nan(size(SpecForMov,1),400,1,1); 
    tmpsnp(:,1:(iend-istart+1),:,:) = SongSpec(1:3:end,istart:iend); 
    SpecForMov(:,:,:,fi) = repmat(tmpsnp,1,1,3);
end
SpecForMov(SpecForMov<prctile(SpecForMov(:),50)) = prctile(SpecForMov(:),50); % flat background
SpecForMov(isnan(SpecForMov)) = min(SpecForMov(:)); 
SpecForMov = -flipud(SpecForMov); % for colormap and display
SpecForMov-min(SpecForMov(:)); SpecForMov = SpecForMov/max(SpecForMov(:)); 
display('reformatted spectrogram')
