function HandpickROIs(VIDEO,SOUND,SPEC, filename, params, showcontour)

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
AudBinWhenFrameStarts = params.AudBinWhenFrameStarts;
AudBinWhenFrameEnds = params.AudBinWhenFrameEnds;
tSound = (0:AudBinWhenFrameEnds(end))/SOUNDfs;

if length(filename) == 0;
    savevid = 0;
else
    savevid = 1; 
end

maxproj = squeeze(max(VIDEO,[],1));
figure; 
imagesc(maxproj); colormap gray
axis equal; axis off
hold on
clicking = 1; 
x = []; 
y = []; 
i = 1; 
while clicking
    [x(i),y(i)] = ginput(1);
    plot(x(i),y(i), 'r.') 
    if x(i)<0 | y(i)<0
        x = x(1:end-1); y = y(1:end-1); 
        clicking = 0;
    end
    i = i+1;
end
ROIx = x; 
ROIy = y; 

clf; colormap gray
imagesc(maxproj, [min(maxproj(:)) max(maxproj(:))])
hold on; axis equal; axis off
umPerPixel = 900/400; 
plot(50+[0 100]/umPerPixel, [50 50],  'color', [1 1 1])
text(mean(50+[0 100]/umPerPixel), [50], '100 um','color', [1 1 1],'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
roicolors = lines(length(ROIx));
[y x] = size(maxproj); 
[X1,X2] = meshgrid(1:x,1:y);
PlaceBlob = zeros(y,x,length(ROIx));
for roi = 1:length(ROIx)
    PlaceBlob(:,:,roi) = reshape(mvnpdf([X1(:) X2(:)], [ROIx(roi) ROIy(roi)], ...
        20/umPerPixel*eye(2)),y,x); 
    contour(squeeze(PlaceBlob(:,:,roi)), 1, 'color',roicolors(roi,:));
end
stROI = permute(repmat(PlaceBlob, 1,1,1,size(VIDEO,1)),[4,1,2,3]); 
stVid = repmat(VIDEO,1,1,1,length(ROIx));
tr = squeeze(sum(sum(stROI.*stVid,2),3));
figure; 
h = subplot(3,1,1)
spectrogramELM(SOUND,SOUNDfs, .005, 1);
g = subplot(3,1,2:3)
plot((1:length(tr))/VIDEOfs, tr)
linkaxes([h g],'x')
xlabel('Time (s)')
ylabel('deltaF/F')