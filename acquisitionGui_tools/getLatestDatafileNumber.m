function num = getLatestDatafileNumber(exper)
num = 0;
d = dir(fullfile(exper.dir, [exper.birdname, '_d*']));
if ~isempty(d)
    num = extractDatafileNumber(exper, d(end).name);
end