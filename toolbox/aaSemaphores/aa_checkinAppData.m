function [status] = aa_checkinAppData(h, name, value)

global AA_APPDATASEMAPHORE;
theSem = 0;
numSem = length(AA_APPDATASEMAPHORE);
for(nSem = 1:numSem)
    if((AA_APPDATASEMAPHORE(nSem).h == h) && strcmp(AA_APPDATASEMAPHORE(nSem).name, name))
        theSem = nSem;
        break;
    end
end

if(theSem == 0)
    warning('aa_checkInAppData did not find semaphore.');
    status = 0;
    return;
end

%currently have a laxed check in policy.  I do not verify, based on
%dbstack and AA_APPDATASEMAPHORE.status, that the checker-in was the
%checker-out.  
setappdata(h, name, value);
status = 1;
AA_APPDATASEMAPHORE(theSem).status = 0;
