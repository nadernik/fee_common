function hFig = aSAP_displayMultipleSD(m_spec_derivs, ...
        param, inchPerSec, inchPerkHz, fWrapWidthInches, ...
        startTime, startPos, endPos, bSigmoid, fScale, ...
        inLineText)
 
%m_spec_derivs is a cell array of all the m_spec_deriv you would like
%displayed consequtively.
%param: all the m_spec_derivs must share the same parameters, atleast for
%now.
%startTime, startPos, endPos are arrays of the length of m_spec_derivs.
%bSigmoid and fScale are scalars.
%inLine text is an arry of length m_spec_Derivs.

%Set any default parameters that were unspecified (except entTime)
numDerivs = length(m_spec_derivs);
if(~exist('startTime'))
    startTime = zeros(1,numDerivs);
end
if(~exist('startPos'))
    startPos = startTime;
end
if(~exist('fScale'))
    fScale = 0;
end
if(~exist('endPos'))
    for(nDeriv = 1:numDerivs)
        endPos(nDeriv) = startTime(nDeriv) + (size(m_spec_derivs{nDeriv},1)*(param.winstep/param.fs));
    end   
else
    for(nDeriv = 1:numDerivs)
        if(isinf(endPos(nDeriv)))
            endPos(nDeriv) = startTime(nDeriv) + (size(m_spec_derivs{nDeriv},1)*(param.winstep/param.fs));
        end
    end
end
if(~exist('bSigmoid'))
    bSigmoid = false;
end
if(~exist('fWrapWidthInches'))
    fWrapWidthInches = 0;
end
if(~exist('inLineText') || (length(inLineText)==0))
    inLineText(1:numDerivs) = {''};
end

%compute total # of inches of song:
m_deriv_spacing = .1; %inches
lengthSecs = sum(endPos - startPos) + (m_deriv_spacing/inchPerSec)*(numDerivs-1);
lengthInchs = lengthSecs * inchPerSec;
fWrapWidthSecs = fWrapWidthInches / inchPerSec;

%compute number of subplots required.
if(fWrapWidthInches == 0)
    numSubPlots = 1;
    widthSecs = lengthSecs;
else
    numSubPlots = ceil(lengthInchs / fWrapWidthInches);
    widthSecs = fWrapWidthSecs;
end

if(numSubPlots == 1)
    widthSecs = lengthSecs;
end


%compute width and height of each row
widthInches = widthSecs * inchPerSec;
freq = [0:param.fs/param.pad:(param.fs/2)-1];
freq = freq(1:254);
heightInches = ((freq(end)-freq(1))/1000)*inchPerkHz;

%Plot it

%Create an appropriately size figure.
h = figure();
set(h,'Units','inches');
margin = 1;
spacing = .1;
figPos = [2,2,widthInches + margin, (heightInches+spacing)*numSubPlots + margin];
set(h,'Position', figPos);

nSubPlot = numSubPlots;
rowRemainingSecs = widthSecs;
for(nDeriv = 1:numDerivs)
    curr_m_spec_deriv = m_spec_derivs{nDeriv};
    curr_pos = startPos(nDeriv);
    curr_endPos = endPos(nDeriv);
    while(curr_pos < curr_endPos)
        currWidthSecs = min(rowRemainingSecs, curr_endPos - curr_pos);
        subPos(1) = margin * .75 + (widthSecs - rowRemainingSecs)*inchPerSec; %x position of subplot, inches
        subPos(2) = margin*.5 + (heightInches+spacing)*(nSubPlot-1);
        subPos(3) = currWidthSecs * inchPerSec;
        subPos(4) = heightInches;
        ah(nSubPlot) = axes('Units', 'inches', 'Position', subPos); 
        aSAP_displaySpectralDerivative(curr_m_spec_deriv, ...
            param, startTime(nDeriv), curr_pos, ...
            curr_pos + currWidthSecs, bSigmoid, ...
            fScale, inchPerSec, inchPerkHz, ...
            true, true, inLineText{nDeriv});
        set(gca, 'XTick',getXTicks(curr_pos, currWidthSecs, inchPerSec));
        set(gca, 'YTick',getYTicks(inchPerkHz));
        if(nSubPlot~=1 | rowRemainingSecs ~= widthSecs)
            xlabel('');
            ylabel('');
            set(gca, 'XTickLabelMode', 'manual');
            set(gca, 'XTickLabel',[]);
            set(gca, 'YTickLabelMode', 'manual');
            set(gca, 'YTickLabel',[]);
        end
        set(gca, 'Units', 'normalized');

        %Add a ... to the upper right
        if(curr_pos + currWidthSecs ~= curr_endPos)        
            xPos = xlim; xPos = xPos(1) + .95*diff(xPos);
            yPos = ylim; yPos = yPos(1) + .95*diff(yPos);
            text(xPos,yPos,'...','Color','red','FontUnits','normalized','FontSize',.1);        
        end
        
        %update variables
        curr_pos = curr_pos + currWidthSecs;
        rowRemainingSecs = rowRemainingSecs - currWidthSecs;
        if(rowRemainingSecs <= 0)
            rowRemainingSecs = widthSecs;
            nSubPlot = nSubPlot - 1;
        end
    end
    rowRemainingSecs = rowRemainingSecs - m_deriv_spacing/inchPerSec;
    if(rowRemainingSecs <= 0)
        rowRemainingSecs = widthSecs;
        nSubPlot = nSubPlot - 1;
    end
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


