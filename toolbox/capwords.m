function capped = capwords(s)
%CAPWORDS Capitalize the first letter of each word
%   capped = CAPWORDS(s)

% capitalize the first letter
ndx_letter = regexpi(s, '[A-Za-z]');
s = cap(s, ndx_letter(1));

% capitalize each letter that comes after a space
ndx_space = strfind(s, ' ');
ndx_word = intersect(ndx_space + 1, ndx_letter);
capped = cap(s, ndx_word);

function s2 = cap(s1, ndx)
s2 = s1;
s2(ndx) = upper(s1(ndx));
