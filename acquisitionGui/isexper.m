function y = isexper(exper)
%ISEXPER True if input is a valid acquisitionGui exper
%
%Usage:
%  y = isexper(exper)

y = true;

fnames = {'dir', 'birdname', 'birddesc', 'expername', 'experdesc', 'datecreated', 'desiredInSampRate', 'audioCh', 'sigCh', 'sigName', 'sigDesc'};
for ii = 1:length(fnames)
    if ~isfield(exper, fnames{ii})
        y = false;
        debugdisp(['NOT an exper because field is missing: ' fnames{ii}])
    end
end

if y == true && ~strcmp(exper.dir(end), filesep)
    y = false;
    debugdisp(['NOT an exper because dir does not end in ' filesep])
end