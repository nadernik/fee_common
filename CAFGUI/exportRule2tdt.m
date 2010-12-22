function exportRule2tdt(rule,RP)
% .tdtTags(n).name
%                .type
%                .pfield

for ntag = 1:length(rule.tdtTags) 
    tag = rule.tdtTags(ntag); % for each tag
%     keyboard %%%DEBUG
    switch tag.type % use the proper write function
        case 'buffer'
            % pad with zeros or truncate. must be the same size as the
            % buffer we are writing to.
            vec = rule.params.(tag.pfield);
            if length(vec) > tag.size
                vec = vec(1:tag.size);
                warning('TDT:SizeMismatch', ...
                    'Truncated %s for in rule %s to make it fit in buffer %s.',tag.pfield,rule.name,tag.name)
            else
                vec(end+1:tag.size) = 0;
            end
            helper_WriteTag(RP, tag.name, vec, 0)
        case 'scalar'
            helper_SetTag(RP, tag.name, rule.params.(tag.pfield))
        otherwise
            error('Unknown tag type "%s"',tag.type)
    end
end

function helper_WriteTag(RP, Name, buffer, nOS)
buffer = buffer(:)'; % buffer must be a row vector
buffer = double(buffer); % buffer must be of type double
success = RP.WriteTagV(Name, nOS, buffer);
if ~success
    error('Unable to write to buffer %s.',Name)
end

function helper_SetTag(RP, Name, Val)
success = RP.SetTagVal(Name, Val);
if ~success
    error('Unable to set tag %s.', Name)
end
