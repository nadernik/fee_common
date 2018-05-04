function aSAP_printFigures(hFigs, device, fullfilename)

%Options:
%device = '-dwin' and fullfilename = '' prints to default printer
%device = '-dbitmap' and fullfilename = ''... copies to clipboard
%device = '-dbpm' and fullfilename not ''... saves bitmap file.
%device = 'djpeg' and fullfilename not ''... save to jpeg file.
%device = '-dlg' brings up windows printer dialog box.

%Maybe utilize PaperUnits, PaperSize, PaperPosition... in the future.
%For now changing the axes from inches to normalized allows the printer
%to resize the figure to fit on the page.

for(nFig = 1:length(hFigs))
    figure(hFigs(nFig));
    
    %print to default printer
    if(strcmp(device,'-djpeg'))
        txt = '-r300';
    else
        txt = '';
    end

    printfile = [fullfilename,'-fig',num2str(nFig)];
    if(~strcmp(device,'-dlg'))
        print(device, txt, printfile);
    else
        printdlg;
    end
end