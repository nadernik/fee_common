function filename = getExperDatafile(exper, num, chan)
%This function assumes the dir command returns the filenames in alphebetical order.
persistent d;
persistent d_exper;

filename = '';
if(~isempty(d_exper) && strcmp(exper.dir, d_exper.dir) && strcmp(exper.birdname, d_exper.birdname) &  strcmp(exper.expername, d_exper.expername))
    filename = helper_getExperDatafile(d, exper, num, chan, true);
end
if(strcmp(filename, ''))
    d = dir([exper.dir,exper.birdname,'_d*chan',num2str(chan),'.dat']);
    filename = helper_getExperDatafile(d, exper, num, chan, false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function filename = helper_getExperDatafile(d,exper, num, chan, bSilent)
filename = ''; %#ok<NASGU>

if(isempty(d))
    if(~bSilent)
        warning(['getExperDatafile failed:  No .dat filenum ', num2str(num),' chan ', num2str(chan), ' in ', exper.dir,'.']);           
    end
    filename = '';
    return;  
end

if(num < length(d))
    filename = d(num).name;
    currNum = extractDatafileNumber(exper, filename);
else
    filename = '';
    currNum = 0;
end

%%If sorted method failed, use binary search...
if(num ~= currNum)
    lf = 1;
    rt = length(d);    
    while(true)
        mid = floor((lf + rt)/2);
        filename = d(mid).name;
        currNum = extractDatafileNumber(exper, filename);
        if(num == currNum)
            filename = d(mid).name;
            break;
        elseif(num > currNum)
            lf = mid+1;
        elseif(num < currNum)
            rt = mid-1;
        end
        
        if(lf>rt)
            if(~bSilent)
                warning(['getExperDatafile failed:  No filenum ', num2str(num) , 'found on chan ', num2str(chan), ' in ', exper.dir,'.']);           
            end
            filename = '';
            return;  
        end      
    end
end
