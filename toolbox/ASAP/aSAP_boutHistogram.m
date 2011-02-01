function aSAP_boutHistogram(singingSumm)

absBoutStartTimes = 0;
for(nFile = 1:length(singingSumm.fileinfo))
    fileSumm = singingSumm.fileinfo(nFile);
    absBoutStartTimes = [absBoutStartTimes, fileSumm.rawSyllStartTimesAbs(fileSumm.boutStartSyll)];
end

absBoutStartTimes = absBoutStartTimes(find(absBoutStartTimes~=0));

%find the range of dates
dnRange = max(absBoutStartTimes) - min(absBoutStartTimes);
elapsedDays = etime(datevec(max(absBoutStartTimes)), datevec(min(absBoutStartTimes))) / (60*60*24);
if(elapsedDays < 2)
    binPerDay = 72;
    fmt = 15;
else
    binPerDay = 4;
    fmt = 0;
end

axes(handles.axesSongProduction);
edges = [min(fileDateNums) - eps:dnRange/(elapsedDays*binPerDay):max(fileDateNums)+eps];
n = histc(fileDateNums, edges);
bar(edges, n, 'histc');
datetick('x',fmt);
axis tight;
title(['Histogram of Wav DateModified: ', datestr(median(fileDateNums),1)]); 


hist(absBoutStartTimes, 72);
datetick('x');
