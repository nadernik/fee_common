function y = structcmp(A, B, varargin)

P.MATCH = 1;
P.FIELDNAME_MISMATCH = 0;
P.VALUES_MISMATCH = 0;
P.verbose = false;

Afields = fieldnames(A);
Bfields = fieldnames(B);
if length(Afields) ~= length(Bfields)
    verbalize(P, 'A and B have different number of fields.')
    y = P.FIELDNAME_MISMATCH;
    return
end
if ~all(ismember(Afields, Bfields))
    verbalize(P, 'A and B do not have the same fields.')
    y = P.FIELDNAME_MISMATCH;
    return
end

for field = Afields
    if ~cmp(A.(field), B.(field))
        y = P.VALUES_MISMATCH;
        return
    end
end

% If we have gotten this far, we must match!
y = P.MATCH;

function verbalize(P, str, varargin)
if P.verbose
    fprintf(1, str, varargin{:})
end

function tf = cmp(x, y)
if class(x) ~= class(y)
    tf = 0;
    return
end
switch class(x)
    case 'char'
        tf = strcmp(x, y);
    case 'struct'
        tf = P.MATCH == structcmp(x, y);
    case 'cell'
        
    otherwise
        try
            tf = all(x(:) == y(:));
        catch
            tf = false;
        end
end
        