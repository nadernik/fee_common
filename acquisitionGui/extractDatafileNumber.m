function num = extractDatafileNumber(exper, name)
%extractDatafileNumber number of file recorded by acquisitionGui
%
% num = extractDatafileNumber(exper, name)
% num is a vector of integers
% exper is the exper data structure created by acquisitionGui. You can load
%       this with loadExper()
% name is a string with the name of the datafile or a cell array of strings
REGSTR = '^.+_d(\d{6})_\d{8}T\d{6}chan\d+\.dat$';
if ~iscell(name)
    name = {name};
end
tokens = regexp(name, REGSTR, 'tokens', 'once');
num = str2double([tokens{:}]);