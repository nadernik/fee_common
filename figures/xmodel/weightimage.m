function weightimage(d, onto, from)

if nargin == 1
    % if no specific weights are specified, plot hvc->msn weights
    from = 'hvc';
    onto = 'msn';
end

fieldname = sprintf('weights_on_%s_from_%s', onto, from);
imagesc(d.(fieldname))
xlabel(from)
ylabel(onto)