function [prefix, num] = getNewDatafilePrefix(exper)

num = getLatestDatafileNumber(exper) + 1;
prefix = sprintf('%s_d%06g_%s', exper.birdname, num, datestr(now,30));
