function fScale = aSAP_displaySpectralDerivative(m_spec_deriv, ...
        param, startTime, startPos, endPos, bSigmoid, ...
        fScale, inchPerSec, inchPerkHz, ...
        bModifyAxesWidth, bModifyAxesHeight, ...
        inLineText)
%m_spec_deriv: (rows = time, cols = freq).
%param: the param structure used when computing the spec_deriv (requires,
%   pad, winstep, and fs values.
%startTime: (default 0) the time in secs of the first row of m_spec_deriv.
%startPos: (default startTime) the time in secs at which you would like the display to begin.
%endPos: (default: length of m_spec_deriv in Secs) the time in secs at you
%   would like the display to end.  Pass -Inf to invoke the default.
%bSigmoid: samples color following a sigmoid, rather than linearly.
%fScale: (default 90 percentile m_spec_deriv) used differently depending of
%   value of bSigmoid.  (Pass 0 to invoke default (autoscale)).
%   if ~bSigmoid: then -fScale is black and +fScale is white.  fScale=~7e9.
%   if bSigmoid: then m_spec_deriv/fScale prior to taking sigmoid.  fScale=~7e9.
%inchPerSec: generate display such that 1 sec fills specifed # of inches.
%inchPerkHz: generate display such that kHz fills specifed # of inches.
%bModifyAxesWidth: modify the axes width such that inchPerSec and
%   endPos-startPos are compatible.
%bModifyAxesHeight:modify the axes height such that the fit is tight given
%   inchPerKHz
%inLineText: text that goes in the top left of the SD.

%Transpose the spec_deriv...
m_spec_deriv = m_spec_deriv';

%Set any default parameters that were unspecified (except entTime)
if(~exist('startTime'))
    startTime = 0;
end
if(~exist('startPos'))
    startPos = startTime;
end
if(exist('fScale'))
    bAutoScale = (fScale==0);
else
    bAutoScale = true;
end
if(~exist('bSigmoid'))
    bSigmoid = false;
end
if(~exist('bModifyAxesWidth'))
    bModifyAxesWidth = false;
end
if(~exist('bModifyAxesHeight'))
    bModifyAxesHeight = false;
end
if(~exist('inLineText'))
    inLineText = '';
end

%Extract parameters needed to interpret m_spec_deriv values.
sampleRate = param.fs;
windowAdv = param.winstep;
winPad = param.pad;

%Compute axes interpretations... freq may be 1 off.
endTime = startTime + (size(m_spec_deriv,2)*(windowAdv/sampleRate));
stepTime = (endTime - startTime)/ (size(m_spec_deriv,2)-1);
time = [startTime:stepTime:endTime];
freq = [0:sampleRate/winPad:(sampleRate/2)-1];
freq = freq(1:254);

if(~exist('endPos'))
    endPos = endTime;
elseif(endPos == -Inf)
    endPos = endTime;
end
if(endPos<startPos)
    endPos = max(startPos+1, endTime);
end

%plot using image scale
if(bSigmoid)
    if(bAutoScale)
        fScale = aSAP_getSDAutoscale(m_spec_deriv);
    end    
    m_spec_deriv = 1./(1+exp(-m_spec_deriv./fScale));
    i = imagesc(time,freq,m_spec_deriv); axis xy; 
    set(i,'HitTest','off');
    colormap(bone);
else
    if(bAutoScale)
        fScale = aSAP_getSDAutoscale(m_spec_deriv);
    end
    i = imagesc(time,freq,m_spec_deriv, [-fScale,fScale]); axis xy;
    set(i,'HitTest','off');
    colormap(bone);
end
xlabel('time (s)');
ylabel('freq (Hz)');

ha = gca;  
unit = get(ha,'Units');
set(ha,'Units','inches');
apos = get(ha,'Position');

%DEAL WITH TIME AXES:
if(bModifyAxesWidth && exist('inchPerSec') && (inchPerSec~=0))
    displayWidth = (endPos-startPos) * inchPerSec;
    apos(3) = displayWidth; %reset the width
    set(ha, 'Position', apos);
end
if(exist('inchPerSec') && (inchPerSec~=0))
    xlim([startPos, startPos + (apos(3)/inchPerSec)]);
else
    xlim([startPos, endPos]);
end

%DEAL WITH FREQ AXES
if(bModifyAxesHeight && exist('inchPerkHz') && (inchPerkHz~=0))
    displayHeight = ((max(freq)-min(freq))/1000) * inchPerkHz;
    apos(4) = displayHeight;
    set(ha, 'Position', apos);
end
if(exist('inchPerkHz') && (inchPerkHz~=0))
    ylim([freq(1),(apos(4) / inchPerkHz)*1000]);
else
    ylim([freq(1),freq(end)]);
end

%Put in the inlineText
xPos = xlim; xPos = xPos(1) + .005*diff(xPos);
yPos = ylim; yPos = yPos(1) + .90*diff(yPos);
text(xPos,yPos,inLineText,'Color','black', 'FontUnits','normalized','FontSize',.09);

%Setting units back to normalized, allows the axes to be rescaled.
set(ha,'Units',unit);

%function myCallback(src,eventdata,arg1,arg2)
%set(gca,'WindowButtonDownFcn',{@myCallback,arg1,arg2})
%If you wanted to lock in inches persec..
%you could force xlim and ylim changes upon axex resize event!!




