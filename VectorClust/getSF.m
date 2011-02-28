function f = getSF(vcdb, nFeat, bndx)
if(nFeat>0)
    f = vcdb.d.sf(:,nFeat);
elseif(nFeat == -1)
    f = [nan; vcdb.d.cn(1:end-1)];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
elseif(nFeat == -2)
    f = [vcdb.d.cn(2:end); nan];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
elseif(nFeat == -3)
    f = [nan; nan; vcdb.d.cn(1:end-2)];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
elseif(nFeat == -4)
    f = [vcdb.d.cn(3:end); nan; nan];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO  
else
    error(['getSF: requested feature does not exist: ', num2str(nFeat)]);
end
if(exist('bndx'))
    f = f(bndx);
end