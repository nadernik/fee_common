function ShowCaVid(VIDEO,SOUND,SPEC, filename, params, showcontour)
slowfac = 1; 
if slowfac~=1
    SOUND = pvocnormalized(SOUND,1/slowfac,200);
end
if nargin<4
    filename = []; 
end
if nargin<5 || length(params)==0
    params.SOUNDfs = 40000;
    params.specTime = -.5:(1/params.SOUNDfs):.5;
    params.F = linspace(507.8125, 5976.6, 141);
    params.VIDEOfs = 20;
    params.AudBinWhenFrameStarts = 0:2000:ceil(size(VIDEO,1)/params.VIDEOfs*params.SOUNDfs); 
    params.AudBinWhenFrameEnds =  params.AudBinWhenFrameStarts + 2000; 
end
if nargin<6
    showcontour = 0; 
end
SOUNDfs = params.SOUNDfs; 
specTime = params.specTime; 
F = params.F; 
VIDEOfs = params.VIDEOfs; 
AudBinWhenFrameStarts = params.AudBinWhenFrameStarts*slowfac;
AudBinWhenFrameEnds = params.AudBinWhenFrameEnds*slowfac;
tSound = (0:AudBinWhenFrameEnds(end))/SOUNDfs;

if length(filename) == 0;
    savevid = 0;
else
    savevid = 1; 
end

 
% set(gcf, 'Position', [1400, 600, 500, 550]);shg
clf; set(gcf, 'color', 'w')

% setting up gcamp plot
subplot('position', [.1 .3 .8 .6]); 
maxproj = squeeze(max(VIDEO,[],1)); 

% clims = [0 .1]; %[0 prctile(dffVIDEO(:),99.999)]; 
clims = [0 prctile(VIDEO(:),99.996)]; % [.1 .5]; %
im = imagesc(maxproj,clims); axis image; axis off; drawnow; shg
if showcontour
    hold on
    contour(maxproj,prctile(maxproj(:),[95 95]), 'color', .5*ones(1,3));
end

% setting up spectrogram plot
subplot('position', [.1 .1 .8 .2]); 
cmap = ((gray)); cmap(1,:) = zeros(1,3); colormap(cmap); % to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
clims = [-70 -20]; %[prctile(SPEC(:), 75) prctile(SPEC(:),99)]; 
sp = imagesc(specTime,F/1000,squeeze(SPEC(1,:,:)), clims); axis tight; axis off
set(gca, 'ydir', 'normal')
hold on; plot([0 0], ylim, 'r')
drawnow

if savevid
    obj = vision.VideoFileWriter(filename, 'AudioInputPort', 1);%,  'fps', 20);
    obj.FrameRate = VIDEOfs; 
else
    a = audioplayer(SOUND(tSound>1/VIDEOfs & (tSound<(size(VIDEO,1)/VIDEOfs-1/VIDEOfs)*slowfac)),SOUNDfs); 
    play(a); tic; 
end

for framei = 1:size(VIDEO,1)
    im.CData = squeeze(VIDEO(framei,:,:));%-meanVIDEO;
    sp.CData = squeeze(SPEC(framei,:,:));
    drawnow
    if savevid
        Frame = getframe(gcf);
        Aud = SOUND(round((AudBinWhenFrameStarts(framei))+1):((round(AudBinWhenFrameStarts(framei))+floor(SOUNDfs/slowfac/VIDEOfs))));
        Aud = [Aud(:) Aud(:)]; 
%         size(Aud)
        step(obj, Frame.cdata, Aud)
    else
        while toc<(AudBinWhenFrameEnds(framei)/SOUNDfs - 1/VIDEOfs);
        end
    end
end
im.CData = maxproj;
if savevid
%     step(obj, Frame.cdata, 0*Aud)
    release(obj); 
    display('saved video')
end