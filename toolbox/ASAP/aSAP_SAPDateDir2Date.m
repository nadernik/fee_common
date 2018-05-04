function dn = aSAP_SAPDateDir2Date(dateDir)
if(~isfloat(dateDir))
    dateDir = str2double(dateDir);
end
year = 2006;
month = 1;
day = 20;

dayDelta = round(dateDir - 365);
dn = datenum(year, month, day+dayDelta);