function aSAP_printSD(device, fullfilename, m_spec_deriv, ...
        param, inchPerSec, inchPerkHz, fWrapWidthInches, ...
        startTime, startPos, endPos, bSigmoid, fScale, figTitle)
%aSAP_printSD is DEAD, use aSAP_printFigures.     

%Options:
%device = '-dwin' and fullfilename = '' prints to default printer
%device = '-dbitmap' and fullfilename = ''... copies to clipboard
%device = '-dbpm' and fullfilename not ''... saves bitmap file.
%device = 'djpeg' and fullfilename not ''... save to jpeg file.
%device = '-dlg' brings up windows printer dialog box.

hFig = aSAP_displaySpectralDerivativeWithWrap(m_spec_deriv, ...
        param, inchPerSec, inchPerkHz, fWrapWidthInches, ...
        startTime, startPos, endPos, bSigmoid, fScale)
title(figTitle);
    
%Maybe utilize PaperUnits, PaperSize, PaperPosition... in the future.
%For now changing the axes from inches to normalized allows the printer
%to resize the figure to fit on the page.
    
%print to default printer
if(strcmp(device,'-djpeg'))
    txt = '-r300';
else
    txt = '';
end

if(~strcmp(device,'-dlg'))
    print(device, txt, fullfilename);
else
    printdlg;
end

close(hFig);
