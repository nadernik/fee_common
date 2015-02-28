function emptyHandles = preallocatehandles(varargin)
if verLessThan('matlab','8.4.0')
    emptyHandles = nan(varargin{:});
else
    emptyHandles = gobjects(varargin{:});
end
end