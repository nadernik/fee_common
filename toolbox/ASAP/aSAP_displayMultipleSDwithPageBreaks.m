function hFigs = aSAP_displayMultipleSDwithPageBreaks(m_spec_derivs, ...
        param, inchPerSec, inchPerkHz, fWrapWidthInches, ...
        figTitle, pageHeight, bPauseBetweenPages, inLineText, ...
        startTime, startPos, endPos, bSigmoid, fScale)

%Options:
%device = '-dwin' and fullfilename = '' prints to default printer
%device = '-dbitmap' and fullfilename = ''... copies to clipboard
%device = '-dbpm' and fullfilename not ''... saves bitmap file.
%device = 'djpeg' and fullfilename not ''... save to jpeg file.
%device = '-dlg' brings up windows printer dialog box.

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
if(~exist('figTitle'))
    figTitle = '';
end
if(~exist('pageHeight'))
    pageHeight = 10;
end
if(~exist('bPauseBetweenPages'))
    bPauseBetweenPages = false;
end
if(~exist('inLineText') || (length(inLineText)==0))
    inLineText(1:numDerivs) = {''};
end

%compute row height, row width, page height, and the width of each deriv
freq = [0:param.fs/param.pad:(param.fs/2)-1];
freq = freq(1:254);
rowHeight = ((freq(end)-freq(1))/1000)*inchPerkHz;
rowWidth = fWrapWidthInches;
m_deriv_spacing = .1; %inches
for(nDeriv = 1:length(m_spec_derivs))
    derivWidths(nDeriv) = aSAP_getSDSecs(m_spec_derivs{nDeriv}, param) * inchPerSec + m_deriv_spacing;
end
inchesPerPage = floor(pageHeight/rowHeight)*rowWidth;

nPage = 1;
startPageDeriv = 1;
endPageDeriv = 1;
while(startPageDeriv <= length(m_spec_derivs))
    
    %See how many of the next m_spec_derivs can fit on a page
    inchesOnPage = derivWidths(startPageDeriv);
    while((endPageDeriv < length(m_spec_derivs)) && ...
          (inchesOnPage + derivWidths(endPageDeriv + 1)< inchesPerPage))
        endPageDeriv = endPageDeriv + 1;
        inchesOnPage = inchesOnPage + derivWidths(endPageDeriv);
    end
   
    %Display the page
    hFigs(nPage) = aSAP_displayMultipleSD(m_spec_derivs(startPageDeriv:endPageDeriv), ...
        param, inchPerSec, inchPerkHz, fWrapWidthInches, ...
        startTime(startPageDeriv:endPageDeriv), ...
        startPos(startPageDeriv:endPageDeriv), ...
        endPos(startPageDeriv:endPageDeriv), ...
        bSigmoid, fScale, ...
        inLineText(startPageDeriv:endPageDeriv));
    title([figTitle, '-page',num2str(nPage)]);
    
    if(bPauseBetweenPages)
        pause;
    end
    
    %The derivative
    startPageDeriv = endPageDeriv + 1;
    endPageDeriv = startPageDeriv;
    nPage = nPage + 1;
end