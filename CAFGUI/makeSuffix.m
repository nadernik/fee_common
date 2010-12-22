function tags = makeSuffix(tags,suff)

for n = 1:length(tags)
    % find existing suffix if it exists
    idx = regexp(tags(n).name,'\d+$'); % suffix is 1 or more digits at end of name
    if isempty(idx) % no existing suffix
        tags(n).name = [tags(n).name int2str(suff)];
    else % has suffix that we will replace
        tags(n).name = [tags(n).name(1:idx-1) int2str(suff)];
    end
end