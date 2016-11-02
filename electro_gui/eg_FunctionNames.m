function names = eg_FunctionNames
egdir = fileparts(which('electro_gui'));
mt = dir(fullfile(egdir, 'egf_*.m'));
names = cell(1, length(mt) + 1);
names{1} = '(Raw)';
for c = 1:length(mt)
    names{c+1} = mt(c).name(5:end-2);
    %mt(c).name is like egf_FunctionName.m
    %                   12345....      ^(this is end-2)
end