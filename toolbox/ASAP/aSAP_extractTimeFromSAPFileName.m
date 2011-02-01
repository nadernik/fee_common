function time = aSAP_extractTimeFromSAPFileName(fname)
%Author: Aaron Andalman 2006.01.31
%extract the time from SAP generated wav filename.

[path,filename,ext] = fileparts(fname);
if(~strcmp(ext,'.wav'))
    filename = [filename,ext];
end
us = strfind(filename,'_');

if(length(us)<2)
    warning('extractTimeFromSAPFileName: SAP File name is miss formatted.');
    time = 0;
    return;
end

wintime = str2num(filename(us(1)+1:us(2)-1));
time = aSAP_wintime2dn(wintime);

% if(length(us)~=6)
%     warning('extractTimeFromSAPFileName: SAP File name is miss formatted.');
%     time = 0;
%     return;
% end
% m = str2num(filename(us(2)+1:us(3)-1));
% d = str2num(filename(us(3)+1:us(4)-1));
% h = str2num(filename(us(4)+1:us(5)-1));
% min = str2num(filename(us(5)+1:us(6)-1));
% s = str2num(filename(us(6)+1:end));
% time = datenum(year,m,d,h,min,s);

 