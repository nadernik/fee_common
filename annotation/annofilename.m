function filename = annofilename(birdname, expername, varargin)

P.Part = 1;
P.RootDir = 'c:\stetner\data\';
P.Type = 'annotation';
P.Prefix = 'all';
P = parseargs(P, varargin{:});

% omit suffix if first part
if P.Part > 1
    suffix = num2str(P.Part, '-pt%03.f');
else
    suffix = '';
end

% omit prefix if annotation
if strcmp(P.Type, 'annotation')
    prefix_and_type = P.Type;
else
    prefix_and_type = [P.Prefix '_' P.Type];
end

filename = [P.RootDir filesep birdname filesep ...
    birdname '_' prefix_and_type '_' expername suffix '.mat'];