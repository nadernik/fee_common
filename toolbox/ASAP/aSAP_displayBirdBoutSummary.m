%Script to display all singing...

numDates = length([370:383]);
bouts = [];
for(nDate = 370:383)
    load(['aa111_',num2str(nDate)]);
    bouts = [bouts, aSAP_getAbsBoutTimesFromSumm(singingSumm)];
end

edges = [min(bouts) - eps:1/(24*4):max(bouts)+eps];
n = histc(bouts, edges);
bar(edges, n, 'histc');
datetick('x');
axis tight;
title(['Histogram of aa111 Jan25-Feb7']); 

get_aa111Info;

for(nDrug = 13:length(aa111Info.drugIn))
    x = [aa111Info.drugIn(nDrug),aa111Info.drugOut(nDrug),aa111Info.drugOut(nDrug),aa111Info.drugIn(nDrug)];
    ye = ylim; y=[ye(1),ye(1),ye(2),ye(2)];
    p = patch(x,y,'blue');
    if(aa111Info.bMusc(nDrug))
        set(p,'FaceColor','red');
    else
        set(p,'FaceColor','green');
    end
    set(p,'FaceAlpha',.4);
end

    