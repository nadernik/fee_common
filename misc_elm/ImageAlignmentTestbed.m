function ImageAlignmentTestbed
%% checking alignment

%6865
% Jan 25-30 6865
% Row = [2139 2140 2155 2156 2183 2184 2187 2188 2213 2214 2221 2222 2245 2246]; 
% Date = [7 7 9 9 10 10 11 11 12 12 13 13 14 14];
% Age = Date + 66; %67dph on jan 1
% % Jan 7-14 6865
% Row = [Row 2345:2346 2388:2389 2392:2393 2428:2429]; 
% Date = [25 25 26 26 29 29 30 30];
% Age = [Age (Date + 66)]; %67dph on jan 1
% % Feb 5-9 6865
% Row = [Row 2440:2441 2491:2492 2520:2521]; 
% Date = [5 5 7 7 8 8];
% Age = [Age (Date + 98)]; %98dph on feb 1

%6719
% Row = [1212:1213 1238:1239 1272:1273 ...
%     1380:1381 1434:1435 1471:1472 1504:1505 ...
%     2299:2300]; 
% Date = [[20 20 21 21 24 24]-31 ... % 31 days in October
%     3 3 12 12 15 15 16 16 ...
%     [17 17]+60]; % 60 days Nov 1 to Jan 1
% Age = Date + 186; %187dph on Nov 1

%6701
Row = [1542:1543 1550:1551 1569:1570 1589:1590 1596:1597 1607:1608]; 
Date = [16 16 18 18 20 20 28 28 29 29 30 30];
Row = [1542:1543 1569:1570 1589:1590 1596:1597 1607:1608 ...
    1614:1615  2294:2295]; 
Date = [16 16 20 20 28 28 29 29 30 30 ...
    ([15 15] + 30) ([ 17 17] +61)]; % 30 days in nov. 31 in dec
Age = Date + 197; %198dph on nov 1

savedir = 'E:\ProcessedCalciumData\AllRows'; %'Z:\emackev\inscopix'; 'C:\Users\emackev\Documents\StuffICanDelete';

for ri = 1:length(Row)
    load(fullfile(savedir, ['CaELM_row' num2str(Row(ri))]), 'VIDEO') %, 'VIDEOfs', ...
%         'SOUND', 'SOUNDfs', 'nFrames', ...
%         'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
%         'SPEC', 'specTime', 'F');%,'VIDEO'); 
%     IM{ri} = squeeze(std(VIDEO,1)./mean(VIDEO,1)); 
    IM{ri} = squeeze(max(VIDEO,[],1)); 
end

figure(1)
filename = 'C:\Users\emackev\Downloads\stabilityGIF.gif'; 
clim = [prctile(IM{1}(:),10) prctile(IM{1}(:),99.995)]; 
for i = 1:1
    shg
    for ri = 1:length(Row)
        imagesc(IM{ri}, [prctile(IM{ri}(:),10) prctile(IM{ri}(:),99.999)]); axis image; colormap gray; axis off; 
        title(['6701, ' num2str(Age(ri)) ' dph'])
        drawnow; pause(.4); 
        frame = getframe(1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if ri == 1;
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append');
        end
    end
end
% registration
figure(1); clf; subplot(2,1,1)
cw = patch([0 1 1 0 0], [0 0 1 1 0], 'r');
ccw = patch([0 1 1 0 0]+1, [0 0 1 1 0], 'g');
left = patch([0 1 1 0 0]-.5, [0 0 1 1 0]+3, 'c');
right = patch([0 1 1 0 0]+1.5, [0 0 1 1 0]+3, 'm');
up = patch([0 1 1 0 0]+.5, [0 0 1 1 0]+4, 'c');
down = patch([0 1 1 0 0]+.5, [0 0 1 1 0]+2, 'm');

axis off
A = IM{1}; B = IM{4}; 
A = A/max(A(:)); B = B/max(B(:)); 
angle = 0; 
translation = [0 0]
set(ccw, 'buttondownfcn', @(h,x) RotateAndPlot(A, B,1));
set(cw, 'buttondownfcn', @(h,x) RotateAndPlot(A, B,-1));
set(down, 'buttondownfcn', @(h,x) TranslateAndPlot(A, B,[0 1]));
set(up, 'buttondownfcn', @(h,x) TranslateAndPlot(A, B,[0 -1]));
set(right, 'buttondownfcn', @(h,x) TranslateAndPlot(A, B,[1 0]));
set(left, 'buttondownfcn', @(h,x) TranslateAndPlot(A, B,[-1 0]));

function RotateAndPlot(im1, im2, step)
    angle = angle+step; 
    im2 =  imrotate(im2,angle, 'crop'); 
    im2 =  imtranslate(im2,translation); 
    subplot(2,1,2)
    PlotIms(im1,im2)
    display([num2str(angle) ' degrees; ' num2str(translation) ' pixels'])
end
function TranslateAndPlot(im1, im2, step)
    im2 =  imrotate(im2,angle, 'crop'); 
    translation = translation+step; 
    im2 =  imtranslate(im2,translation); 
    subplot(2,1,2)
    PlotIms(im1,im2)
    display([num2str(angle) ' degrees; ' num2str(translation) ' pixels'])
end
function PlotIms(im1,im2)
    im2 =  imrotate(im2,angle, 'crop'); 
    im2 =  imtranslate(im2,translation); 
    tmp = abs(im1-im2);
    tmp = tmp - imgaussfilt(tmp,10, 'Padding', 'symmetric'); % high pass filter
%     image(cat(3,im1,im2,im1)); drawnow
    imagesc(tmp); drawnow
end

subplot(2,1,2)

for ri = 0:10:360
    B = imrotate(A,ri, 'crop'); 
    image(cat(3,A,B,A)); 
%     imshowpair(A,B, 'falsecolor')
    drawnow; pause(.1)
end
%%% DO GUIish THING TO TRY DIFFERENT TRANSFORMS

% f2245 = squeeze(VIDEO(1,:,:));
% imagesc(squeeze(VIDEO(1,:,:))); axis image; colormap gray; axis off
sound(sin(1:1000))
% ShowCaVid(VIDEO,SOUND,SPEC,[] ,params,showcontour)%, fullfile(savedir, 'tmp.avi'))
end