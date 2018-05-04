function str = varname2str(varname)
% replaces underscores with spaces and capital letters in the middle of
% words into spaces + lowercase version of that letter

ich = 0;
for chr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' % for each capital letter
    ich = ich + 1;
    findpat{ich} = ['(\w)' chr]; % look for a character followed by a capital letter
    replpat{ich} = ['$1 ' lower(chr)]; % replace with the same character, space, and lowercase version of teh capital letter
end
str = regexprep(varname, findpat, replpat);

% replace underscores with spaces
str = strrep(str, '_', ' ');

% capitalize the first letter of each word
str = capwords(str);
