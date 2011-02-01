function fileSumm = aSAP_augmentFileSumm(fileSumm, newFileSumm)

if(isequal(newFileSumm,[]))
    return;
elseif(isequal(fileSumm,[]))
    fileSumm = newFileSumm;
    return;
end

fileSumm.fileinfo = [fileSumm.fileinfo, newFileSumm.fileinfo];
 