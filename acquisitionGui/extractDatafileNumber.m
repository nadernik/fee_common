function num = extractDatafileNumber(exper, name)
%extractDatafileNumber number of file recorded by acquisitionGui
%
% num = extractDatafileNumber(exper, name)
% num is a vector of integers
% exper is the exper data structure created by acquisitionGui. You can load
%       this with loadExper()
% name is a string with the name of the datafile or a cell array of strings

if ~iscell(name)
    name = {name};
end

num = zeros(size(name));
for k = 1:length(name)
    u = strfind(name{k}, '_');
    num(k) = str2num(name{k}(u(1)+2:u(2)-1));
end