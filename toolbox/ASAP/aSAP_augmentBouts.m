function bouts = aSAP_augmentBouts(bouts, newBouts)

if(isequal(newBouts,[]))
    return;
elseif(isequal(bouts,[]))
    bouts = newBouts;
    return;
end

bouts.filename = [bouts.filename, newBouts.filename];
bouts.filepath = [bouts.filepath, newBouts.filepath]; 
bouts.filetime = [bouts.filetime, newBouts.filetime];
bouts.rawAudFs = [bouts.rawAudFs, newBouts.rawAudFs];
bouts.numSylls = [bouts.numSylls, newBouts.numSylls]; 
bouts.startTFile = [bouts.startTFile, newBouts.startTFile];
bouts.endTFile = [bouts.endTFile, newBouts.endTFile];
bouts.startTAbs = [bouts.startTAbs, newBouts.startTAbs];
bouts.endTAbs = [bouts.endTAbs, newBouts.endTAbs];
bouts.meth = [bouts.meth, newBouts.meth];