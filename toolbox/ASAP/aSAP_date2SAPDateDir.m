function dateDir = aSAP_Date2SAPDateDir(dn)

refyear = 2006;
refmonth = 1;
refday = 20;

refdir = 365;

refdn = datenum(refyear, refmonth, refday);
[year, month, day] = datevec(dn);

dayDelta = round(etime(datevec(refdn), datevec(datenum(year,month,day)))/(24*60*60));
dateDir = num2str(round(refdir - dayDelta));