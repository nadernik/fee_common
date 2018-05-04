function sd = subdirs(d)
%SUBDIRS List subdirectories
%    SD = SUBDIRS(D) returns a struct of subdirectories immediately under
%    directory D. It is not recursive. The fields of SD are the same as the
%    fields returned by the DIR() function.
files = dir(d);
% Only keep file entries that are directories NOT named "." or ".."
keep = @(f) f.isdir && ~strcmp(f.name, '.') && ~strcmp(f.name, '..');
sd = files(arrayfun(keep, files));