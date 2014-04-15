function plotFilesPerHour(varargin)
% plotFilesPerHour Number of acquisitionGui data files recorded per hour
%
% Syntax:
%   plotFilesPerHour(exper)
%   plotFilesPerHour('bird name', 'exper name')
%   plotFilesPerHour('bird name', 'exper name', 'data directory')
%   plotFilesPerHour(ahx, ...)
%       Plots on axes referred to by the axes handle axh
%
% This function relies on these acquisitionGui functions:
%   loadExper()
%   extractExperFilenumTime()
%   getLatestDatafileNumber()

defaultDataDir = 'c:\stetner\data';

if nargin > 1 && isscalar(varargin{1}) && ishandle(varargin{1})
    axh = varargin{1};
    numargs = nargin - 1;
    args = varargin(2:end);
else
    axh = nan;
    numargs = nargin;
    args = varargin;
end
    

switch numargs
    case 1
        exper = args{1};
    case 2
        birdName = args{1};
        experName = args{2};
        exper = loadExper(birdName, experName, defaultDataDir);
    case 3
        birdName = args{1};
        experName = args{2};
        dataDir = args{3};
        exper = loadExper(birdName, experName, dataDir);
end
        
% Calculate the hour of each file
numfiles = getLatestDatafileNumber(exper);
t = nan(numfiles,1);
for filenum = 1:numfiles
    t(filenum) = extractExperFilenumTime(exper, filenum);
end
hr = hour(t);
x = -0.5:1:24.5;
if ishandle(axh)
    hist(axh, hr, x)
else
    hist(hr, x)
end

set(gca, 'XLim', [0 24], 'XTick', 0.5:1:23.5, 'XTickLabel', 0:1:23)