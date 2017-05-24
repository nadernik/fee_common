function SpecForMov = SpectrogramForMovie(DataFolder, indSong); 
load(fullfile(DataFolder, 'compiled.mat'), 'SongSpec', 'CompSoundSONG', 'SOUNDfs','VIDEOfs');
display('loaded spectrogram')
SpecForMov = zeros(size(SongSpec(1:5:end,:),1),400, 3,length(indSong));
for fi = 1:length(indSong)
    istart = ceil(indSong(fi)/VIDEOfs*200); %specfs is 200hz
    tmpsnp = SongSpec(1:5:end,istart:istart+400-1); 
    SpecForMov(:,:,:,fi) = repmat(tmpsnp,1,1,3);
end
SpecForMov(SpecForMov<prctile(SpecForMov(:),50)) = prctile(SpecForMov(:),50); % flat background
SpecForMov = -flipud(SpecForMov); % for colormap and display
SpecForMov-min(SpecForMov(:)); SpecForMov = SpecForMov/max(SpecForMov(:)); 
display('reformatted spectrogram')
