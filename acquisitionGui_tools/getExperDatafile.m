function filename = getExperDatafile(exper, num, chan)
%This function assumes the dir command returns the filenames in alphebetical order.
persistent dirStruct;
persistent d_exper;
persistent d_searchstring

if isnumeric(chan)
    chanstr = ['chan' int2str(chan)];
elseif ischar(chan)
    chanstr = chan;
else
    error('Chan must be an integer or a string')
end
searchstring = [exper.birdname '_d*' chanstr '.*'];

filename = '';
if strcmp(searchstring, d_searchstring) && ...
        ~isempty(d_exper) && ...
        strcmp(exper.dir,       d_exper.dir) && ...
        strcmp(exper.birdname,  d_exper.birdname) &&  ...
        strcmp(exper.expername, d_exper.expername)
    filename = helper_getExperDatafile(dirStruct, exper, num, chanstr, true);
end
if strcmp(filename, '')
    dirStruct = dir(fullfile(exper.dir, searchstring));
    d_exper = exper;
    d_searchstring = searchstring;
    filename = helper_getExperDatafile(dirStruct, exper, num, chanstr, false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function filename = helper_getExperDatafile(dirStruct, exper, num, chanstr, bSilent)
filename = ''; %#ok<NASGU>

if isempty(dirStruct)
    if(~bSilent)
        fprintf('No file number %d for channel ''%s'' in %s.\n', num, chanstr, exper.dir);           
    end
    filename = '';
    return;  
end

if num < length(dirStruct)
    filename = dirStruct(num).name;
    currNum = extractDatafileNumber(exper, filename);
else
    filename = '';
    currNum = 0;
end

%%If sorted method failed, use binary search...
if num ~= currNum
    lf = 1;
    rt = length(dirStruct);    
    while true
        mid = floor((lf + rt)/2);
        filename = dirStruct(mid).name;
        currNum = extractDatafileNumber(exper, filename);
        if(num == currNum)
            filename = dirStruct(mid).name;
            break;
        elseif(num > currNum)
            lf = mid+1;
        elseif(num < currNum)
            rt = mid-1;
        end
        
        if lf > rt
            if ~bSilent
                fprintf('No file number %d for channel ''%s'' in %s.\n', num, chanstr, exper.dir);          
            end
            filename = '';
            return;  
        end      
    end
end
