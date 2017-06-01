function row2movie(rowpath, savepath)
% load the row
load(rowpath, 'SOUND', 'VIDEO', 'SOUNDfs', 'VIDEOfs')

% compute the spectrogram, if haven't already
variableInfo = who('-file', rowpath);
if ~ismember('SongSpec', variableInfo) 
    display('need to compute song spectrogram... only need to do this once... could take about a minute')
    tic; [SongSpec,SpecTime,SpecF] = spectrogramELM(SOUND,SOUNDfs,.005, 0); toc
    SongSpec = 10*log10(SongSpec); 
    display('computed spectrogram')
    save(rowpath, 'SongSpec', 'SpecTime', 'SpecF', ...
        '-append');
    display('saved spectrogram')
else 
    load(rowpath, 'SongSpec')
end

% do background subtraction, if haven't already
if 1; ~ismember('VIDEObs_smooth', variableInfo) 
    Y = permute(VIDEO,[2 3 1]); 
    Y = Y - min(Y(:)); 
    
    % subtract background
    [Yest, results] = local_background(Y, [], 25); 
    VIDEObs = permute(Y-Yest,[3 1 2]); 

    % smooth it
    VIDEObs_smooth = 0*VIDEObs; 
    for fi = 1:size(VIDEObs,1)
        tmp = squeeze(VIDEObs(fi,:,:));
        tmp = imgaussfilt(tmp, 3, 'Padding', 'symmetric'); % low pass filter
        VIDEObs_smooth(fi,:,:) = tmp; 
    end
    save(rowpath, 'VIDEObs_smooth', ...
        '-append');   
    display('computed local background'); 
else
    load(rowpath, 'VIDEObs_smooth')
end
    
    
% Compile movie
SpecForMov = SpectrogramForMovie(SongSpec, 1:size(VIDEObs_smooth,1));
VidForMov = repmat(permute(VIDEObs_smooth,[2,3,1]),1,1,1, 3);
VidForMov = permute(VidForMov, [1 2 4 3]); 
VidForMov(VidForMov<prctile(VidForMov(:),50)) = prctile(VidForMov(:),50); 
VidForMov = VidForMov-min(VidForMov(:)); 
VidForMov = VidForMov/prctile(VidForMov(:),99.996); 
ToPlay = [VidForMov; 1-SpecForMov]; 
% implay(ToPlay,VIDEOfs);

% save the movie
obj = vision.VideoFileWriter(savepath, 'AudioInputPort', 1);%,  'fps', 20);
obj.FrameRate = VIDEOfs; 
for framei = 1:size(VIDEO,1)
    istart = floor(framei*SOUNDfs/VIDEOfs); 
    Aud = SOUND(istart:min((istart+floor(SOUNDfs/VIDEOfs)-1),length(SOUND)));
    if length(Aud)<floor(SOUNDfs/VIDEOfs)
        Aud(end:floor(SOUNDfs/VIDEOfs)) = 0;
    end
    step(obj, squeeze(ToPlay(:,:,:,framei)), Aud)
    display(framei)
end
release(obj)
end