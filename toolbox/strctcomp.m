function out = strctcomp(strct1, strct2)
%Check if structs are totally equal or equal within some tolerance
%
%takes two structures as input, returns true if they're equal
%If not exactly equal, it will go through the structures to determine where
%the structures differ. It will also check to see if floating values are
%within a tolerance value of eachother
%
%Written by Galen Lynch 7/6/2014
TOLERANCE = 1e-5; %Change this to change what's 'good enough'
out = isequaln(strct1, strct2);
if numel(strct1) == numel(strct2)
    disp('Lengths are equal')
    nArr = numel(strct1);
    if all(strcmp(fieldnames(strct1), fieldnames(strct2)))
        disp('Structs have same fields')
        flds = fieldnames(strct1);
        for fldNo = 1:length(flds)
            fld = flds{fldNo};
            sameClass = true;
            strctC1 = class(strct1(1).(fld));
            strctC2 = class(strct2(1).(fld));
            for kk = 1:nArr
                sameClass = sameClass && isa(strct1(kk).(fld), strctC1);
                sameClass = sameClass && isa(strct2(kk).(fld), strctC2);
            end
            if ~sameClass
                fprintf('Field ''%s'' changes class over elements of the struct array, giving up!\n', fld);
            elseif strcmp(strctC1, strctC2)
                fprintf('Field ''%s'' contains the same class in both structs\n', fld);
                for arrNo = 1:nArr
                    if isequal(strct1(arrNo).(fld), strct2(arrNo).(fld))
                        fprintf('Fields ''%s'' at position %d are equal\n', fld, arrNo)
                    else
                        fprintf('Unequal values in field ''%s'' at position %d\n', fld, arrNo)
                        if isa(strct1(arrNo).(fld), 'cell')
                            recursive_cell_comp(strct1(arrNo).(fld), strct2(arrNo).(fld), TOLERANCE)
                        elseif isa(strct1(arrNo).(fld), 'double') && isequal(size(strct1(arrNo).(fld)), size(strct2(arrNo).(fld)))
                            if all(abs(strct1(arrNo).(fld) - strct2(arrNo).(fld)) <= TOLERANCE)
                                fprintf('Doubles in field ''%s'' at position %d are within tolerance\n', fld, arrNo)
                            end
                        else
                            disp('Strct 1 has value:')
                            disp(strct1(arrNo).(fld));
                            disp('Strct 2 has value:')
                            disp(strct2(arrNo).(fld));
                        end
                    end
                end
            else
                fprintf('Field ''%s'' contains different classes\n', fld);
            end
        end
    else
        disp('Structs have different fields')
    end
else
    disp('Lengths are unequal')
end
end

function out = recursive_cell_comp(cell1, cell2, tolerance, depth)
assert(isa(cell1, 'cell') && isa(cell2, 'cell'), 'unexpectedly ran out of cells');
if ~exist('tolerance', 'var')
    tolerance = 1e-5;
end
if ~exist('depth', 'var')
    depth = 1;
end
if isequal(cell1, cell2)
    out = true;
else
    nEntry = numel(cell1);
    if nEntry ~= numel(cell2)
        fprintf('Unequal cell lengths at depth %d/n', depth)
    else
        for entryNo = 1:nEntry
            if isequal(cell1{entryNo}, cell2{entryNo})%If they're equal
                continue;
            elseif ~strcmp(class(cell1{entryNo}), class(cell2{entryNo}))%If they're not the same class
                fprintf([repmat(' ', 1, depth-1), '! different classes at depth %d position %d\n'], depth, entryNo); 
            elseif isa(cell1{entryNo}, 'cell')%If they're differing cells
                fprintf([repmat(' ', 1, depth-1), 'checking position %d at depth %d...\n'], entryNo, depth);
                recursive_cell_comp(cell1{entryNo}, cell2{entryNo}, depth+1);
            else%If they're differing non-cells
                if isa(cell1{entryNo}, 'double')%If they're differing doubles
                    if isempty(cell1{entryNo}) && isempty(cell2{entryNo})%If they're empty
                        fprintf([repmat(' ', 1, depth-1), 'entries at depth %d position %d are both empty\n'], depth, entryNo);
                    elseif isequal(size(cell1{entryNo}),size((cell2{entryNo}))) %if they're non-empty and the same size
                        if all(abs(cell1{entryNo} - cell2{entryNo}) <= tolerance)%If they're close enough
                            fprintf([repmat(' ', 1, depth-1), 'entries at depth %d position %d within tolerance\n'], depth, entryNo);
                        else%If they're not close enough
                            fprintf([repmat(' ', 1, depth-1), '! unequal entries at depth %d position %d\n'], depth, entryNo);
                        end
                    else %If they're non-empty and differing sizes
                        fprintf([repmat(' ', 1, depth-1), '! length differs in entries at depth %d position %d\n'], depth, entryNo);
                    end
                else%If they're differing non-cell and non-double
                    fprintf([repmat(' ', 1, depth-1), '! unequal entries at depth %d position %d\n'], depth, entryNo);
                end
            end
        end
    end
end
end