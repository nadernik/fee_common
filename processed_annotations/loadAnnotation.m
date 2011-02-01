function anno = loadAnnotation(exper, varargin)

filename = sprintf('%s_annotation_%s', exper.birdname, exper.expername);
if nargin > 1
    part = varargin{1};
else
    part = 1;
end

if strcmp(part,'end')
    while exist(exist(filename,'file'))
        filename = sprintf('%s-pt%03.f', filename, part);
        part = part + 1;
    end
    part = part - 1;
end

if part ~= 1
    % if part is 1, there is no suffix
    filename = sprintf('%s-pt%03.f', filename, part);
end

anno = aaLoadHashtable(filename);