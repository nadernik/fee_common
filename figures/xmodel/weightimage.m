function weightimage(d, onto, from, do_sort)

if nargin == 1
    % if no specific weights are specified, plot hvc->msn weights
    from = 'hvc';
    onto = 'msn';
end

fieldname = sprintf('weights_on_%s_from_%s', onto, from);

if exist('do_sort', 'var') && do_sort == true
    for row = 1:size(d.(fieldname), 1)
        [maxval maxndx(row)] = max(d.(fieldname)(row,:));
    end
    [junk, sortndx] = sort(maxndx);
    sorted = d.(fieldname)(sortndx,:);
    imagesc(sorted)
else
    imagesc(d.(fieldname))
end



xlabel(from)
ylabel(onto)
set(gca, 'XTick', [], 'YTick', [])
axis square