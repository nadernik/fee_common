function emptyStruct = emptystruct(fieldNames, varargin)
%%Process varargin to find size of empty cell
maybeMoreFlds = false;
if ~iscellstr(fieldNames)
    if ischar(fieldNames)
        maybeMoreFlds = true;
    else
        error('fieldNames must be a string type')
    end
end
if maybeMoreFlds
    nVarArg = numel(varargin);
    nStrV = 0;
    while nStrV < nVarArg && ischar(varargin{nStrV+1})
        nStrV = nStrV + 1;
    end
    fieldNames = {fieldNames, varargin{1:nStrV}};
    varargin = varargin((1+nStrV):end);
end
nFld = numel(fieldNames);
nvararg = numel(varargin);
if nvararg > 0
    assert(all(cellfun(@isnumeric, varargin)), 'trailing arguments must be numeric');
    emptyCell = cell(varargin{:});
else
    emptyCell = cell(1);
end
argCell = cell(2, nFld);
argCell(1,:) = fieldNames(:);
argCell(2,:) = {emptyCell};
emptyStruct = struct(argCell{:});
end