function dn = aSAP_wintime2dn(windowsTime)
daysSince1900 = floor(windowsTime);
secs = (60*60*24) * (windowsTime - daysSince1900);
dn = datenum(1900, 0, daysSince1900-1, 0, 0, secs);
