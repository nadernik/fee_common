function wintime = aSAP_dn2wintime(dn)
[year, month, day, hour, min, second] = datevec(dn);
days = (etime([year, month, day,0,0,0],[1900,1,0,0,0,0]) / (24*60*60)) + 1; 
second = second + hour*60*60 + min*60;
frac = second / (60*60*24);
wintime = days + frac;