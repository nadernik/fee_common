function filename = get_annotation_filename(birdname, expername, varargin)

P.part = 1;
P.rootdir = 'c:\stetner\data\';
P.type = 'annotation';
P.prefix = 'all';
P = parseargs(P, varargin{:});

% omit suffix if first part
if P.part > 1
    suffix = num2str(P.part, '-pt%03.f');
else
    suffix = '';
end

% omit prefix if annotation
if strcmp(P.type, 'annotation')
    prefix_and_type = P.type;
else
    prefix_and_type = [P.prefix '_' P.type];
end

filename = [P.rootdir filesep birdname filesep ...
    birdname '_' prefix_and_type '_' expername suffix '.mat'];