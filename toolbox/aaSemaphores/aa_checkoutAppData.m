function [value , status] = aa_checkoutAppData(h, name)

%Only one checkout can be called at a time...
st = dbstack;
for(i=2:length(st))
    if(strcmp(st(i).name,'aa_checkoutAppData'))
        value = [];
        status = 0;
        return;
    end
end

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
    theSem = numSem + 1;
    AA_APPDATASEMAPHORE(theSem).h = h;
    AA_APPDATASEMAPHORE(theSem).name = name;
    AA_APPDATASEMAPHORE(theSem).status = 0;
end

if(AA_APPDATASEMAPHORE(theSem).status == 0)
    AA_APPDATASEMAPHORE(theSem).status = st(2).name;
    value = getappdata(h, name);
    status = 1;
else
    value = [];
    status = 0;
end


