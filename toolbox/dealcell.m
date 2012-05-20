function varargout = dealcell(ca)

if nargout ~= numel(ca)
    error('Number of output arguments must match number of elements in input')
end
varargout = ca;