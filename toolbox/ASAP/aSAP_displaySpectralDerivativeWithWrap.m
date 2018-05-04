function hFig = aSAP_displaySpectralDerivativeWithWrap(m_spec_deriv, ...
        param, inchPerSec, inchPerkHz, fWrapWidthInches, ...
        startTime, startPos, endPos, bSigmoid, fScale)
 
%startTime, startPos, endPos, bSigmoid, and fScale are optional.
        
%Set any default parameters that were unspecified (except entTime)
if(~exist('startTime'))
    startTime = 0;
end
if(~exist('startPos'))
    startPos = startTime;
end
if(~exist('fScale'))
    fScale = 0;
end
if(~exist('endPos') || isinf(endPos))
    endPos = startTime + (size(m_spec_deriv,1)*(param.winstep/param.fs));    
end
if(~exist('bSigmoid'))
    bSigmoid = false;
end
if(~exist('fWrapWidthInches'))
    fWrapWidthInches = 0;
end
if(~exist('inLineText'))
    inLineText = '';
end

lengthSecs = endPos - startPos;
lengthInchs = lengthSecs * inchPerSec;
fWrapWidthSecs = fWrapWidthInches / inchPerSec;

%compute number of subplots required.
if(fWrapWidthInches == 0)
    numSubPlots = 1;
    stepSecs = lengthSecs;
else
    numSubPlots = ceil(lengthInchs / fWrapWidthInches);
    stepSecs = fWrapWidthSecs;
end

if(numSubPlots == 1)
    stepSecs = lengthSecs;
end

%Do a test run to determin outer bounding box.
test_h = figure;
aSAP_displaySpectralDerivative(m_spec_deriv, ...
        param, startTime, startPos, startPos + stepSecs, bSigmoid, ...
        fScale, inchPerSec, inchPerkHz, ...
        true, true);
set(gca,'Units','inches');
testPos = get(gca,'Position');
close(test_h);

%Plot it
    h = figure();
    set(h,'Units','inches');


%Plot all the stuff
figure(h);
margin = 1;
spacing = .1;
figPos = [2,2,testPos(3) + margin, (testPos(4)+spacing)*numSubPlots + margin];
set(h,'Position', figPos);
for(nSubPlot = numSubPlots:-1:1)
    subPos = [margin*.75, margin*.5 + (testPos(4)+spacing)*(nSubPlot-1), testPos(3), testPos(4)];
    ah(nSubPlot) = axes('Units', 'inches', 'Position', subPos);    
    aSAP_displaySpectralDerivative(m_spec_deriv, ...
        param, startTime, startPos, startPos + stepSecs, bSigmoid, ...
        fScale, inchPerSec, inchPerkHz, ...
        true, true, inLineText);
    set(gca, 'XTick',getXTicks(startPos, stepSecs, inchPerSec));
    set(gca, 'YTick',getYTicks(inchPerkHz));
    if(nSubPlot~=1)
        xlabel('');
        ylabel('');
        set(gca, 'XTickLabelMode', 'manual');
        set(gca, 'XTickLabel',[]);
        set(gca, 'YTickLabelMode', 'manual');
        set(gca, 'YTickLabel',[]);
    end
    set(gca, 'Units', 'normalized');
    startPos = startPos + stepSecs;
end

axes(ah(numSubPlots));
hFig = h;

function xTicks = getXTicks(startPos, stepSecs, inchPerSec)
xTicks = [round(startPos*10)/10:.100:startPos+stepSecs];
if(length(xTicks) <= 1)
    xTicks = [round(startPos*100)/100:.01:startPos+stepSecs];
elseif(length(xTicks) > 15)
    xTicks = [round(startPos*1)/1:1:startPos+stepSecs];
end

function yTicks = getYTicks(inchPerkHz)
yTicks = [4000,8000];


