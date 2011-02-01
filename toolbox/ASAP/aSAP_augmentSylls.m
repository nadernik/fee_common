function sylls = aSAP_augmentSylls(sylls, newSylls)

if(isequal(newSylls,[]))
    return;
elseif(isequal(sylls,[]))
    sylls = newSylls;
    return;
end

sylls.filename = [sylls.filename, newSylls.filename];
sylls.filepath = [sylls.filepath, newSylls.filepath]; 
sylls.filetime = [sylls.filetime, newSylls.filetime];
sylls.rawAudFs = [sylls.rawAudFs, newSylls.rawAudFs];
sylls.startTFile = [sylls.startTFile, newSylls.startTFile];
sylls.endTFile = [sylls.endTFile, newSylls.endTFile];
sylls.startTAbs = [sylls.startTAbs, newSylls.startTAbs];
sylls.endTAbs = [sylls.endTAbs, newSylls.endTAbs];
sylls.meth = [sylls.meth,newSylls.meth];
sylls.fileNoise = [sylls.fileNoise, newSylls.fileNoise];
sylls.fileNoiseVar = [sylls.fileNoiseVar, newSylls.fileNoiseVar];
